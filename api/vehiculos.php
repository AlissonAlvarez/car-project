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
// POST - CREAR / ACTUALIZAR VEHÍCULO
// -----------------------------
if ($method === "POST") {
    $accion = $_POST['accion'] ?? '';
    $input = $_POST; // datos del formulario
    $imagen = $_FILES['imagen_principal'] ?? null;

    // Manejar la imagen
    $imagen_ruta = ""; 
    if ($imagen && $imagen['error'] === UPLOAD_ERR_OK) {
        $ext = pathinfo($imagen['name'], PATHINFO_EXTENSION);
        $nombreArchivo = uniqid() . "." . $ext;
        $rutaDestino = __DIR__ . "/uploads/vehiculos/" . $nombreArchivo;

        if (!is_dir(__DIR__ . "/uploads/vehiculos")) {
            mkdir(__DIR__ . "/uploads/vehiculos", 0777, true);
        }

        if (move_uploaded_file($imagen['tmp_name'], $rutaDestino)) {
            $imagen_ruta = "api/uploads/vehiculos/" . $nombreArchivo;
        }
    }

    if ($accion === "actualizar") {
        // Usar la imagen existente si no se sube nueva
        $imagen_final = $imagen_ruta ? $imagen_ruta : ($input['imagen_antigua'] ?? '');

        $stmt = $conn->prepare("
            UPDATE Vehiculo SET 
                color=?, `año`=?, precio_dia=?, estado=?, kilometraje=?, id_modelo=?, id_seguro=?, descripcion=?, imagen_principal=?, comision_afiliado=?
            WHERE placa=?
        ");
        // bind_param: tipos s=string, i=int, d=double
        $stmt->bind_param(
            "siidissssds",
            $input["color"],
            $input["año"],
            $input["precio_dia"],
            $input["estado"],
            $input["kilometraje"],
            $input["id_modelo"],
            $input["id_seguro"],
            $input["descripcion"],
            $imagen_final,
            $input["comision_afiliado"],
            $input["placa"]
        );

        ejecutar_stmt($stmt);
        echo json_encode(["success" => true]);
        exit;

    } else {
        // Crear vehículo
        $stmt = $conn->prepare("
            INSERT INTO Vehiculo 
            (placa, color, `año`, precio_dia, estado, kilometraje, id_modelo, id_seguro, descripcion, imagen_principal, destacado, es_afiliado, calificacion_promedio, numero_reseñas, comision_afiliado)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, 0, ?)
        ");
        $stmt->bind_param(
            "ssdisissssd",
            $input["placa"],
            $input["color"],
            $input["año"],
            $input["precio_dia"],
            $input["estado"],
            $input["kilometraje"],
            $input["id_modelo"],
            $input["id_seguro"],
            $input["descripcion"],
            $imagen_ruta,
            $input["comision_afiliado"]
        );
        ejecutar_stmt($stmt);
        echo json_encode(["success" => true]);
        exit;
    }
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
