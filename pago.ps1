-- ============================================================
-- EXTENSIÓN: AGREGAR MÉTODO DE PAGO A TABLA VENTAS
-- ============================================================
-- Este script extiende la tabla de ventas para incluir
-- el método de pago utilizado en cada transacción

USE datastorm;
GO

-- Agregar columna de método de pago si no existe
IF NOT EXISTS (
    SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ventas' AND COLUMN_NAME = 'metodo_pago'
)
BEGIN
    ALTER TABLE dbo.ventas
    ADD metodo_pago VARCHAR(50) DEFAULT 'tarjeta'
    CONSTRAINT chk_metodo_pago CHECK (
        metodo_pago IN ('tarjeta', 'paypal', 'transferencia', 'oxxo')
    );
    
    PRINT '✅ Columna metodo_pago agregada a tabla ventas';
END
ELSE
BEGIN
    PRINT 'ℹ️ La columna metodo_pago ya existe';
END
GO

-- Agregar columna de estado de pedido si no existe
IF NOT EXISTS (
    SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ventas' AND COLUMN_NAME = 'estado_pedido'
)
BEGIN
    ALTER TABLE dbo.ventas
    ADD estado_pedido VARCHAR(50) DEFAULT 'pendiente'
    CONSTRAINT chk_estado_pedido CHECK (
        estado_pedido IN ('pendiente', 'confirmado', 'procesando', 'enviado', 'entregado', 'cancelado')
    );
    
    PRINT '✅ Columna estado_pedido agregada a tabla ventas';
END
ELSE
BEGIN
    PRINT 'ℹ️ La columna estado_pedido ya existe';
END
GO

-- Agregar columna de número de referencia de pago si no existe
IF NOT EXISTS (
    SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ventas' AND COLUMN_NAME = 'referencia_pago'
)
BEGIN
    ALTER TABLE dbo.ventas
    ADD referencia_pago VARCHAR(100) NULL;
    
    PRINT '✅ Columna referencia_pago agregada a tabla ventas';
END
ELSE
BEGIN
    PRINT 'ℹ️ La columna referencia_pago ya existe';
END
GO

-- Ver estructura actualizada
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ventas'
ORDER BY ORDINAL_POSITION;
GO