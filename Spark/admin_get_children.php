<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$result = $conn->query("
    SELECT
        c.id, c.user_id, c.f_name, c.m_name, c.l_name,
        c.birthdate, c.sex, c.school, c.grade_level,
        c.with_disability, c.disability_details,
        c.created_at,
        u.f_name  AS parent_f_name,
        u.l_name  AS parent_l_name,
        u.email   AS parent_email
    FROM CHILDREN c
    JOIN USERS u ON u.id = c.user_id
    ORDER BY u.l_name, u.f_name, c.birthdate DESC
");

if (!$result) {
    echo json_encode(["status" => "error", "message" => "Query failed."]);
    exit;
}

$children = [];
while ($row = $result->fetch_assoc()) {
    $row["with_disability"] = (string) $row["with_disability"]; // normalize for Flutter
    $children[] = $row;
}

echo json_encode([
    "status"   => "success",
    "count"    => count($children),
    "children" => $children,
]);

$conn->close();
?>