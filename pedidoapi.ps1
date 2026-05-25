<?php
/**
 * API: Estado de Conexión MySQL
 * Archivo: /api/estado.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'datastorm');

/**
 * API: Guardar Pedido en MySQL
 * Archivo: /api/guardar-pedido.php
 * 
 * Procesa solicitudes POST del frontend para guardar pedidos
 * en la base de datos MySQL
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar preflight CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Solo aceptar POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Método no permitido']);
    exit();
}

// Configuración de MySQL
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'datastorm');
define('DB_PORT', 3306);

try {
    // Recibir datos JSON
    $input = file_get_contents('php://input');
    $datos = json_decode($input, true);

    if (!$datos) {
        throw new Exception('JSON inválido');
    }

    // Validar campos requeridos
    $campos_requeridos = ['numero_referencia', 'correo_usuario', 'total_pedido', 'metodo_pago', 'carrito'];
    foreach ($campos_requeridos as $campo) {
        if (empty($datos[$campo]) && $datos[$campo] !== 0 && $datos[$campo] !== '0') {
            throw new Exception("Campo requerido faltante: $campo");
        }
    }

    // Conectar a MySQL usando mysqli
    $conexion = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);

    if ($conexion->connect_error) {
        throw new Exception('Error de conexión: ' . $conexion->connect_error);
    }

    // Establecer charset UTF-8
    $conexion->set_charset("utf8mb4");

    // ============================================================
    // PASO 1: Encontrar o crear usuario
    // ============================================================
    $correo = filter_var($datos['correo_usuario'], FILTER_SANITIZE_EMAIL);
    $nombre_usuario = isset($datos['usuario']) ? htmlspecialchars($datos['usuario'], ENT_QUOTES, 'UTF-8') : 'Usuario';
    $telefono = htmlspecialchars($datos['telefono'] ?? '', ENT_QUOTES, 'UTF-8');
    $domicilio = htmlspecialchars($datos['domicilio'] ?? '', ENT_QUOTES, 'UTF-8');

    // Buscar usuario existente
    $stmt = $conexion->prepare("SELECT id_usuario FROM usuarios WHERE correo_usuario = ?");
    if (!$stmt) {
        throw new Exception("Error en preparación: " . $conexion->error);
    }

    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows > 0) {
        $usuario = $resultado->fetch_assoc();
        $id_usuario = $usuario['id_usuario'];
    } else {
        // Crear nuevo usuario
        $stmt_insert = $conexion->prepare(
            "INSERT INTO usuarios (nombre_usuario, correo_usuario, contraseña, telefono, domicilio, estado) 
             VALUES (?, ?, ?, ?, ?, 'activo')"
        );

        if (!$stmt_insert) {
            throw new Exception("Error en preparación: " . $conexion->error);
        }

        // Contraseña temporal hasheada
        $pass_temp = password_hash(substr(md5($correo), 0, 8), PASSWORD_BCRYPT);

        $stmt_insert->bind_param("sssss", $nombre_usuario, $correo, $pass_temp, $telefono, $domicilio);

        if (!$stmt_insert->execute()) {
            throw new Exception("Error al crear usuario: " . $stmt_insert->error);
        }

        $id_usuario = $conexion->insert_id;
        $stmt_insert->close();
    }

    $stmt->close();

    // ============================================================
    // PASO 2: Crear pedido
    // ============================================================
    $numero_referencia = htmlspecialchars($datos['numero_referencia'], ENT_QUOTES, 'UTF-8');
    $total_pedido = floatval($datos['total_pedido']);
    $metodo_pago = htmlspecialchars($datos['metodo_pago'], ENT_QUOTES, 'UTF-8');
    $estado_pedido = htmlspecialchars($datos['estado_pedido'] ?? 'pendiente', ENT_QUOTES, 'UTF-8');
    $codigo_oxxo = isset($datos['codigo_oxxo']) ? htmlspecialchars($datos['codigo_oxxo'], ENT_QUOTES, 'UTF-8') : NULL;

    $stmt_pedido = $conexion->prepare(
        "INSERT INTO pedidos (id_usuario, numero_referencia, total_pedido, metodo_pago, estado_pedido, codigo_oxxo, telefono, domicilio) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    );

    if (!$stmt_pedido) {
        throw new Exception("Error en preparación: " . $conexion->error);
    }

    $stmt_pedido->bind_param(
        "isdsssss",
        $id_usuario,
        $numero_referencia,
        $total_pedido,
        $metodo_pago,
        $estado_pedido,
        $codigo_oxxo,
        $telefono,
        $domicilio
    );

    if (!$stmt_pedido->execute()) {
        throw new Exception("Error al crear pedido: " . $stmt_pedido->error);
    }

    $id_pedido = $conexion->insert_id;
    $stmt_pedido->close();

    // ============================================================
    // PASO 3: Guardar detalles del pedido
    // ============================================================
    $carrito = $datos['carrito'] ?? [];
    $stmt_detalle = $conexion->prepare(
        "INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) 
         VALUES (?, ?, ?, ?)"
    );

    if (!$stmt_detalle) {
        throw new Exception("Error en preparación: " . $conexion->error);
    }

    foreach ($carrito as $item) {
        $id_producto = intval($item['id'] ?? 0);
        $cantidad = intval($item['cantidad'] ?? 1);
        $precio_unitario = floatval($item['precio'] ?? 0);

        if ($id_producto > 0 && $cantidad > 0 && $precio_unitario >= 0) {
            $stmt_detalle->bind_param(
                "iid",
                $id_pedido,
                $id_producto,
                $precio_unitario
            );

            // Necesitamos reasignar cantidad después de cada iteración
            $stmt_detalle->bind_param(
                "iidd",
                $id_pedido,
                $id_producto,
                $cantidad,
                $precio_unitario
            );

            if (!$stmt_detalle->execute()) {
                throw new Exception("Error al guardar detalle: " . $stmt_detalle->error);
            }
        }
    }

    $stmt_detalle->close();

    // ============================================================
    // Respuesta exitosa
    // ============================================================
    http_response_code(201);
    echo json_encode([
        'success' => true,
        'id_pedido' => $id_pedido,
        'id_usuario' => $id_usuario,
        'numero_referencia' => $numero_referencia,
        'mensaje' => 'Pedido guardado exitosamente en MySQL'
    ]);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);

} finally {
    if (isset($conexion)) {
        $conexion->close();
    }
}
?>