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
define('DB_PORT', 3306);

try {
    $conexion = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);

    if ($conexion->connect_error) {
        http_response_code(503);
        echo json_encode([
            'success' => false,
            'estado' => 'desconectado',
            'error' => 'No hay conexión a MySQL'
        ]);
    } else {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'estado' => 'conectado',
            'base_datos' => DB_NAME,
            'servidor' => DB_HOST
        ]);
        $conexion->close();
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
