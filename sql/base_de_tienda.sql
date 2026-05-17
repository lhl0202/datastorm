-- ============================================================
-- BASE DE DATOS: DATASTORM - TIENDA DE COMPUTADORAS
-- Integrantes: Jorge Morales Chávez | Gibran Mesina Mejía
-- Motor: SQL Server (T-SQL)
-- ============================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'datastorm')
    CREATE DATABASE datastorm;
GO

USE datastorm;
GO

-- ============================================================
-- TABLA: PROVEEDORES
-- ============================================================
IF OBJECT_ID('dbo.proveedores', 'U') IS NOT NULL
    DROP TABLE dbo.proveedores;
GO

CREATE TABLE dbo.proveedores (
    id_proveedor     INT IDENTITY(1,1) PRIMARY KEY,
    nombre_empresa   VARCHAR(100) NOT NULL,
    correo_proveedor VARCHAR(120) NOT NULL UNIQUE,
    numero_proveedor VARCHAR(20),
    CONSTRAINT chk_correo_prov CHECK (correo_proveedor LIKE '%@%.%')
);
GO

-- ============================================================
-- TABLA: CLIENTES
-- ============================================================
IF OBJECT_ID('dbo.clientes', 'U') IS NOT NULL
    DROP TABLE dbo.clientes;
GO

CREATE TABLE dbo.clientes (
    id_cliente     INT IDENTITY(1,1) PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    numero         VARCHAR(20),
    correo_cliente VARCHAR(120) NOT NULL UNIQUE,
    domicilio      VARCHAR(255),
    CONSTRAINT chk_correo_cli CHECK (correo_cliente LIKE '%@%.%')
);
GO

-- ============================================================
-- TABLA: PRODUCTOS
-- ============================================================
IF OBJECT_ID('dbo.productos', 'U') IS NOT NULL
    DROP TABLE dbo.productos;
GO

CREATE TABLE dbo.productos (
    id_producto     INT IDENTITY(1,1) PRIMARY KEY,
    nombre_producto VARCHAR(150) NOT NULL,
    existencia      INT NOT NULL DEFAULT 0,
    precio_producto DECIMAL(10,2) NOT NULL,
    clase           VARCHAR(80),
    id_proveedor    INT NULL,
    CONSTRAINT fk_prod_prov   FOREIGN KEY (id_proveedor)
        REFERENCES dbo.proveedores(id_proveedor)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_precio     CHECK (precio_producto >= 0),
    CONSTRAINT chk_existencia CHECK (existencia >= 0)
);
GO

-- ============================================================
-- TABLA: VENTAS
-- ============================================================
IF OBJECT_ID('dbo.ventas', 'U') IS NOT NULL
    DROP TABLE dbo.ventas;
GO

CREATE TABLE dbo.ventas (
    id_venta    INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente  INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT GETDATE(),
    total_final DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_venta_cli FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes(id_cliente)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

-- ============================================================
-- TABLA: DETALLE_VENTA
-- ============================================================
IF OBJECT_ID('dbo.detalle_venta', 'U') IS NOT NULL
    DROP TABLE dbo.detalle_venta;
GO

CREATE TABLE dbo.detalle_venta (
    id_detalle      INT IDENTITY(1,1) PRIMARY KEY,
    id_venta        INT NOT NULL,
    id_producto     INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_det_venta  FOREIGN KEY (id_venta)
        REFERENCES dbo.ventas(id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_det_prod   FOREIGN KEY (id_producto)
        REFERENCES dbo.productos(id_producto)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT chk_cantidad    CHECK (cantidad > 0),
    CONSTRAINT chk_precio_unit CHECK (precio_unitario >= 0)
);
GO

-- ============================================================
-- TABLA: DETALLE_ENVIO
-- ENUM no existe en T-SQL; se reemplaza con VARCHAR + CHECK
-- ============================================================
IF OBJECT_ID('dbo.detalle_envio', 'U') IS NOT NULL
    DROP TABLE dbo.detalle_envio;
GO

CREATE TABLE dbo.detalle_envio (
    id_envio     INT IDENTITY(1,1) PRIMARY KEY,
    id_venta     INT NOT NULL UNIQUE,
    numero_envio VARCHAR(60) NOT NULL UNIQUE,
    direccion    VARCHAR(255) NOT NULL,
    costo_envio  DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    estado_envio VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    fecha_envio  DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_envio_venta FOREIGN KEY (id_venta)
        REFERENCES dbo.ventas(id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_estado_envio CHECK (
        estado_envio IN ('pendiente', 'en_camino', 'entregado', 'cancelado')
    )
);
GO

-- ============================================================
-- TRIGGERS
-- Sin DELIMITER (no existe en T-SQL)
-- Cada trigger usa la tabla virtual "inserted" en vez de NEW
-- ============================================================

CREATE OR ALTER TRIGGER trg_actualizar_total
ON dbo.detalle_venta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE v
    SET v.total_final = (
        SELECT COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0)
        FROM dbo.detalle_venta dv
        WHERE dv.id_venta = i.id_venta
    )
    FROM dbo.ventas v
    INNER JOIN inserted i ON v.id_venta = i.id_venta;
END;
GO

CREATE OR ALTER TRIGGER trg_descontar_inventario
ON dbo.detalle_venta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.existencia = p.existencia - i.cantidad
    FROM dbo.productos p
    INNER JOIN inserted i ON p.id_producto = i.id_producto;
END;
GO

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

INSERT INTO dbo.proveedores (nombre_empresa, correo_proveedor, numero_proveedor) VALUES
('Dell México',        'ventas@dell.com.mx',     '800-999-3355'),
('HP Distribuidor MX', 'contacto@hpdist.com.mx', '33-1234-5678'),
('Asus Mayoreo',       'asus@mayoreo.mx',         '55-8765-4321');
GO

INSERT INTO dbo.clientes (nombre_cliente, numero, correo_cliente, domicilio) VALUES
('Jorge Morales Chavez', '33-1000-0001', 'jorge.morales@email.com', 'Av. Patria 100, Guadalajara, Jal.'),
('Gibran Mesina Mejia',  '33-2000-0002', 'gibran.mesina@email.com', 'Calle Libertad 45, Zapopan, Jal.'),
('Ana Torres Lopez',     '33-3000-0003', 'ana.torres@email.com',    'Blvd. Tlaquepaque 88, Tlaquepaque, Jal.');
GO

INSERT INTO dbo.productos (nombre_producto, existencia, precio_producto, clase, id_proveedor) VALUES
('Dell Inspiron 15 3000',      10, 12999.00, 'PC',             1),
('HP Pavilion 14',              8, 14500.00, 'PC',             2),
('Asus VivoBook 16X',           6, 16800.00, 'PC',             3),
('Dell Monitor 24 Full HD',    15,  4200.00, 'Monitor',        1),
('HP LaserJet 107a',            5,  2850.00, 'Impresora',      2),
('Teclado Mecanico RGB',       20,   899.00, 'Periferico',     3),
('Mouse Inalambrico Logitech', 25,   450.00, 'Periferico',     3),
('SSD Kingston 1TB',           12,  1350.00, 'Almacenamiento', 2),
('RAM Corsair 16GB DDR4',      18,   980.00, 'Componente',     1),
('Mochila para Laptop 15',     30,   350.00, 'Accesorio',      2);
GO

-- ============================================================
-- VISTAS
-- CREATE VIEW debe ser el unico statement del batch en T-SQL
-- ============================================================

CREATE OR ALTER VIEW dbo.vista_ventas AS
SELECT
    v.id_venta,
    c.nombre_cliente,
    c.correo_cliente,
    v.fecha_venta,
    v.total_final,
    e.estado_envio,
    e.numero_envio
FROM dbo.ventas v
JOIN dbo.clientes c ON c.id_cliente = v.id_cliente
LEFT JOIN dbo.detalle_envio e ON e.id_venta = v.id_venta;
GO

CREATE OR ALTER VIEW dbo.vista_inventario AS
SELECT
    p.id_producto,
    p.nombre_producto,
    p.clase,
    p.existencia,
    p.precio_producto,
    pr.nombre_empresa AS proveedor
FROM dbo.productos p
LEFT JOIN dbo.proveedores pr ON pr.id_proveedor = p.id_proveedor;
GO

CREATE OR ALTER VIEW dbo.vista_detalle_venta AS
SELECT
    dv.id_venta,
    c.nombre_cliente,
    pr.nombre_producto,
    dv.cantidad,
    dv.precio_unitario,
    (dv.cantidad * dv.precio_unitario) AS subtotal
FROM dbo.detalle_venta dv
JOIN dbo.ventas v      ON v.id_venta      = dv.id_venta
JOIN dbo.clientes c    ON c.id_cliente    = v.id_cliente
JOIN dbo.productos pr  ON pr.id_producto  = dv.id_producto;
GO