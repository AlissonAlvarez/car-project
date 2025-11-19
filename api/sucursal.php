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
// GET — LISTAR SUCURSALES
// ===========================================
if ($method === "GET") {
    $result = $conn->query("SELECT * FROM Sucursal ORDER BY nombre_sucursal ASC");
    $data = [];
    while ($row = $result->fetch_assoc()) $data[] = $row;
    echo json_encode($data);
    exit;
}

// ===========================================
// POST — CREAR O ACTUALIZAR SUCURSAL
// ===========================================
if ($method === "POST") {
    $accion = $_POST["accion"] ?? "";

    $id_sucursal = $_POST["id_sucursal"] ?? "";
    $nombre_sucursal = $_POST["nombre_sucursal"] ?? "";
    $direccion = $_POST["direccion"] ?? "";
    $ciudad = $_POST["ciudad"] ?? "";
    $telefono = $_POST["telefono"] ?? "";
    $email = $_POST["email"] ?? "";
    $horario = $_POST["horario"] ?? "";

    // ===========================
    // ACTUALIZAR
    // ===========================
    if ($accion === "actualizar") {
        $stmt = $conn->prepare("
            UPDATE Sucursal SET 
                nombre_sucursal=?, direccion=?, ciudad=?, telefono=?, email=?, horario=?
            WHERE id_sucursal=?
        ");

        $stmt->bind_param(
            "sssssss",
            $nombre_sucursal,
            $direccion,
            $ciudad,
            $telefono,
            $email,
            $horario,
            $id_sucursal
        );

        ejecutar_stmt($stmt);
        echo json_encode(["success" => true, "msg" => "Sucursal actualizada"]);
        exit;
    }

    // ===========================
    // CREAR
    // ===========================
    $stmt = $conn->prepare("
        INSERT INTO Sucursal (id_sucursal, nombre_sucursal, direccion, ciudad, telefono, email, horario)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");

    $stmt->bind_param(
        "sssssss",
        $id_sucursal,
        $nombre_sucursal,
        $direccion,
        $ciudad,
        $telefono,
        $email,
        $horario
    );

    ejecutar_stmt($stmt);
    echo json_encode(["success" => true, "msg" => "Sucursal creada"]);
    exit;
}

// ===========================================
// DELETE — ELIMINAR SUCURSAL
// ===========================================
if ($method === "DELETE") {

    if (!isset($_GET["id_sucursal"])) {
        echo json_encode(["error" => "ID de sucursal no especificado"]);
        exit;
    }

    $id_sucursal = $_GET["id_sucursal"];

    $stmt = $conn->prepare("DELETE FROM Sucursal WHERE id_sucursal=?");
    $stmt->bind_param("s", $id_sucursal);

    ejecutar_stmt($stmt);

    echo json_encode(["success" => true, "msg" => "Sucursal eliminada"]);
    exit;
}

// ===========================================
// MÉTODO NO SOPORTADO
// ===========================================
http_response_code(405);
echo json_encode(["error" => "Método no soportado"]);
exit;

?>
