<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$result = $conn->query("
    SELECT
        u.id, u.email, u.f_name, u.m_name, u.l_name, u.suffix,
        u.occupation, u.role, u.created_at,
        p.solo_parent_type, p.civil_status,
        p.solo_parent_id_no, p.id_issued_date, p.id_expiry_date,
        p.barangay, p.city, p.province,
        p.verification_status, p.rejection_reason,
        p.verified_at
    FROM USERS u
    LEFT JOIN SOLO_PARENT_PROFILE p ON p.user_id = u.id
    WHERE u.role = 'user'
    ORDER BY
        FIELD(p.verification_status, 'pending', 'rejected', 'verified'),
        u.created_at DESC
");

if (!$result) {
    echo json_encode(["status" => "error", "message" => "Query failed."]);
    exit;
}

$users = [];
while ($row = $result->fetch_assoc()) {
    $users[] = $row;
}

echo json_encode([
    "status" => "success",
    "count"  => count($users),
    "users"  => $users,
]);

$conn->close();
?>