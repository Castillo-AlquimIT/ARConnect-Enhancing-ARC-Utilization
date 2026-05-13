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

    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $ms_id = $data['microsoft_id']  ?? '';
    $name  = $data['name']          ?? '';
    $email = $data['email']         ?? '';

    if (empty($ms_id)) {
        echo json_encode(["status" => "error", "message" => "Missing Microsoft ID"]);
        exit;
    }

    // Check if this Microsoft account is already linked
    $check = $conn->prepare("
        SELECT u_id, u_num_id, u_first, u_middle, u_last, u_suffix, u_role
        FROM users
        WHERE u_ms_id = ?
    ");

    if (!$check) {
        throw new Exception($conn->error);
    }

    $check->bind_param("s", $ms_id);
    $check->execute();
    $result = $check->get_result();

    if ($result->num_rows > 0) {

        // Existing user — log them in
        $row = $result->fetch_assoc();

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

        // New Microsoft user — create account
        // u_num_id is set to email prefix as placeholder (can be updated later)
        $num_id_placeholder = strtok($email, '@') ?: $ms_id;

        // Split display name into first/last best-effort
        $parts = explode(' ', trim($name), 2);
        $first = $parts[0] ?? $name;
        $last  = $parts[1] ?? '';

        $insert = $conn->prepare("
            INSERT INTO users
                (u_num_id, u_first, u_last, u_email, u_ms_id)
            VALUES
                (?, ?, ?, ?, ?)
        ");

        if (!$insert) {
            throw new Exception($conn->error);
        }

        $insert->bind_param("sssss", $num_id_placeholder, $first, $last, $email, $ms_id);

        if ($insert->execute()) {

            $new_id = $conn->insert_id;
            $_SESSION['user']    = $num_id_placeholder;
            $_SESSION['user_id'] = $new_id;

            echo json_encode([
                "status"  => "success",
                "message" => "Account created via Microsoft",
                "user"    => [
                    "id"     => $new_id,
                    "num_id" => $num_id_placeholder,
                    "name"   => $first,
                    "last"   => $last,
                    "role"   => "student",
                ]
            ]);

        } else {
            echo json_encode([
                "status"  => "error",
                "message" => "Failed to create account"
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