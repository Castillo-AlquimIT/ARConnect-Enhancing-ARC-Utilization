<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$result = $conn->query("
    SELECT
        d.id, d.user_id, d.document_type, d.file_path,
        d.file_name, d.file_size_kb, d.status,
        d.remarks, d.uploaded_at, d.reviewed_at,
        u.f_name, u.l_name, u.email,
        r.f_name AS reviewer_f_name,
        r.l_name AS reviewer_l_name
    FROM DOCUMENTS d
    JOIN  USERS u ON u.id = d.user_id
    LEFT JOIN USERS r ON r.id = d.reviewed_by
    ORDER BY
        FIELD(d.status, 'pending', 'rejected', 'approved'),
        d.uploaded_at DESC
");

if (!$result) {
    echo json_encode(["status" => "error", "message" => "Query failed."]);
    exit;
}

$docs = [];
while ($row = $result->fetch_assoc()) {
    $docs[] = $row;
}

echo json_encode([
    "status"    => "success",
    "count"     => count($docs),
    "documents" => $docs,
]);

$conn->close();
?>