<?php
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Conectar MySQL
$conn = new mysqli("localhost", "root", "", "alquiler_vehiculos");
if ($conn->connect_error) {
    echo json_encode(["error" => "Error DB: " . $conn->connect_error]);
    exit;
}

$method = $_SERVER["REQUEST_METHOD"];

/* ============================================
   CREAR RESERVA
   ============================================ */
if ($method === "POST") {
    $input = json_decode(file_get_contents("php://input"), true);

    if (!$input) {
        echo json_encode(["error" => "JSON inválido"]);
        exit;
    }

    // Validar campos obligatorios
    if (
        empty($input["fecha_inicio"]) ||
        empty($input["fecha_fin"]) ||
        empty($input["placa"]) ||
        empty($input["id_sucursal"]) ||
        empty($input["id_usuario"])
    ) {
        echo json_encode(["error" => "Faltan datos obligatorios"]);
        exit;
    }

    // Datos
    $fecha_inicio = $input["fecha_inicio"];
    $fecha_fin = $input["fecha_fin"];
    $observaciones = $input["observaciones"] ?? "";
    $placa = $input["placa"];
    $id_usuario = $input["id_usuario"];
    $id_sucursal = $input["id_sucursal"];

    /* Validar placa */
    $checkVeh = $conn->query("SELECT placa FROM Vehiculo WHERE placa='$placa'");
    if ($checkVeh->num_rows == 0) {
        echo json_encode(["error" => "La placa no existe"]);
        exit;
    }

    /* Validar usuario */
    $checkUser = $conn->query("SELECT id_usuario FROM Usuarios WHERE id_usuario=$id_usuario");
    if ($checkUser->num_rows == 0) {
        echo json_encode(["error" => "El usuario no existe"]);
        exit;
    }

    /* Validar sucursal */
    $checkSuc = $conn->query("SELECT id_sucursal FROM Sucursal WHERE id_sucursal='$id_sucursal'");
    if ($checkSuc->num_rows == 0) {
        echo json_encode(["error" => "La sucursal no existe"]);
        exit;
    }

    // Insertar reserva
    $stmt = $conn->prepare("
        INSERT INTO Reservas 
        (fecha_inicio, fecha_fin, observaciones, placa, id_usuario, id_sucursal, estado)
        VALUES (?, ?, ?, ?, ?, ?, 'Pendiente')
    ");

    $stmt->bind_param(
        "ssssss",
        $fecha_inicio,
        $fecha_fin,
        $observaciones,
        $placa,
        $id_usuario,
        $id_sucursal
    );

    if ($stmt->execute()) {
        echo json_encode([
            "success" => true,
            "id_reserva" => $stmt->insert_id
        ]);
    } else {
        echo json_encode(["error" => $stmt->error]);
    }

    exit;
}

echo json_encode(["error" => "Método no soportado"]);
exit;
?>
