<?php
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Credentials: true");

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

// Función para ejecutar statement y manejar errores
function ejecutar_stmt($stmt){
    if (!$stmt->execute()) {
        echo json_encode(["error" => $stmt->error]);
        exit;
    }
    return true;
}

// -----------------------------
// LISTAR VEHÍCULOS
// -----------------------------
if ($method === "GET") {
    $result = $conn->query("
        SELECT v.*, m.nombre_modelo, s.nombre_compania
        FROM Vehiculo v
        LEFT JOIN Modelo m ON v.id_modelo = m.id_modelo
        LEFT JOIN Seguro s ON v.id_seguro = s.id_seguro
    ");
    $data = [];
    while ($row = $result->fetch_assoc()) $data[] = $row;
    echo json_encode($data);
    exit;
}

// -----------------------------
// RECIBIR DATOS JSON
// -----------------------------
$input = json_decode(file_get_contents("php://input"), true);
if (($method === "POST" || $method === "PUT") && !$input) {
    echo json_encode(["error" => "JSON inválido o vacío"]);
    exit;
}

// -----------------------------
// CREAR VEHÍCULO
// -----------------------------
if ($method === "POST") {
    $stmt = $conn->prepare("
        INSERT INTO Vehiculo 
        (placa, color, `año`, precio_dia, estado, kilometraje, id_modelo, id_seguro, descripcion, imagen_principal, destacado, es_afiliado, calificacion_promedio, numero_reseñas, comision_afiliado)
        VALUES (?, ?, ?, ?, 'Disponible', ?, ?, ?, ?, ?, 0, 0, 0, 0, ?)
    ");

    $stmt->bind_param(
        "ssdiissssd",
        $input["placa"],            // s = string
        $input["color"],            // s = string
        $input["año"],              // i = int
        $input["precio_dia"],       // d = decimal
        $input["kilometraje"],      // i = int
        $input["id_modelo"],        // s = varchar
        $input["id_seguro"],        // s = varchar
        $input["descripcion"],      // s = string
        $input["imagen_principal"], // s = string
        $input["comision_afiliado"] // d = decimal
    );

    ejecutar_stmt($stmt);
    echo json_encode(["success" => true]);
    exit;
}

// -----------------------------
// ACTUALIZAR VEHÍCULO
// -----------------------------
if ($method === "PUT") {
    $stmt = $conn->prepare("
        UPDATE Vehiculo SET 
            color=?, `año`=?, precio_dia=?, kilometraje=?, id_modelo=?, id_seguro=?, descripcion=?, imagen_principal=?, comision_afiliado=?
        WHERE placa=?
    ");

    // Tipos corregidos: s = string, i = int, d = double
    $stmt->bind_param(
        "sidisssdss",
        $input["color"],            // s
        $input["año"],              // i
        $input["precio_dia"],       // d
        $input["kilometraje"],      // i
        $input["id_modelo"],        // s
        $input["id_seguro"],        // s
        $input["descripcion"],      // s
        $input["imagen_principal"], // s
        $input["comision_afiliado"],// d
        $input["placa"]             // s
    );

    ejecutar_stmt($stmt);
    echo json_encode(["success" => true]);
    exit;
}

// -----------------------------
// ELIMINAR VEHÍCULO
// -----------------------------
if ($method === "DELETE") {
    if (!isset($_GET["placa"])) {
        echo json_encode(["error" => "Placa no especificada"]);
        exit;
    }

    $placa = $conn->real_escape_string($_GET["placa"]);

    // Verificar si hay reservas
    $res = $conn->query("SELECT COUNT(*) AS total FROM Reservas WHERE placa='$placa'");
    $row = $res->fetch_assoc();
    if ($row["total"] > 0) {
        echo json_encode(["error" => "No se puede eliminar el vehículo porque tiene reservas asociadas"]);
        exit;
    }

    $res = $conn->query("DELETE FROM Vehiculo WHERE placa='$placa'");
    if (!$res) {
        echo json_encode(["error" => $conn->error]);
        exit;
    }

    echo json_encode(["success" => true]);
    exit;
}

// -----------------------------
// MÉTODO NO SOPORTADO
// -----------------------------
http_response_code(405);
echo json_encode(["error" => "Método no soportado"]);
exit;
?>
