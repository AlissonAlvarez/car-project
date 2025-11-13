<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

require_once "../config/Constantes.php";
require_once "../config/Conexion.php";

$db = new Conexion();
$conn = $db->abrir_conexion();

// ============================================
// LISTAR VEHÍCULOS (con joins a tablas relacionadas)
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && !isset($_GET['borrar'])) {
    $sql = "SELECT 
                v.*,
                m.nombre_modelo,
                m.tipo_vehiculo,
                m.capacidad,
                ma.nombre_marca,
                s.nombre_compania as seguro_nombre,
                s.tipo_cobertura,
                s.costo_diario as seguro_costo
            FROM Vehiculo v
            INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
            INNER JOIN Marca ma ON m.id_marca = ma.id_marca
            INNER JOIN Seguro s ON v.id_seguro = s.id_seguro
            ORDER BY v.placa DESC";
    
    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();
    
    $vehiculos = [];
    while ($row = $result->fetch_assoc()) {
        $vehiculos[] = $row;
    }
    
    echo json_encode($vehiculos);
    exit;
}

// ============================================
// INSERTAR VEHÍCULO
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['insertar'])) {
    $data = json_decode(file_get_contents("php://input"), true);
    
    $placa = $conn->real_escape_string($data['placa']);
    $color = $conn->real_escape_string($data['color']);
    $año = $data['año'];
    $precio_dia = $data['precio_dia'];
    $estado = $conn->real_escape_string($data['estado'] ?? 'Disponible');
    $kilometraje = $data['kilometraje'];
    $id_modelo = $conn->real_escape_string($data['id_modelo']);
    $id_seguro = $conn->real_escape_string($data['id_seguro']);
    
    // Validar estados permitidos
    $estados_validos = ['Disponible', 'Alquilado', 'Mantenimiento', 'Fuera de servicio'];
    if (!in_array($estado, $estados_validos)) {
        echo json_encode([
            "success" => 0,
            "message" => "Estado no válido. Debe ser: Disponible, Alquilado, Mantenimiento o Fuera de servicio"
        ]);
        exit;
    }
    
    $sql = "INSERT INTO Vehiculo (
                placa, color, año, precio_dia, estado, kilometraje, 
                id_modelo, id_seguro
            ) VALUES (
                '$placa', '$color', '$año', '$precio_dia', '$estado', '$kilometraje',
                '$id_modelo', '$id_seguro'
            )";
    
    $db->consultar_informacion($sql);
    $insertado = $conn->affected_rows ?? 0;
    
    if ($insertado > 0) {
        echo json_encode([
            "success" => 1,
            "message" => "Vehículo creado correctamente",
            "placa" => $placa
        ]);
    } else {
        echo json_encode([
            "success" => 0,
            "message" => "Error al crear vehículo",
            "error_sql" => $conn->error
        ]);
    }
    exit;
}

// ============================================
// ACTUALIZAR VEHÍCULO
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['actualizar'])) {
    $placa = $_GET['actualizar'];
    $data = json_decode(file_get_contents("php://input"), true);
    
    $color = $conn->real_escape_string($data['color']);
    $año = $data['año'];
    $precio_dia = $data['precio_dia'];
    $estado = $conn->real_escape_string($data['estado']);
    $kilometraje = $data['kilometraje'];
    $id_modelo = $conn->real_escape_string($data['id_modelo']);
    $id_seguro = $conn->real_escape_string($data['id_seguro']);
    
    // Validar estados permitidos
    $estados_validos = ['Disponible', 'Alquilado', 'Mantenimiento', 'Fuera de servicio'];
    if (!in_array($estado, $estados_validos)) {
        echo json_encode([
            "success" => 0,
            "message" => "Estado no válido"
        ]);
        exit;
    }
    
    $sql = "UPDATE Vehiculo SET 
                color = '$color',
                año = '$año',
                precio_dia = '$precio_dia',
                estado = '$estado',
                kilometraje = '$kilometraje',
                id_modelo = '$id_modelo',
                id_seguro = '$id_seguro'
            WHERE placa = '$placa'";
    
    $db->consultar_informacion($sql);
    $actualizado = $conn->affected_rows ?? 0;
    
    if ($actualizado >= 0) {
        echo json_encode([
            "success" => 1,
            "message" => "Vehículo actualizado correctamente"
        ]);
    } else {
        echo json_encode([
            "success" => 0,
            "message" => "Error al actualizar vehículo",
            "error_sql" => $conn->error
        ]);
    }
    exit;
}

// ============================================
// ELIMINAR VEHÍCULO
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['borrar'])) {
    $placa = $_GET['borrar'];
    
    // Verificar si tiene órdenes de alquiler activas
    $sqlCheck = "SELECT COUNT(*) as total FROM Orden_Alquiler 
                 WHERE placa = '$placa' 
                 AND estado IN ('Activa')";
    $db->consultar_informacion($sqlCheck);
    $resultCheck = $db->obtener_resultados();
    $rowCheck = $resultCheck->fetch_assoc();
    
    if ($rowCheck['total'] > 0) {
        echo json_encode([
            "success" => 0,
            "message" => "No se puede eliminar. El vehículo tiene órdenes de alquiler activas."
        ]);
        exit;
    }
    
    $sql = "DELETE FROM Vehiculo WHERE placa = '$placa'";
    $db->consultar_informacion($sql);
    
    echo json_encode([
        "success" => 1,
        "message" => "Vehículo eliminado correctamente"
    ]);
    exit;
}

// ============================================
// CAMBIAR ESTADO DEL VEHÍCULO
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_GET['cambiar_estado'])) {
    $placa = $_GET['cambiar_estado'];
    $data = json_decode(file_get_contents("php://input"), true);
    $nuevo_estado = $conn->real_escape_string($data['estado']);
    
    // Validar estados permitidos
    $estados_validos = ['Disponible', 'Alquilado', 'Mantenimiento', 'Fuera de servicio'];
    if (!in_array($nuevo_estado, $estados_validos)) {
        echo json_encode([
            "success" => 0,
            "message" => "Estado no válido. Debe ser: Disponible, Alquilado, Mantenimiento o Fuera de servicio"
        ]);
        exit;
    }
    
    $sql = "UPDATE Vehiculo SET estado = '$nuevo_estado' WHERE placa = '$placa'";
    $db->consultar_informacion($sql);
    
    echo json_encode([
        "success" => 1,
        "message" => "Estado actualizado correctamente"
    ]);
    exit;
}

// ============================================
// OBTENER VEHÍCULOS DISPONIBLES (con filtros)
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['disponibles'])) {
    $fecha_inicio = isset($_GET['fecha_inicio']) ? $conn->real_escape_string($_GET['fecha_inicio']) : null;
    $fecha_fin = isset($_GET['fecha_fin']) ? $conn->real_escape_string($_GET['fecha_fin']) : null;
    
    $sql = "SELECT 
                v.*,
                m.nombre_modelo,
                m.tipo_vehiculo,
                m.capacidad,
                ma.nombre_marca
            FROM Vehiculo v
            INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
            INNER JOIN Marca ma ON m.id_marca = ma.id_marca
            WHERE v.estado = 'Disponible'";
    
    // Filtrar vehículos que no estén alquilados en las fechas solicitadas
    if ($fecha_inicio && $fecha_fin) {
        $sql .= " AND v.placa NOT IN (
                    SELECT placa FROM Orden_Alquiler 
                    WHERE estado = 'Activa'
                    AND (
                        (fecha_inicio <= '$fecha_fin' AND fecha_fin >= '$fecha_inicio')
                    )
                )";
    }
    
    $sql .= " ORDER BY v.precio_dia ASC";
    
    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();
    
    $vehiculos = [];
    while ($row = $result->fetch_assoc()) {
        $vehiculos[] = $row;
    }
    
    echo json_encode($vehiculos);
    exit;
}

// ============================================
// OBTENER VEHÍCULO POR PLACA (detalle completo)
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['detalle'])) {
    $placa = $conn->real_escape_string($_GET['detalle']);
    
    $sql = "SELECT 
                v.*,
                m.nombre_modelo,
                m.tipo_vehiculo,
                m.capacidad,
                ma.nombre_marca,
                s.nombre_compania as seguro_nombre,
                s.tipo_cobertura,
                s.costo_diario as seguro_costo,
                s.telefono_contacto as seguro_telefono
            FROM Vehiculo v
            INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
            INNER JOIN Marca ma ON m.id_marca = ma.id_marca
            INNER JOIN Seguro s ON v.id_seguro = s.id_seguro
            WHERE v.placa = '$placa'";
    
    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();
    
    if ($row = $result->fetch_assoc()) {
        // Obtener historial de mantenimiento
        $sqlMantenimiento = "SELECT 
                                man.*,
                                e.nombres as empleado_nombre,
                                e.apellidos as empleado_apellido
                             FROM Mantenimiento man
                             INNER JOIN Empleado e ON man.cedula_empleado = e.cedula_empleado
                             WHERE man.placa = '$placa'
                             ORDER BY man.fecha_mantenimiento DESC
                             LIMIT 5";
        $db->consultar_informacion($sqlMantenimiento);
        $resultMantenimiento = $db->obtener_resultados();
        
        $mantenimientos = [];
        while ($mant = $resultMantenimiento->fetch_assoc()) {
            $mantenimientos[] = $mant;
        }
        $row['historial_mantenimiento'] = $mantenimientos;
        
        // Obtener órdenes de alquiler recientes
        $sqlOrdenes = "SELECT 
                            oa.*,
                            c.nombres as cliente_nombre,
                            c.apellidos as cliente_apellido
                       FROM Orden_Alquiler oa
                       INNER JOIN Cliente c ON oa.cedula_cliente = c.cedula_cliente
                       WHERE oa.placa = '$placa'
                       ORDER BY oa.fecha_inicio DESC
                       LIMIT 5";
        $db->consultar_informacion($sqlOrdenes);
        $resultOrdenes = $db->obtener_resultados();
        
        $ordenes = [];
        while ($orden = $resultOrdenes->fetch_assoc()) {
            $ordenes[] = $orden;
        }
        $row['historial_alquiler'] = $ordenes;
        
        echo json_encode($row);
    } else {
        echo json_encode([
            "success" => 0,
            "message" => "Vehículo no encontrado"
        ]);
    }
    exit;
}

// ============================================
// OBTENER VEHÍCULOS POR ESTADO
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['por_estado'])) {
    $estado = $conn->real_escape_string($_GET['por_estado']);
    
    $sql = "SELECT 
                v.*,
                m.nombre_modelo,
                m.tipo_vehiculo,
                ma.nombre_marca
            FROM Vehiculo v
            INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
            INNER JOIN Marca ma ON m.id_marca = ma.id_marca
            WHERE v.estado = '$estado'
            ORDER BY v.placa";
    
    $db->consultar_informacion($sql);
    $result = $db->obtener_resultados();
    
    $vehiculos = [];
    while ($row = $result->fetch_assoc()) {
        $vehiculos[] = $row;
    }
    
    echo json_encode($vehiculos);
    exit;
}

// ============================================
// OBTENER ESTADÍSTICAS DE VEHÍCULOS
// ============================================
if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['estadisticas'])) {
    $sql = "SELECT 
                COUNT(*) as total_vehiculos,
                SUM(CASE WHEN estado = 'Disponible' THEN 1 ELSE 0 END) as disponibles,
                SUM(CASE WHEN estado = 'Alquilado' THEN 1 ELSE 0 END) as alquilados,
                SUM(CASE WHEN estado = 'Mantenimiento' THEN 1 ELSE 0 END) as mantenimiento,
                SUM(CASE WHEN estado = 'Fuera de servicio' THEN 1 ELSE 0 END) as fuera_servicio,
                AVG(precio_dia) as precio_promedio,
                AVG(kilometraje) as kilometraje_promedio
            FROM Vehiculo";
    
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