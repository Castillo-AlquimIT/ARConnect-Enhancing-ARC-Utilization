<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$action    = trim($_POST["action"]    ?? "");
$target_id = intval($_POST["target_id"] ?? 0);
$admin_id  = intval($_POST["admin_id"]  ?? 0);

// ── validation ────────────────────────────────────────────────────────────────
if (empty($action) || $target_id <= 0 || $admin_id <= 0) {
    echo json_encode(["status" => "error", "message" => "Missing required fields."]);
    exit;
}

$allowed_actions = ["delete_user", "delete_child", "delete_document"];
if (!in_array($action, $allowed_actions, true)) {
    echo json_encode(["status" => "error", "message" => "Invalid action."]);
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

// ── prevent admin self-delete ─────────────────────────────────────────────────
if ($action === "delete_user" && $target_id === $admin_id) {
    echo json_encode(["status" => "error", "message" => "You cannot delete your own account."]);
    exit;
}

// ── execute action ────────────────────────────────────────────────────────────
$conn->begin_transaction();
try {
    switch ($action) {

        case "delete_user":
            // Cascades to SOLO_PARENT_PROFILE, CHILDREN, DOCUMENTS via FK
            $stmt = $conn->prepare("DELETE FROM USERS WHERE id = ? AND role = 'user'");
            $stmt->bind_param("i", $target_id);
            $stmt->execute();

            if ($stmt->affected_rows === 0) {
                throw new Exception("User not found or is an admin.");
            }
            $stmt->close();

            $msg         = "User and all related data deleted successfully.";
            $target_type = "user";
            break;

        case "delete_child":
            $stmt = $conn->prepare("DELETE FROM CHILDREN WHERE id = ?");
            $stmt->bind_param("i", $target_id);
            $stmt->execute();

            if ($stmt->affected_rows === 0) {
                throw new Exception("Child record not found.");
            }
            $stmt->close();

            $msg         = "Child record deleted successfully.";
            $target_type = "child";
            break;

        case "delete_document":
            // Fetch file path first so we can remove the file
            $f = $conn->prepare("SELECT file_path FROM DOCUMENTS WHERE id = ?");
            $f->bind_param("i", $target_id);
            $f->execute();
            $f->bind_result($file_path);
            $f->fetch();
            $f->close();

            $stmt = $conn->prepare("DELETE FROM DOCUMENTS WHERE id = ?");
            $stmt->bind_param("i", $target_id);
            $stmt->execute();

            if ($stmt->affected_rows === 0) {
                throw new Exception("Document not found.");
            }
            $stmt->close();

            // Attempt to remove the physical file (non-fatal if missing)
            if (!empty($file_path) && file_exists($file_path)) {
                @unlink($file_path);
            }

            $msg         = "Document deleted successfully.";
            $target_type = "document";
            break;

        default:
            throw new Exception("Unhandled action.");
    }

    // Log the action
    $log = $conn->prepare("
        INSERT INTO ADMIN_LOGS (admin_id, action, target_type, target_id)
        VALUES (?, ?, ?, ?)
    ");
    $log->bind_param("isis", $admin_id, $action, $target_type, $target_id);
    $log->execute();
    $log->close();

    $conn->commit();
    echo json_encode(["status" => "success", "message" => $msg]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}

$conn->close();
?>