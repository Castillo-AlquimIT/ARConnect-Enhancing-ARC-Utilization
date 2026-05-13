<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$email    = trim($_POST["email"]    ?? "");
$password = $_POST["password"] ?? "";

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Email and password are required."]);
    exit;
}

$stmt = $conn->prepare("
    SELECT u.id, u.f_name, u.l_name, u.email, u.password, u.role,
           p.verification_status
    FROM   USERS u
    LEFT JOIN SOLO_PARENT_PROFILE p ON p.user_id = u.id
    WHERE  u.email = ?
    LIMIT  1
");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Invalid email or password."]);
    exit;
}

$user = $result->fetch_assoc();

if (!password_verify($password, $user["password"])) {
    echo json_encode(["status" => "error", "message" => "Invalid email or password."]);
    exit;
}

echo json_encode([
    "status"  => "success",
    "message" => "Login successful.",
    "user"    => [
        "id"                  => $user["id"],
        "f_name"              => $user["f_name"],
        "l_name"              => $user["l_name"],
        "email"               => $user["email"],
        "role"                => $user["role"],
        "verification_status" => $user["verification_status"] ?? "pending",
    ],
]);

$stmt->close();
$conn->close();
?>