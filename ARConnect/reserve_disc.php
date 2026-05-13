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

    $user_id    = $_POST['user_id']    ?? '';
    $room       = $_POST['room']       ?? '';
    $date       = $_POST['date']       ?? '';
    $time_start = $_POST['time_start'] ?? '';
    $time_end   = $_POST['time_end']   ?? '';

    // Required field check
    if (empty($user_id) || empty($room) || empty($date) || empty($time_start) || empty($time_end)) {
        echo json_encode([
            "status"  => "error",
            "message" => "All fields are required"
        ]);
        exit;
    }

    // Validate date is not in the past
    if ($date < date('Y-m-d')) {
        echo json_encode([
            "status"  => "error",
            "message" => "Cannot book a date in the past"
        ]);
        exit;
    }

    // Check if the user already has a pending/approved booking on the same date
    $userCheck = $conn->prepare("
        SELECT r_id FROM reserve_disc
        WHERE r_user_id = ?
          AND r_date = ?
          AND r_status IN ('pending', 'approved')
    ");

    if (!$userCheck) throw new Exception($conn->error);

    $userCheck->bind_param("is", $user_id, $date);
    $userCheck->execute();

    if ($userCheck->get_result()->num_rows > 0) {
        echo json_encode([
            "status"  => "error",
            "message" => "You already have a booking on this date"
        ]);
        exit;
    }

    // Check if the room + time slot is already taken
    $slotCheck = $conn->prepare("
        SELECT r_id FROM reserve_disc
        WHERE r_room = ?
          AND r_date = ?
          AND r_status IN ('pending', 'approved')
          AND NOT (r_time_end <= ? OR r_time_start >= ?)
    ");

    if (!$slotCheck) throw new Exception($conn->error);

    $slotCheck->bind_param("ssss", $room, $date, $time_start, $time_end);
    $slotCheck->execute();

    if ($slotCheck->get_result()->num_rows > 0) {
        echo json_encode([
            "status"  => "error",
            "message" => "This room and time slot is already booked"
        ]);
        exit;
    }

    // Insert the reservation
    $insert = $conn->prepare("
        INSERT INTO reserve_disc
            (r_user_id, r_room, r_date, r_time_start, r_time_end, r_status)
        VALUES
            (?, ?, ?, ?, ?, 'pending')
    ");

    if (!$insert) throw new Exception($conn->error);

    $insert->bind_param("issss", $user_id, $room, $date, $time_start, $time_end);

    if ($insert->execute()) {
        echo json_encode([
            "status"     => "success",
            "message"    => "Room booked successfully",
            "booking_id" => $conn->insert_id
        ]);
    } else {
        echo json_encode([
            "status"  => "error",
            "message" => "Failed to save booking"
        ]);
    }

} catch (Throwable $e) {
    echo json_encode([
        "status"  => "error",
        "message" => $e->getMessage()
    ]);
}
?>