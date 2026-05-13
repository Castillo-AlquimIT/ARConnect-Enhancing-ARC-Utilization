<?php
// Database configuration
$servername = "localhost";   // or your server IP
$username   = "root";        // your MySQL username
$password   = "";            // your MySQL password
$dbname     = "sparkdb";    // your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode([
        "status"  => "error",
        "message" => "Connection failed: " . $conn->connect_error
    ]));
}
?>