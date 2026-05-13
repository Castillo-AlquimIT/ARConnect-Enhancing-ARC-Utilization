<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
error_reporting(E_ALL);
ini_set('display_errors', 0);

session_start();
include "db.php";

$action = $_POST['action'] ?? $_GET['action'] ?? '';

try {

    switch ($action) {

        // ─────────────────────────────────────────
        // GET QUEUE STATUS — called on page load
        // Returns the user's active ticket if any
        // ─────────────────────────────────────────
        case 'get_ticket':

            $user_id = $_POST['user_id'] ?? $_GET['user_id'] ?? '';

            if (empty($user_id)) {
                echo json_encode(["status" => "error", "message" => "user_id required"]);
                exit;
            }

            $stmt = $conn->prepare("
                SELECT q_id, q_ticket_no, q_status, q_issued_at
                FROM borrow_queue
                WHERE q_user_id = ?
                  AND q_status IN ('in queue', 'being served')
                ORDER BY q_issued_at DESC
                LIMIT 1
            ");

            if (!$stmt) throw new Exception($conn->error);

            $stmt->bind_param("i", $user_id);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows > 0) {
                $row = $result->fetch_assoc();

                // Count how many tickets are ahead in the queue
                $ahead = $conn->prepare("
                    SELECT COUNT(*) AS ahead
                    FROM borrow_queue
                    WHERE q_status = 'in queue'
                      AND q_issued_at < ?
                ");
                $ahead->bind_param("s", $row['q_issued_at']);
                $ahead->execute();
                $aheadRow   = $ahead->get_result()->fetch_assoc();
                $waitMinutes = ($aheadRow['ahead'] ?? 0) * 5; // estimate 5 min per person

                echo json_encode([
                    "status"  => "success",
                    "ticket"  => [
                        "id"        => $row['q_id'],
                        "number"    => $row['q_ticket_no'],
                        "status"    => $row['q_status'],
                        "est_wait"  => $waitMinutes > 0 ? "{$waitMinutes} min" : "Your turn soon",
                        "issued_at" => $row['q_issued_at'],
                    ]
                ]);
            } else {
                echo json_encode([
                    "status"  => "success",
                    "ticket"  => null  // no active ticket
                ]);
            }

            break;

        // ─────────────────────────────────────────
        // ISSUE TICKET — user joins the queue
        // ─────────────────────────────────────────
        case 'issue_ticket':

            $user_id = $_POST['user_id'] ?? '';

            if (empty($user_id)) {
                echo json_encode(["status" => "error", "message" => "user_id required"]);
                exit;
            }

            // Check if user already has an active ticket
            $check = $conn->prepare("
                SELECT q_id FROM borrow_queue
                WHERE q_user_id = ?
                  AND q_status IN ('in queue', 'being served')
            ");

            if (!$check) throw new Exception($conn->error);

            $check->bind_param("i", $user_id);
            $check->execute();

            if ($check->get_result()->num_rows > 0) {
                echo json_encode([
                    "status"  => "error",
                    "message" => "You already have an active ticket"
                ]);
                exit;
            }

            // Generate next ticket number (01–99, resets daily)
            $today = date('Y-m-d');

            $lastTicket = $conn->prepare("
                SELECT q_ticket_no FROM borrow_queue
                WHERE DATE(q_issued_at) = ?
                ORDER BY q_id DESC
                LIMIT 1
            ");

            $lastTicket->bind_param("s", $today);
            $lastTicket->execute();
            $lastRow    = $lastTicket->get_result()->fetch_assoc();
            $nextNumber = $lastRow ? (intval($lastRow['q_ticket_no']) % 99) + 1 : 1;
            $ticketNo   = str_pad($nextNumber, 2, '0', STR_PAD_LEFT);

            // Insert ticket
            $insert = $conn->prepare("
                INSERT INTO borrow_queue (q_user_id, q_ticket_no, q_status)
                VALUES (?, ?, 'in queue')
            ");

            if (!$insert) throw new Exception($conn->error);

            $insert->bind_param("is", $user_id, $ticketNo);

            if ($insert->execute()) {

                // Count ahead for estimated wait
                $queuePos    = $conn->query("SELECT COUNT(*) AS total FROM borrow_queue WHERE q_status = 'in queue'")->fetch_assoc();
                $waitMinutes = max(0, (($queuePos['total'] ?? 1) - 1) * 5);

                echo json_encode([
                    "status"  => "success",
                    "message" => "Ticket issued",
                    "ticket"  => [
                        "id"       => $conn->insert_id,
                        "number"   => $ticketNo,
                        "status"   => "in queue",
                        "est_wait" => $waitMinutes > 0 ? "{$waitMinutes} min" : "Your turn soon",
                    ]
                ]);

            } else {
                echo json_encode(["status" => "error", "message" => "Failed to issue ticket"]);
            }

            break;

        // ─────────────────────────────────────────
        // CANCEL TICKET — user leaves the queue
        // ─────────────────────────────────────────
        case 'cancel_ticket':

            $user_id   = $_POST['user_id']   ?? '';
            $ticket_id = $_POST['ticket_id'] ?? '';

            if (empty($user_id) || empty($ticket_id)) {
                echo json_encode(["status" => "error", "message" => "user_id and ticket_id required"]);
                exit;
            }

            $stmt = $conn->prepare("
                UPDATE borrow_queue
                SET q_status = 'cancelled'
                WHERE q_id = ?
                  AND q_user_id = ?
                  AND q_status IN ('in queue', 'being served')
            ");

            if (!$stmt) throw new Exception($conn->error);

            $stmt->bind_param("ii", $ticket_id, $user_id);
            $stmt->execute();

            if ($stmt->affected_rows > 0) {
                echo json_encode(["status" => "success", "message" => "Ticket cancelled"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Ticket not found or already resolved"]);
            }

            break;

        default:
            echo json_encode(["status" => "error", "message" => "Unknown action"]);
            break;
    }

} catch (Throwable $e) {
    echo json_encode([
        "status"  => "error",
        "message" => $e->getMessage()
    ]);
}
?>
