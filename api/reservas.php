<?php
// Mostrar errores de PHP (temporal para debug)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Cabeceras CORS y JSON
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Conexión a la base de datos
$conn = new mysqli("localhost", "root", "", "alquiler_vehiculos");
if ($conn->connect_error) {
    echo json_encode(["error" => "Error al conectar a la DB: " . $conn->connect_error]);
    exit;
}

$method = $_SERVER["REQUEST_METHOD"];

// -----------------------------
// LISTAR RESERVAS
// -----------------------------
if ($method === "GET") {
    $result = $conn->query("
        SELECT r.*, m.nombre_modelo, v.placa, r.observaciones
        FROM Reservas r
        LEFT JOIN Vehiculo v ON r.placa = v.placa
        LEFT JOIN Modelo m ON v.id_modelo = m.id_modelo
    ");

    if (!$result) {
        echo json_encode(["error" => $conn->error]);
        exit;
    }

    $data = [];
    while ($row = $result->fetch_assoc()) $data[] = $row;
    echo json_encode($data);
    exit;
}

// -----------------------------
// CREAR RESERVA SIN USUARIO
// -----------------------------
if ($method === "POST") {
    $input = json_decode(file_get_contents("php://input"), true);

    if (!$input) {
        echo json_encode(["error" => "JSON inválido"]);
        exit;
    }

    // Validar campos obligatorios
    if (empty($input["fecha_inicio"]) || empty($input["fecha_fin"]) || empty($input["placa"])) {
        echo json_encode(["error" => "Faltan datos obligatorios"]);
        exit;
    }

    // Limpiar datos
    $placa = $conn->real_escape_string($input["placa"]);
    $fecha_inicio = $conn->real_escape_string($input["fecha_inicio"]);
    $fecha_fin = $conn->real_escape_string($input["fecha_fin"]);
    $observaciones = isset($input["observaciones"]) ? $conn->real_escape_string($input["observaciones"]) : "";

    // Verificar que el vehículo exista
    $resVeh = $conn->query("SELECT * FROM Vehiculo WHERE placa = '$placa'");
    if (!$resVeh) {
        echo json_encode(["error" => $conn->error]);
        exit;
    }
    if ($resVeh->num_rows === 0) {
        echo json_encode(["error" => "Vehículo no existe"]);
        exit;
    }

    // Insertar la reserva sin id_usuario
    try {
        $stmt = $conn->prepare("
            INSERT INTO Reservas 
            (fecha_inicio, fecha_fin, observaciones, placa, estado)
            VALUES (?, ?, ?, ?, 'Pendiente')
        ");

        if (!$stmt) throw new Exception("Error al preparar la consulta: " . $conn->error);

        $stmt->bind_param("ssss", $fecha_inicio, $fecha_fin, $observaciones, $placa);

        if ($stmt->execute()) {
            echo json_encode([
                "success" => true,
                "id_reserva" => $stmt->insert_id
            ]);
        } else {
            throw new Exception($stmt->error);
        }
    } catch (Exception $e) {
        echo json_encode(["error" => $e->getMessage()]);
    }
    exit;
}

// -----------------------------
// MÉTODO NO SOPORTADO
// -----------------------------
http_response_code(405);
echo json_encode(["error" => "Método no soportado"]);
exit;
?>
