<?php
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Credentials: true");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ===========================================
// CONEXIÓN DB
// ===========================================
$conn = new mysqli("localhost", "root", "", "alquiler_vehiculos");
if ($conn->connect_error) {
    echo json_encode(["error" => "Error DB: " . $conn->connect_error]);
    exit;
}

$method = $_SERVER["REQUEST_METHOD"];

// ===========================================
// FUNCION PARA EJECUTAR STMT
// ===========================================
function ejecutar_stmt($stmt){
    if (!$stmt->execute()) {
        echo json_encode(["error" => $stmt->error]);
        exit;
    }
    return true;
}

// ===========================================
// GET — LISTAR RESERVAS
// ===========================================
if ($method === "GET") {
    $result = $conn->query("
        SELECT r.*, 
               v.placa, v.color, v.año, v.precio_dia, 
               u.nombres AS nombre_usuario, u.apellidos AS apellido_usuario,
               s.nombre_sucursal
        FROM Reservas r
        LEFT JOIN Vehiculo v ON r.placa = v.placa
        LEFT JOIN Usuarios u ON r.id_usuario = u.id_usuario
        LEFT JOIN Sucursal s ON r.id_sucursal = s.id_sucursal
        ORDER BY r.id_reserva DESC
    ");

    $data = [];
    while ($row = $result->fetch_assoc()) $data[] = $row;

    echo json_encode($data);
    exit;
}

// ===========================================
// POST — CREAR O ACTUALIZAR RESERVA
// ===========================================
if ($method === "POST") {
    $accion = $_POST["accion"] ?? "";

    $id_reserva   = $_POST["id_reserva"] ?? "";
    $id_usuario   = $_POST["id_usuario"] ?? "";
    $placa        = $_POST["placa"] ?? "";
    $id_sucursal  = $_POST["id_sucursal"] ?? "";
    $fecha_inicio = $_POST["fecha_inicio"] ?? "";
    $fecha_fin    = $_POST["fecha_fin"] ?? "";
    $estado       = $_POST["estado"] ?? "Pendiente";
    $observaciones= $_POST["observaciones"] ?? "";

    if (strtotime($fecha_fin) <= strtotime($fecha_inicio)) {
        echo json_encode(["error" => "La fecha final debe ser mayor que la inicial"]);
        exit;
    }

    if ($accion === "actualizar") {
        $stmt = $conn->prepare("
            UPDATE Reservas SET 
                id_usuario=?, placa=?, id_sucursal=?, fecha_inicio=?, fecha_fin=?, estado=?, observaciones=?
            WHERE id_reserva=?
        ");
        $stmt->bind_param(
            "issssssi",
            $id_usuario,
            $placa,
            $id_sucursal,
            $fecha_inicio,
            $fecha_fin,
            $estado,
            $observaciones,
            $id_reserva
        );

        ejecutar_stmt($stmt);
        echo json_encode(["success" => true, "msg" => "Reserva actualizada"]);
        exit;
    }

    // CREAR
    $stmt = $conn->prepare("
        INSERT INTO Reservas (id_usuario, placa, id_sucursal, fecha_inicio, fecha_fin, estado, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->bind_param(
        "issssss",
        $id_usuario,
        $placa,
        $id_sucursal,
        $fecha_inicio,
        $fecha_fin,
        $estado,
        $observaciones
    );

    ejecutar_stmt($stmt);
    echo json_encode(["success" => true, "msg" => "Reserva creada"]);
    exit;
}

// ===========================================
// DELETE — ELIMINAR RESERVA
// ===========================================
if ($method === "DELETE") {

    if (!isset($_GET["id_reserva"])) {
        echo json_encode(["error" => "ID de reserva no especificado"]);
        exit;
    }

    $id_reserva = intval($_GET["id_reserva"]);

    $stmt = $conn->prepare("DELETE FROM Reservas WHERE id_reserva=?");
    $stmt->bind_param("i", $id_reserva);

    ejecutar_stmt($stmt);

    echo json_encode(["success" => true, "msg" => "Reserva eliminada"]);
    exit;
}

// ===========================================
// METODO NO SOPORTADO
// ===========================================
http_response_code(405);
echo json_encode(["error" => "Método no soportado"]);
exit;

?>
