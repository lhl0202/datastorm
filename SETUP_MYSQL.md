# 🛒 DataStorm - Configuración MySQL y Autenticación de Compras

## 📋 Resumen de Cambios

### ✅ Ya Implementado

1. **Validación de Autenticación en Checkout**
   - Si el usuario NO está autenticado → Abre modal de login/registro
   - Si está autenticado → Continúa con la compra

2. **Estructura MySQL Completa**
   - Tabla `usuarios` - Autenticación de clientes
   - Tabla `pedidos` - Órdenes de compra
   - Tabla `detalle_pedido` - Items en cada pedido
   - Tabla `carrito_temporal` - Carritos guardados
   - Tabla `historial_envios` - Seguimiento de envíos

3. **API PHP para MySQL**
   - `api/guardar-pedido.php` - Guarda pedidos
   - `api/estado.php` - Verifica conexión

4. **Módulo JavaScript de Pedidos**
   - `assets/js/pedidos.js` - Gestión de órdenes

---

## 🚀 Pasos de Instalación

### 1️⃣ Crear Base de Datos MySQL

```bash
# Opción A: Desde línea de comandos
mysql -u root < sql/datastorm_mysql.sql

# Opción B: Desde interfaz gráfica (phpMyAdmin, MySQL Workbench)
# - Abre el archivo sql/datastorm_mysql.sql
# - Copia y pega el contenido
# - Ejecuta
```

### 2️⃣ Configurar Credenciales (IMPORTANTE)

Edita los siguientes archivos con tus credenciales de MySQL:

**api/guardar-pedido.php** (línea ~22):
```php
define('DB_HOST', 'localhost');    // Tu servidor MySQL
define('DB_USER', 'root');         // Tu usuario MySQL
define('DB_PASS', '');             // Tu contraseña MySQL
define('DB_NAME', 'datastorm');
define('DB_PORT', 3306);
```

**api/estado.php** (línea ~8):
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'datastorm');
define('DB_PORT', 3306);
```

### 3️⃣ Verificar Servidor Web

El proyecto necesita ejecutarse bajo un servidor web (Apache/Nginx con PHP):

```bash
# Si tienes XAMPP/WAMP/LAMP
# Coloca la carpeta en:
# - XAMPP: C:\xampp\htdocs\datastorm
# - WAMP: C:\wamp64\www\datastorm
# - Linux: /var/www/html/datastorm

# Accede a:
# http://localhost/datastorm
```

### 4️⃣ Probar Autenticación en Checkout

1. Abre http://localhost/datastorm
2. Ve a Catálogo y agrega productos al carrito
3. Haz clic en "Ir al carrito" → "Proceder al pago"
4. Intenta pagar **SIN estar logueado**
   - ✅ Debe mostrar: "🔐 Debes iniciar sesión..."
   - ✅ Debe abrir modal de login
5. Crea una cuenta y vuelve a intentar
   - ✅ Debe procesar el pago
   - ✅ Debe guardar en MySQL

---

## 📊 Estructura de Tablas MySQL

### `usuarios`
```
id_usuario (PK)
nombre_usuario
correo_usuario (UNIQUE)
contraseña (hasheada)
telefono
domicilio
estado (activo/inactivo)
fecha_registro
fecha_ultimo_acceso
```

### `pedidos`
```
id_pedido (PK)
id_usuario (FK)
numero_referencia (UNIQUE)
fecha_pedido
total_pedido
metodo_pago (tarjeta/paypal/transferencia/oxxo)
estado_pedido (pendiente/confirmado/procesando/enviado/entregado/cancelado)
codigo_oxxo (opcional)
referencia_pago
telefono
domicilio
```

### `detalle_pedido`
```
id_detalle (PK)
id_pedido (FK)
id_producto (FK)
cantidad
precio_unitario
subtotal (GENERATED ALWAYS)
```

---

## 🔐 Flujo de Autenticación en Compra

```
Usuario hace clic en "Pagar"
    ↓
¿Usuario autenticado? (getUser())
    ├─ NO → Mostrar error + Abrir modal login
    └─ SÍ → Validar formulario de compra
            ↓
        ¿Formulario válido?
            ├─ NO → Mostrar errores
            └─ SÍ → Guardar en MySQL
                    ↓
                ¿Carrito no vacío?
                    ├─ NO → Error
                    └─ SÍ → Procesar compra
                            ├─ Crear registro en usuarios (si no existe)
                            ├─ Crear pedido
                            ├─ Guardar detalles de productos
                            └─ Mostrar confirmación + Limpiar carrito
```

---

## 🔧 Funciones Disponibles en `pedidos.js`

```javascript
// Guardar pedido (se llama automáticamente)
guardarPedidoSQL(datoPedido)

// Obtener pedidos del usuario
obtenerPedidosUsuario(correoUsuario)

// Obtener detalles de un pedido
obtenerDetallePedido(idPedido)

// Actualizar estado de pedido
actualizarEstadoPedido(idPedido, nuevoEstado)

// Verificar conexión a MySQL
verificarConexionSQL()
```

---

## ⚙️ Métodos de Pago Soportados

- **Tarjeta de Crédito/Débito**
- **PayPal**
- **Transferencia Bancaria**
- **OXXO**

---

## 📝 Testing de la API

### Probar guardado de pedido:
```bash
curl -X POST http://localhost/datastorm/api/guardar-pedido.php \
  -H "Content-Type: application/json" \
  -d '{
    "numero_referencia": "DS-1234567890",
    "correo_usuario": "test@email.com",
    "usuario": "Juan",
    "telefono": "33-1234-5678",
    "domicilio": "Calle 123, Guadalajara",
    "total_pedido": 1500.50,
    "metodo_pago": "tarjeta",
    "carrito": [
      {"id": 1, "cantidad": 2, "precio": 500.25},
      {"id": 2, "cantidad": 1, "precio": 499}
    ]
  }'
```

### Probar conexión:
```bash
curl http://localhost/datastorm/api/estado.php
```

---

## 🐛 Troubleshooting

### Error: "No hay conexión a MySQL"
- ✅ Verifica que MySQL está corriendo
- ✅ Verifica credenciales en `api/guardar-pedido.php`
- ✅ Comprueba que la base de datos `datastorm` existe

### Error: "Campo requerido faltante"
- ✅ Verifica que envías todos los datos del formulario
- ✅ Revisa la consola del navegador (F12) para errores

### Pedido no se guarda
- ✅ Abre DevTools (F12) → Network → Revisa la respuesta de `guardar-pedido.php`
- ✅ Revisa la consola para mensajes de error

---

## 📚 Archivos Modificados

```
pages/checkout.html          ← Actualizado: Validación auth en procesarCompra()
assets/js/pedidos.js         ← Nuevo: Gestión de pedidos
api/guardar-pedido.php       ← Nuevo: API MySQL
api/estado.php               ← Nuevo: Verificar conexión
sql/datastorm_mysql.sql      ← Nuevo: Estructura MySQL completa
```

---

## ✨ Características Futuras

- [ ] Historial de pedidos en perfil de usuario
- [ ] Email de confirmación automático
- [ ] Integración con gateways de pago reales (Stripe, PayPal API)
- [ ] Rastreo de pedidos en tiempo real
- [ ] Dashboard de administrador para gestión de pedidos

