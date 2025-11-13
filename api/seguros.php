<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

require_once "../config/Constantes.php";
require_once "../config/Conexion.php";

$db = new Conexion();
$conn = $db->abrir_conexion();

// ========================================================
// LISTAR SEGUROS
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && !isset($_GET['borrar']) && !isset($_GET['detalle']) && !isset($_GET['estadisticas'])) {
    $sql = "SELECT 
                id_seguro,
                nombre_compania,
                tipo_cobertura,
                costo_diario,
                telefono_contacto
            FROM Seguro
            ORDER BY id_seguro ASC";

    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();

    $seguros = [];
    while ($row = $result->fetch_assoc()) {
        $seguros[] = $row;
    }

    echo json_encode($seguros);
    exit;
}

// ========================================================
// INSERTAR SEGURO
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['insertar'])) {
    $data = json_decode(file_get_contents("php://input"), true);

    $id_seguro = $conn->real_escape_string($data['id_seguro']);
    $nombre_compania = $conn->real_escape_string($data['nombre_compania']);
    $tipo_cobertura = $conn->real_escape_string($data['tipo_cobertura']);
    $costo_diario = floatval($data['costo_diario']);
    $telefono_contacto = $conn->real_escape_string($data['telefono_contacto']);

    $sql = "INSERT INTO Seguro (id_seguro, nombre_compania, tipo_cobertura, costo_diario, telefono_contacto)
            VALUES ('$id_seguro', '$nombre_compania', '$tipo_cobertura', '$costo_diario', '$telefono_contacto')";

    $db->consultar_informacion($sql);

    if ($conn->affected_rows > 0) {
        echo json_encode(["success" => 1, "message" => "Seguro creado correctamente"]);
    } else {
        echo json_encode(["success" => 0, "message" => "Error al crear seguro", "error" => $conn->error]);
    }
    exit;
}

// ========================================================
// ACTUALIZAR SEGURO
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['actualizar'])) {
    $id_seguro = $conn->real_escape_string($_GET['actualizar']);
    $data = json_decode(file_get_contents("php://input"), true);

    $nombre_compania = $conn->real_escape_string($data['nombre_compania']);
    $tipo_cobertura = $conn->real_escape_string($data['tipo_cobertura']);
    $costo_diario = floatval($data['costo_diario']);
    $telefono_contacto = $conn->real_escape_string($data['telefono_contacto']);

    $sql = "UPDATE Seguro 
            SET nombre_compania = '$nombre_compania',
                tipo_cobertura = '$tipo_cobertura',
                costo_diario = '$costo_diario',
                telefono_contacto = '$telefono_contacto'
            WHERE id_seguro = '$id_seguro'";

    $db->consultar_informacion($sql);

    if ($conn->affected_rows >= 0) {
        echo json_encode(["success" => 1, "message" => "Seguro actualizado correctamente"]);
    } else {
        echo json_encode(["success" => 0, "message" => "Error al actualizar seguro", "error" => $conn->error]);
    }
    exit;
}

// ========================================================
// ELIMINAR SEGURO
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['borrar'])) {
    $id_seguro = $conn->real_escape_string($_GET['borrar']);

    // Verificar si el seguro está asociado a algún vehículo
    $sqlCheck = "SELECT COUNT(*) AS total FROM Vehiculo WHERE id_seguro = '$id_seguro'";
    $db->consultar_informacion($sqlCheck);
    $resultCheck = $db->obtener_resultados();
    $rowCheck = $resultCheck->fetch_assoc();

    if ($rowCheck['total'] > 0) {
        echo json_encode(["success" => 0, "message" => "No se puede eliminar. Existen vehículos asociados a este seguro."]);
        exit;
    }

    $sql = "DELETE FROM Seguro WHERE id_seguro = '$id_seguro'";
    $db->consultar_informacion($sql);

    echo json_encode(["success" => 1, "message" => "Seguro eliminado correctamente"]);
    exit;
}

// ========================================================
// OBTENER SEGURO POR ID
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['detalle'])) {
    $id_seguro = $conn->real_escape_string($_GET['detalle']);

    $sql = "SELECT 
                id_seguro,
                nombre_compania,
                tipo_cobertura,
                costo_diario,
                telefono_contacto
            FROM Seguro
            WHERE id_seguro = '$id_seguro'";

    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();

    if ($row = $result->fetch_assoc()) {
        echo json_encode($row);
    } else {
        echo json_encode(["success" => 0, "message" => "Seguro no encontrado"]);
    }
    exit;
}

// ========================================================
// OBTENER ESTADÍSTICAS DE SEGUROS
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['estadisticas'])) {
    $sql = "SELECT 
                COUNT(*) AS total_seguros,
                AVG(costo_diario) AS costo_promedio,
                MIN(costo_diario) AS costo_minimo,
                MAX(costo_diario) AS costo_maximo
            FROM Seguro";
    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();

    if ($row = $result->fetch_assoc()) {
        echo json_encode($row);
    }
    exit;
}

echo json_encode(["success" => 0, "message" => "Acción no válida"]);
exit;
?>
