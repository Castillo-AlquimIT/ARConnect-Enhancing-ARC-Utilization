<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 0);

session_start();

if (!isset($_SESSION['user']) || !isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode([
        "status"  => "error",
        "message" => "Unauthorized"
    ]);
    exit;
}

include "db.php";

try {

    $user_id = $_SESSION['user_id'];

    $stmt = $conn->prepare("
        SELECT u_id, u_num_id, u_first, u_middle, u_last, u_suffix, u_email, u_role
        FROM users
        WHERE u_id = ?
    ");

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param("i", $user_id);
    $stmt->execute();

    $result = $stmt->get_result();

    if ($result->num_rows > 0) {

        $row = $result->fetch_assoc();

        echo json_encode([
            "status" => "success",
            "user"   => [
                "id"     => $row['u_id'],
                "num_id" => $row['u_num_id'],
                "name"   => $row['u_first'],
                "middle" => $row['u_middle'],
                "last"   => $row['u_last'],
                "suffix" => $row['u_suffix'],
                "email"  => $row['u_email'],
                "role"   => $row['u_role'],
            ]
        ]);

    } else {
        http_response_code(404);
        echo json_encode([
            "status"  => "error",
            "message" => "User not found"
        ]);
    }

} catch (Throwable $e) {
    echo json_encode([
        "status"  => "error",
        "message" => $e->getMessage()
    ]);
}
?>