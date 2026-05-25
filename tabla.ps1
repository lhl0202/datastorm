-- ============================================================
-- BASE DE DATOS: DATASTORM - TIENDA DE COMPUTADORAS
-- Motor: MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS datastorm;
USE datastorm;

-- ============================================================
-- TABLA: USUARIOS (Autenticación)
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo_usuario VARCHAR(120) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    domicilio VARCHAR(255),
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_acceso TIMESTAMP NULL,
    INDEX idx_correo (correo_usuario),
    CONSTRAINT chk_correo_user CHECK (correo_usuario LIKE '%@%.%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: PROVEEDORES
-- ============================================================
CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    correo_proveedor VARCHAR(120) NOT NULL UNIQUE,
    numero_proveedor VARCHAR(20),
    CONSTRAINT chk_correo_prov CHECK (correo_proveedor LIKE '%@%.%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: PRODUCTOS
-- ============================================================
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(150) NOT NULL,
    existencia INT NOT NULL DEFAULT 0,
    precio_producto DECIMAL(10,2) NOT NULL,
    clase VARCHAR(80),
    id_proveedor INT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_precio CHECK (precio_producto >= 0),
    CONSTRAINT chk_existencia CHECK (existencia >= 0),
    INDEX idx_clase (clase)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: PEDIDOS (Órdenes de compra)
-- ============================================================
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    numero_referencia VARCHAR(100) UNIQUE,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_pedido DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    metodo_pago ENUM('tarjeta', 'paypal', 'transferencia', 'oxxo') DEFAULT 'tarjeta',
    estado_pedido ENUM('pendiente', 'confirmado', 'procesando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    codigo_oxxo VARCHAR(50) NULL,
    referencia_pago VARCHAR(100) NULL,
    telefono VARCHAR(20),
    domicilio VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_usuario (id_usuario),
    INDEX idx_fecha (fecha_pedido),
    INDEX idx_estado (estado_pedido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: DETALLE_PEDIDO (Items en cada pedido)
-- ============================================================
CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_precio_unit CHECK (precio_unitario >= 0),
    INDEX idx_pedido (id_pedido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: HISTORIAL_ENVIOS
-- ============================================================
CREATE TABLE IF NOT EXISTS historial_envios (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    numero_seguimiento VARCHAR(100) NOT NULL UNIQUE,
    estado_envio ENUM('pendiente', 'en_camino', 'entregado', 'cancelado') DEFAULT 'pendiente',
    costo_envio DECIMAL(8,2) DEFAULT 0.00,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega TIMESTAMP NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_estado_envio (estado_envio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: CARRITO_TEMPORAL (Carritos guardados)
-- ============================================================
CREATE TABLE IF NOT EXISTS carrito_temporal (
    id_carrito INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE KEY unique_carrito (id_usuario, id_producto),
    INDEX idx_usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

INSERT INTO proveedores (nombre_empresa, correo_proveedor, numero_proveedor) VALUES
('Dell México', 'ventas@dell.com.mx', '800-999-3355'),
('HP Distribuidor MX', 'contacto@hpdist.com.mx', '33-1234-5678'),
('Asus Mayoreo', 'asus@mayoreo.mx', '55-8765-4321');

INSERT INTO productos (nombre_producto, existencia, precio_producto, clase, id_proveedor) VALUES
('Dell Inspiron 15 3000', 10, 12999.00, 'PC', 1),
('HP Pavilion 14', 8, 14500.00, 'PC', 2),
('Asus VivoBook 16X', 6, 16800.00, 'PC', 3),
('Dell Monitor 24 Full HD', 15, 4200.00, 'Monitor', 1),
('HP LaserJet 107a', 5, 2850.00, 'Impresora', 2),
('Teclado Mecanico RGB', 20, 899.00, 'Periferico', 3),
('Mouse Inalambrico Logitech', 25, 450.00, 'Periferico', 3),
('SSD Kingston 1TB', 12, 1350.00, 'Almacenamiento', 2),
('RAM Corsair 16GB DDR4', 18, 980.00, 'Componente', 1),
('Mochila para Laptop 15', 30, 350.00, 'Accesorio', 2);

-- Usuario de prueba (contraseña: 123456 hasheada)
INSERT INTO usuarios (nombre_usuario, correo_usuario, contraseña, telefono, domicilio) VALUES
('Jorge Morales', 'jorge.morales@email.com', '$2y$10$..hash..', '33-1000-0001', 'Av. Patria 100, Guadalajara, Jal.'),
('Gibran Mesina', 'gibran.mesina@email.com', '$2y$10$..hash..', '33-2000-0002', 'Calle Libertad 45, Zapopan, Jal.'),
('Ana Torres', 'ana.torres@email.com', '$2y$10$..hash..', '33-3000-0003', 'Blvd. Tlaquepaque 88, Tlaquepaque, Jal.');

-- ============================================================
-- VISTAS
-- ============================================================

CREATE OR REPLACE VIEW vista_pedidos_usuarios AS
SELECT
    p.id_pedido,
    p.numero_referencia,
    u.nombre_usuario,
    u.correo_usuario,
    p.fecha_pedido,
    p.total_pedido,
    p.metodo_pago,
    p.estado_pedido,
    COUNT(dp.id_detalle) AS cantidad_items
FROM pedidos p
JOIN usuarios u ON p.id_usuario = u.id_usuario
LEFT JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
GROUP BY p.id_pedido;

CREATE OR REPLACE VIEW vista_inventario AS
SELECT
    p.id_producto,
    p.nombre_producto,
    p.clase,
    p.existencia,
    p.precio_producto,
    pr.nombre_empresa AS proveedor
FROM productos p
LEFT JOIN proveedores pr ON pr.id_proveedor = p.id_proveedor;

CREATE OR REPLACE VIEW vista_detalle_pedidos AS
SELECT
    p.id_pedido,
    u.nombre_usuario,
    pr.nombre_producto,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal
FROM detalle_pedido dp
JOIN pedidos p ON p.id_pedido = dp.id_pedido
JOIN usuarios u ON u.id_usuario = p.id_usuario
JOIN productos pr ON pr.id_producto = dp.id_producto;

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger: Actualizar total del pedido al insertar detalle
DELIMITER //
CREATE TRIGGER trg_actualizar_total_pedido
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET total_pedido = (
        SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
        FROM detalle_pedido
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
END //
DELIMITER ;

-- Trigger: Descontar inventario al confirmar pedido
DELIMITER //
CREATE TRIGGER trg_descontar_inventario
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF NEW.estado_pedido = 'confirmado' AND OLD.estado_pedido != 'confirmado' THEN
        UPDATE productos p
        JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
        SET p.existencia = p.existencia - dp.cantidad
        WHERE dp.id_pedido = NEW.id_pedido;
    END IF;
END //
DELIMITER ;

-- Trigger: Registrar último acceso del usuario
DELIMITER //
CREATE TRIGGER trg_ultimo_acceso
AFTER SELECT ON usuarios
FOR EACH ROW
BEGIN
    UPDATE usuarios
    SET fecha_ultimo_acceso = CURRENT_TIMESTAMP
    WHERE id_usuario = NEW.id_usuario;
END //
DELIMITER ;