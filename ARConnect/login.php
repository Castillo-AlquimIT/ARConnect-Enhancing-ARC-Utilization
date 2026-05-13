<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 0);

session_start();
include "db.php";

try {

    $num_id   = $_POST['num_id']   ?? '';
    $password = $_POST['password'] ?? '';

    if (empty($num_id) || empty($password)) {
        echo json_encode([
            "status"  => "error",
            "message" => "ID and password required"
        ]);
        exit;
    }

    $stmt = $conn->prepare("
        SELECT u_id, u_num_id, u_first, u_middle, u_last, u_suffix, u_role, u_password
        FROM users
        WHERE u_num_id = ?
    ");

    if (!$stmt) {
        throw new Exception($conn->error);
    }

    $stmt->bind_param("s", $num_id);
    $stmt->execute();

    $result = $stmt->get_result();

    if ($result->num_rows > 0) {

        $row = $result->fetch_assoc();

        if (password_verify($password, $row['u_password'])) {

            $_SESSION['user']    = $row['u_num_id'];
            $_SESSION['user_id'] = $row['u_id'];

            echo json_encode([
                "status"  => "success",
                "message" => "Login successful",
                "user"    => [
                    "id"     => $row['u_id'],
                    "num_id" => $row['u_num_id'],
                    "name"   => $row['u_first'],
                    "middle" => $row['u_middle'],
                    "last"   => $row['u_last'],
                    "suffix" => $row['u_suffix'],
                    "role"   => $row['u_role'],
                ]
            ]);

        } else {
            echo json_encode([
                "status"  => "error",
                "message" => "Invalid password"
            ]);
        }

    } else {
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