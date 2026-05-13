<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
error_reporting(E_ALL);
ini_set('display_errors', 0);

session_start();
include "db.php";

try {

    $name     = $_POST['name']     ?? '';
    $email    = $_POST['email']    ?? '';   // optional
    $rating   = $_POST['rating']   ?? '';
    $message  = $_POST['feedback'] ?? '';

    if (empty($name) || empty($message)) {
        echo json_encode([
            "status"  => "error",
            "message" => "Name and feedback are required"
        ]);
        exit;
    }

    if (!empty($rating) && (!is_numeric($rating) || $rating < 1 || $rating > 5)) {
        echo json_encode([
            "status"  => "error",
            "message" => "Rating must be between 1 and 5"
        ]);
        exit;
    }

    // Link to logged-in user if session exists
    $user_id = $_SESSION['user_id'] ?? null;

    $stmt = $conn->prepare("
        INSERT INTO feedback
            (f_user_id, f_name, f_email, f_rate, f_message)
        VALUES
            (?, ?, ?, ?, ?)
    ");

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param("issis", $user_id, $name, $email, $rating, $message);

    if ($stmt->execute()) {
        echo json_encode([
            "status"  => "success",
            "message" => "Feedback submitted successfully"
        ]);
    } else {
        echo json_encode([
            "status"  => "error",
            "message" => "Failed to save feedback"
        ]);
    }

    $stmt->close();

} catch (Throwable $e) {
    echo json_encode([
        "status"  => "error",
        "message" => $e->getMessage()
    ]);
}
?>