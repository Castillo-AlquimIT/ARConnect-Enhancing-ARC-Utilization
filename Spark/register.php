<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php"; // $conn = mysqli connection

// ── collect & sanitize ────────────────────────────────────────────────────────
$f_name           = trim($_POST["f_name"]           ?? "");
$m_name           = trim($_POST["m_name"]           ?? "");
$l_name           = trim($_POST["l_name"]           ?? "");
$suffix           = trim($_POST["suffix"]           ?? "");
$occupation       = trim($_POST["occupation"]       ?? "");
$email            = trim($_POST["email"]            ?? "");
$password         = $_POST["password"]              ?? "";
$solo_parent_type = trim($_POST["solo_parent_type"] ?? "");
$civil_status     = trim($_POST["civil_status"]     ?? "");
$barangay         = trim($_POST["barangay"]         ?? "");
$city             = trim($_POST["city"]             ?? "");
$province         = trim($_POST["province"]         ?? "");

// ── server-side validation ────────────────────────────────────────────────────
$required = compact("f_name", "l_name", "email", "password",
                    "solo_parent_type", "civil_status",
                    "barangay", "city", "province");

foreach ($required as $key => $val) {
    if (empty($val)) {
        echo json_encode([
            "status"  => "error",
            "message" => "Missing required field: $key",
        ]);
        exit;
    }
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["status" => "error", "message" => "Invalid email address."]);
    exit;
}

if (strlen($password) < 8) {
    echo json_encode(["status" => "error", "message" => "Password must be at least 8 characters."]);
    exit;
}

$allowed_types = [
    "unmarried", "separated", "annulled", "widowed",
    "spouse_detained", "spouse_disabled", "spouse_mia",
];
$allowed_statuses = ["single", "married", "separated", "widowed", "annulled"];

if (!in_array($solo_parent_type, $allowed_types, true)) {
    echo json_encode(["status" => "error", "message" => "Invalid solo parent type."]);
    exit;
}

if (!in_array($civil_status, $allowed_statuses, true)) {
    echo json_encode(["status" => "error", "message" => "Invalid civil status."]);
    exit;
}

// ── check duplicate email ─────────────────────────────────────────────────────
$check = $conn->prepare("SELECT id FROM USERS WHERE email = ? LIMIT 1");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Email is already registered."]);
    $check->close();
    exit;
}
$check->close();

// ── hash password ─────────────────────────────────────────────────────────────
$hashed = password_hash($password, PASSWORD_BCRYPT);

// ── insert within a transaction ───────────────────────────────────────────────
$conn->begin_transaction();

try {
    // 1. USERS
    $u = $conn->prepare("
        INSERT INTO USERS (f_name, m_name, l_name, suffix, occupation, email, password)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    $u->bind_param("sssssss",
        $f_name, $m_name, $l_name, $suffix, $occupation, $email, $hashed);
    $u->execute();
    $user_id = $conn->insert_id;
    $u->close();

    // 2. SOLO_PARENT_PROFILE
    $p = $conn->prepare("
        INSERT INTO SOLO_PARENT_PROFILE
            (user_id, solo_parent_type, civil_status, barangay, city, province)
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    $p->bind_param("isssss",
        $user_id, $solo_parent_type, $civil_status, $barangay, $city, $province);
    $p->execute();
    $p->close();

    $conn->commit();

    echo json_encode([
        "status"  => "success",
        "message" => "Registration successful! Your account is pending verification.",
        "user"    => [
            "id"                  => $user_id,
            "f_name"              => $f_name,
            "email"               => $email,
            "verification_status" => "pending",
        ],
    ]);

} catch (Exception $e) {
    $conn->rollback();
    echo json_encode([
        "status"  => "error",
        "message" => "Registration failed. Please try again.",
    ]);
}

$conn->close();
?>