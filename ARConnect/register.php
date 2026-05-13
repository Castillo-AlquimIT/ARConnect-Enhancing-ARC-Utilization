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

    $num_id   = $_POST['num_id']   ?? '';
    $first    = $_POST['name']     ?? '';   // Flutter sends 'name' for first name
    $middle   = $_POST['middle']   ?? '';   // optional
    $last     = $_POST['last']     ?? '';
    $suffix   = $_POST['suffix']   ?? '';   // optional
    $password = $_POST['password'] ?? '';

    // Required fields (middle and suffix are optional)
    if (empty($num_id) || empty($first) || empty($last) || empty($password)) {
        echo json_encode([
            "status"  => "error",
            "message" => "All required fields must be filled"
        ]);
        exit;
    }

    // Check if ID already exists
    $check = $conn->prepare("SELECT u_id FROM users WHERE u_num_id = ?");

    if (!$check) {
        throw new Exception($conn->error);
    }

    $check->bind_param("s", $num_id);
    $check->execute();

    $result = $check->get_result();

    if ($result->num_rows > 0) {
        echo json_encode([
            "status"  => "error",
            "message" => "ID already registered"
        ]);

    } else {

        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

        $insert = $conn->prepare("
            INSERT INTO users
                (u_num_id, u_first, u_middle, u_last, u_suffix, u_password)
            VALUES
                (?, ?, ?, ?, ?, ?)
        ");

        if (!$insert) {
            throw new Exception($conn->error);
        }

        $insert->bind_param(
            "ssssss",
            $num_id,
            $first,
            $middle,
            $last,
            $suffix,
            $hashedPassword
        );

        if ($insert->execute()) {

            $_SESSION['user']    = $num_id;
            $_SESSION['user_id'] = $conn->insert_id;

            echo json_encode([
                "status"  => "success",
                "message" => "Registration successful"
            ]);

        } else {
            echo json_encode([
                "status"  => "error",
                "message" => "Failed to register"
            ]);
        }
    }

} catch (Throwable $e) {
    echo json_encode([
        "status"  => "error",
        "message" => $e->getMessage()
    ]);
}
?>