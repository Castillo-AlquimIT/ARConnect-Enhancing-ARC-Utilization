<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$user_id          = intval($_POST["user_id"]           ?? 0);
$status           = trim($_POST["status"]              ?? "");
$rejection_reason = trim($_POST["rejection_reason"]    ?? "");
$admin_id         = intval($_POST["admin_id"]          ?? 0);

// ── validation ────────────────────────────────────────────────────────────────
if ($user_id <= 0 || $admin_id <= 0) {
    echo json_encode(["status" => "error", "message" => "Invalid user or admin ID."]);
    exit;
}

$allowed = ["verified", "rejected", "pending"];
if (!in_array($status, $allowed, true)) {
    echo json_encode(["status" => "error", "message" => "Invalid status value."]);
    exit;
}

if ($status === "rejected" && empty($rejection_reason)) {
    echo json_encode(["status" => "error", "message" => "Rejection reason is required."]);
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

// ── update profile ────────────────────────────────────────────────────────────
$conn->begin_transaction();
try {
    $verified_at = $status === "verified" ? date("Y-m-d H:i:s") : null;
    $reason      = $status === "rejected" ? $rejection_reason : null;
    $verified_by = $status === "verified" ? $admin_id : null;

    $stmt = $conn->prepare("
        UPDATE SOLO_PARENT_PROFILE
        SET verification_status = ?,
            rejection_reason    = ?,
            verified_at         = ?,
            verified_by         = ?,
            updated_at          = NOW()
        WHERE user_id = ?
    ");
    $stmt->bind_param("sssii", $status, $reason, $verified_at, $verified_by, $user_id);
    $stmt->execute();
    $stmt->close();

    // Log the action
    $action = "set_verification_" . $status;
    $log = $conn->prepare("
        INSERT INTO ADMIN_LOGS (admin_id, action, target_type, target_id, notes)
        VALUES (?, ?, 'user', ?, ?)
    ");
    $log->bind_param("isis", $admin_id, $action, $user_id, $reason);
    $log->execute();
    $log->close();

    $conn->commit();

    $msg = match($status) {
        "verified" => "User has been verified successfully.",
        "rejected" => "User has been rejected.",
        default    => "Status updated to pending.",
    };

    echo json_encode(["status" => "success", "message" => $msg]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => "Update failed. Please try again."]);
}

$conn->close();
?>