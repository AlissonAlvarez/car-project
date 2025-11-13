<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

require_once "../config/Constantes.php";
require_once "../Configuracion/Conexion.php";

$db = new Conexion();
$conn = $db->abrir_conexion();

// ========================================================
// LISTAR MODELOS (JOIN con Marca)
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && !isset($_GET['borrar'])) {
    $sql = "SELECT 
                m.id_modelo,
                m.nombre_modelo,
                m.tipo_vehiculo,
                m.capacidad,
                ma.id_marca,
                ma.nombre_marca
            FROM Modelo m
            INNER JOIN Marca ma ON m.id_marca = ma.id_marca
            ORDER BY m.id_modelo ASC";

    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();

    $modelos = [];
    while ($row = $result->fetch_assoc()) {
        $modelos[] = $row;
    }

    echo json_encode($modelos);
    exit;
}

// ========================================================
// INSERTAR MODELO
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['insertar'])) {
    $data = json_decode(file_get_contents("php://input"), true);

    $id_modelo = $conn->real_escape_string($data['id_modelo']);
    $nombre_modelo = $conn->real_escape_string($data['nombre_modelo']);
    $tipo_vehiculo = $conn->real_escape_string($data['tipo_vehiculo']);
    $capacidad = intval($data['capacidad']);
    $id_marca = $conn->real_escape_string($data['id_marca']);

    // Validar que la marca exista
    $sqlMarca = "SELECT id_marca FROM Marca WHERE id_marca = '$id_marca'";
    $db->consultar_informacion($sqlMarca);
    $resMarca = $db->obtener_resultados();
    if ($resMarca->num_rows == 0) {
        echo json_encode(["success" => 0, "message" => "La marca especificada no existe"]);
        exit;
    }

    $sql = "INSERT INTO Modelo (id_modelo, nombre_modelo, tipo_vehiculo, capacidad, id_marca)
            VALUES ('$id_modelo', '$nombre_modelo', '$tipo_vehiculo', '$capacidad', '$id_marca')";

    $db->consultar_informacion($sql);
    if ($conn->affected_rows > 0) {
        echo json_encode(["success" => 1, "message" => "Modelo creado correctamente"]);
    } else {
        echo json_encode(["success" => 0, "message" => "Error al crear modelo", "error" => $conn->error]);
    }
    exit;
}

// ========================================================
// ACTUALIZAR MODELO
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['actualizar'])) {
    $id_modelo = $conn->real_escape_string($_GET['actualizar']);
    $data = json_decode(file_get_contents("php://input"), true);

    $nombre_modelo = $conn->real_escape_string($data['nombre_modelo']);
    $tipo_vehiculo = $conn->real_escape_string($data['tipo_vehiculo']);
    $capacidad = intval($data['capacidad']);
    $id_marca = $conn->real_escape_string($data['id_marca']);

    $sql = "UPDATE Modelo 
            SET nombre_modelo = '$nombre_modelo',
                tipo_vehiculo = '$tipo_vehiculo',
                capacidad = '$capacidad',
                id_marca = '$id_marca'
            WHERE id_modelo = '$id_modelo'";

    $db->consultar_informacion($sql);

    if ($conn->affected_rows >= 0) {
        echo json_encode(["success" => 1, "message" => "Modelo actualizado correctamente"]);
    } else {
        echo json_encode(["success" => 0, "message" => "Error al actualizar modelo", "error" => $conn->error]);
    }
    exit;
}

// ========================================================
// ELIMINAR MODELO
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['borrar'])) {
    $id_modelo = $conn->real_escape_string($_GET['borrar']);

    // Verificar si el modelo está asociado a algún vehículo
    $sqlCheck = "SELECT COUNT(*) as total FROM Vehiculo WHERE id_modelo = '$id_modelo'";
    $db->consultar_informacion($sqlCheck);
    $resultCheck = $db->obtener_resultados();
    $rowCheck = $resultCheck->fetch_assoc();

    if ($rowCheck['total'] > 0) {
        echo json_encode(["success" => 0, "message" => "No se puede eliminar. Existen vehículos asociados a este modelo."]);
        exit;
    }

    $sql = "DELETE FROM Modelo WHERE id_modelo = '$id_modelo'";
    $db->consultar_informacion($sql);

    echo json_encode(["success" => 1, "message" => "Modelo eliminado correctamente"]);
    exit;
}

// ========================================================
// OBTENER MODELO POR ID
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['detalle'])) {
    $id_modelo = $conn->real_escape_string($_GET['detalle']);

    $sql = "SELECT 
                m.id_modelo,
                m.nombre_modelo,
                m.tipo_vehiculo,
                m.capacidad,
                ma.id_marca,
                ma.nombre_marca
            FROM Modelo m
            INNER JOIN Marca ma ON m.id_marca = ma.id_marca
            WHERE m.id_modelo = '$id_modelo'";

    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();

    if ($row = $result->fetch_assoc()) {
        echo json_encode($row);
    } else {
        echo json_encode(["success" => 0, "message" => "Modelo no encontrado"]);
    }
    exit;
}

// ========================================================
// OBTENER ESTADÍSTICAS DE MODELOS
// ========================================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['estadisticas'])) {
    $sql = "SELECT 
                COUNT(*) AS total_modelos,
                COUNT(DISTINCT id_marca) AS total_marcas,
                AVG(capacidad) AS capacidad_promedio
            FROM Modelo";
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
