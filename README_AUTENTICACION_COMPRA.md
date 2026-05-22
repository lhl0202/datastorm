#  AUTENTICACIÓN EN COMPRA - DataStorm

## ¿Qué se implementó?

### 1. Validación de Autenticación en Checkout
Cuando el usuario intenta **procesar una compra**, el sistema verifica:

- **Si NO está autenticado:**
  - Muestra: ` Debes iniciar sesión o crear cuenta para continuar`
  - Abre automáticamente el modal de login/registro
  - Cancela la compra

- **Si está autenticado:**
  - Valida el formulario
  - Procesa la compra
  - Guarda en MySQL

### 2.  Conexión a Base de Datos MySQL
Todos los pedidos se guardan automáticamente en MySQL con:
- Datos del usuario
- Productos comprados
- Total de la compra
- Método de pago
- Estado del pedido

---

##  Archivos Nuevos/Modificados

| Archivo | Tipo | Cambio | Ubicación |
|---------|------|--------|-----------|
| `checkout.html` | Modificado | Agregada validación auth | `pages/` |
| `pedidos.js` | Nuevo | Gestión de pedidos | `assets/js/` |
| `guardar-pedido.php` | Nuevo | API MySQL | `api/` |
| `estado.php` | Nuevo | Verificar conexión | `api/` |
| `datastorm_mysql.sql` | Nuevo | Base de datos completa | `sql/` |
| `SETUP_MYSQL.md` | Nuevo | Instrucciones | `./` |

---

## 🔧 Configuración Rápida

### Paso 1: Crear base de datos
```bash
# En terminal MySQL o desde phpMyAdmin
mysql -u root < sql/datastorm_mysql.sql
```

### Paso 2: Configurar credenciales
Edita estos archivos con tus datos MySQL:

**api/guardar-pedido.php** (líneas ~22-26):
```php
define('DB_HOST', 'localhost');  // Tu servidor
define('DB_USER', 'root');       // Tu usuario
define('DB_PASS', '');           // Tu contraseña
define('DB_NAME', 'datastorm');
define('DB_PORT', 3306);
```

**api/estado.php** (líneas ~8-12):
```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'datastorm');
define('DB_PORT', 3306);
```

### Paso 3: Ejecutar en servidor web
```bash
# XAMPP: C:\xampp\htdocs\datastorm
# WAMP: C:\wamp64\www\datastorm
# Linux: /var/www/html/datastorm

# Accede a: http://localhost/datastorm
```

---

##  Flujo de Compra

```
┌─────────────────────────────┐
│ Usuario en Checkout         │
└──────────────┬──────────────┘
               │
               ▼
      ┌────────────────┐
      │ Click en "Pagar" │
      └────────┬─────────┘
               │
               ▼
    ┌──────────────────────┐
    │ procesarCompra()     │
    │ Verifica: getUser()  │
    └──────┬──────────┬────┘
           │          │
       SÍ  │          │  NO
           │          │
           ▼          ▼
    ┌─────────┐   ┌──────────────────┐
    │ Valida  │   │Abre modal login  │
    │ Compra  │   │ Retorna (stop)   │
    └────┬────┘   └──────────────────┘
         │
         ▼
    ┌─────────────────┐
    │ guardarPedidoSQL│
    │ Envía a MySQL   │
    └────┬────────────┘
         │
         ▼
    ┌────────────────────────────┐
    │ api/guardar-pedido.php     │
    │ • Crea/busca usuario       │
    │ • Inserta pedido           │
    │ • Guarda detalles producto │
    └────┬───────────────────────┘
         │
         ▼
    ┌──────────────────┐
    │ Devuelve JSON OK │
    └────┬─────────────┘
         │
         ▼
    ┌────────────────────┐
    │Muestra confirmación│
    │ " Compra realizada │
    │  Número: DS-..."   │
    └────┬───────────────┘
         │
         ▼
    ┌──────────────────┐
    │ Limpia carrito   │
    │ Redirige a cat.  │
    └──────────────────┘
```

---

##  Estructura de Datos MySQL

### Tabla: `usuarios`
```sql
CREATE TABLE usuarios (
  id_usuario INT PRIMARY KEY AUTO_INCREMENT
  nombre_usuario VARCHAR(100)
  correo_usuario VARCHAR(120) UNIQUE -- Email único
  contraseña VARCHAR(255)            -- Hasheada (bcrypt)
  telefono VARCHAR(20)
  domicilio VARCHAR(255)
  estado ENUM('activo', 'inactivo') DEFAULT 'activo'
  fecha_registro TIMESTAMP
  fecha_ultimo_acceso TIMESTAMP
);
```

### Tabla: `pedidos`
```sql
CREATE TABLE pedidos (
  id_pedido INT PRIMARY KEY AUTO_INCREMENT
  id_usuario INT FOREIGN KEY → usuarios
  numero_referencia VARCHAR(100)     -- DS-1234567890
  fecha_pedido TIMESTAMP
  total_pedido DECIMAL(10,2)
  metodo_pago ENUM('tarjeta', 'paypal', 'transferencia', 'oxxo')
  estado_pedido ENUM('pendiente', 'confirmado', 'enviado', 'entregado')
  codigo_oxxo VARCHAR(50) NULL       -- Para pagos en OXXO
  telefono VARCHAR(20)
  domicilio VARCHAR(255)
);
```

### Tabla: `detalle_pedido`
```sql
CREATE TABLE detalle_pedido (
  id_detalle INT PRIMARY KEY AUTO_INCREMENT
  id_pedido INT FOREIGN KEY → pedidos
  id_producto INT FOREIGN KEY → productos
  cantidad INT
  precio_unitario DECIMAL(10,2)
  subtotal DECIMAL(10,2) -- Calculado automáticamente
);
```

---

##  Pruebas

### Test 1: Compra SIN estar autenticado
1. Abre http://localhost/datastorm
2. Agrega un producto al carrito
3. Haz click en carrito → "Proceder al pago"
4. Click en "Confirmar Compra" **sin estar logueado**
5.  Debe mostrar: ` Debes iniciar sesión...`
6.  Debe abrir modal de login

### Test 2: Compra CON estar autenticado
1. Crea una cuenta o inicia sesión
2. Agrega productos
3. Procede al checkout
4. Completa el formulario de compra
5. Click en "Confirmar Compra"
6.  Debe procesar la compra
7.  Debe guardarse en MySQL
8.  Debe mostrar: ` ¡Compra realizada! Número: DS-...`

### Test 3: Verificar conexión MySQL
```bash
curl http://localhost/datastorm/api/estado.php

# Respuesta exitosa:
{
  "success": true,
  "estado": "conectado",
  "base_datos": "datastorm",
  "servidor": "localhost"
}
```

### Test 4: Verificar guardado de pedido
```bash
mysql -u root -D datastorm -e "SELECT * FROM pedidos LIMIT 1;"
```

---

##  Troubleshooting

| Problema | Solución |
|----------|----------|
| "No hay conexión a MySQL" | Verifica que MySQL está corriendo. Revisa credenciales en api/*.php |
| "Debes iniciar sesión" incluso autenticado | Revisa que `getUser()` retorna datos. Abre DevTools F12 → Consola |
| Pedido no aparece en MySQL | Revisa tabla pedidos. Verifica POST en Network (F12) |
| Error: "Campo requerido faltante" | Completa todos los campos del formulario de compra |
| CORS error | El servidor web necesita soporte de CORS. Las cabeceras ya están incluidas en api/*.php |

---

##  Próximas Mejoras

- [ ] Confirmar pedido por email
- [ ] Integración con Stripe/PayPal API
- [ ] Rastreo de envíos en tiempo real
- [ ] Dashboard de administrador
- [ ] Reporte de ventas
- [ ] Recuperación de carrito abandonado

---

##  Soporte

Para preguntas sobre:
- **Autenticación:** Revisa `assets/js/auth.js`
- **Pedidos:** Revisa `assets/js/pedidos.js`
- **MySQL:** Revisa `sql/datastorm_mysql.sql`
- **API:** Revisa `api/guardar-pedido.php`

