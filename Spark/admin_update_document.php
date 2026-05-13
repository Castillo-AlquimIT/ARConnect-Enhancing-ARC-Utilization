<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$doc_id   = intval($_POST["doc_id"]   ?? 0);
$status   = trim($_POST["status"]     ?? "");
$remarks  = trim($_POST["remarks"]    ?? "");
$admin_id = intval($_POST["admin_id"] ?? 0);

// ── validation ────────────────────────────────────────────────────────────────
if ($doc_id <= 0 || $admin_id <= 0) {
    echo json_encode(["status" => "error", "message" => "Invalid document or admin ID."]);
    exit;
}

$allowed = ["approved", "rejected", "pending"];
if (!in_array($status, $allowed, true)) {
    echo json_encode(["status" => "error", "message" => "Invalid status value."]);
    exit;
}

// ── confirm admin role ────────────────────────────────────────────────────────
$chk = $conn->prepare("SELECT role FROM USERS WHERE id = ? LIMIT 1");
$chk->bind_param("i", $admin_id);
$chk->execute();
$chk->bind_result($role);
$chk->fetch();
$chk->close();

if ($role !== "admin") {
    echo json_encode(["status" => "error", "message" => "Unauthorized."]);
    exit;
}

// ── update document ───────────────────────────────────────────────────────────
$conn->begin_transaction();
try {
    $reviewed_at = date("Y-m-d H:i:s");

    $stmt = $conn->prepare("
        UPDATE DOCUMENTS
        SET status      = ?,
            remarks     = ?,
            reviewed_by = ?,
            reviewed_at = ?
        WHERE id = ?
    ");
    $stmt->bind_param("ssisi", $status, $remarks, $admin_id, $reviewed_at, $doc_id);
    $stmt->execute();
    $stmt->close();

    // Log the action
    $action = "document_" . $status;
    $log = $conn->prepare("
        INSERT INTO ADMIN_LOGS (admin_id, action, target_type, target_id, notes)
        VALUES (?, ?, 'document', ?, ?)
    ");
    $log->bind_param("isis", $admin_id, $action, $doc_id, $remarks);
    $log->execute();
    $log->close();

    $conn->commit();

    $msg = $status === "approved"
        ? "Document approved successfully."
        : ($status === "rejected" ? "Document rejected." : "Document set to pending.");

    echo json_encode(["status" => "success", "message" => $msg]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => "Update failed. Please try again."]);
}

$conn->close();
?>