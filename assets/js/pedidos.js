/**
 * Módulo de Pedidos - Gestión de órdenes con MySQL
 * Maneja el guardado de pedidos en la base de datos
 */

// Guardar pedido en MySQL
function guardarPedidoSQL(datoPedido) {
  try {
    // Construir objeto con datos de la compra
    const pedido = {
      id_pedido: datoPedido.id_pedido,
      usuario: datoPedido.usuario,
      correo: datoPedido.correo,
      telefono: datoPedido.telefono,
      domicilio: datoPedido.domicilio,
      total: datoPedido.total,
      metodo_pago: datoPedido.metodo_pago,
      carrito: datoPedido.carrito,
      fecha_pedido: new Date().toISOString(),
      estado: 'pendiente'
    };

    // Guardar en sessionStorage como respaldo local
    const pedidosGuardados = JSON.parse(sessionStorage.getItem('ds_pedidos')) || [];
    pedidosGuardados.push(pedido);
    sessionStorage.setItem('ds_pedidos', JSON.stringify(pedidosGuardados));

    // Enviar a servidor MySQL
    enviarPedidoAlServidor(pedido);

    return true;
  } catch(error) {
    console.error('Error al guardar pedido:', error);
    return false;
  }
}

// Enviar pedido al servidor MySQL
function enviarPedidoAlServidor(pedido) {
  const usuario = getUser();
  
  if (!usuario || !usuario.correo) {
    console.error('Usuario no autenticado');
    return;
  }

  // Preparar datos para enviar al servidor
  const datosEnvio = {
    numero_referencia: pedido.id_pedido,
    correo_usuario: usuario.correo,
    telefono: pedido.telefono,
    domicilio: pedido.domicilio,
    total_pedido: pedido.total,
    metodo_pago: pedido.metodo_pago,
    estado_pedido: 'pendiente',
    carrito: pedido.carrito
  };

  // Enviar a API PHP/Node que conecta con MySQL
  fetch('../api/guardar-pedido.php', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(datosEnvio)
  })
  .then(response => {
    if (!response.ok) throw new Error('Error en respuesta del servidor');
    return response.json();
  })
  .then(data => {
    if(data.success) {
      console.log('✅ Pedido guardado en MySQL:', data.id_pedido);
      // Guardar ID de pedido en MySQL para referencia posterior
      sessionStorage.setItem('ds_ultimo_pedido', JSON.stringify(data));
    } else {
      console.error('Error al guardar pedido:', data.error);
      mostrarMensaje('⚠️ ' + (data.error || 'Error al procesar pedido'), 'error');
    }
  })
  .catch(error => {
    console.warn('📡 Conexión offline - Pedido guardado localmente:', error.message);
    // El pedido ya está guardado en sessionStorage
  });
}

// Obtener historial de pedidos del usuario
function obtenerPedidosUsuario(correoUsuario) {
  try {
    const pedidosGuardados = JSON.parse(sessionStorage.getItem('ds_pedidos')) || [];
    const misPedidos = pedidosGuardados.filter(p => p.correo === correoUsuario);
    return misPedidos;
  } catch(error) {
    console.error('Error al obtener pedidos:', error);
    return [];
  }
}

// Obtener detalles de un pedido específico
function obtenerDetallePedido(idPedido) {
  try {
    const pedidosGuardados = JSON.parse(sessionStorage.getItem('ds_pedidos')) || [];
    return pedidosGuardados.find(p => p.id_pedido === idPedido) || null;
  } catch(error) {
    console.error('Error al obtener detalle:', error);
    return null;
  }
}

// Actualizar estado de pedido
function actualizarEstadoPedido(idPedido, nuevoEstado) {
  try {
    const pedidosGuardados = JSON.parse(sessionStorage.getItem('ds_pedidos')) || [];
    const pedido = pedidosGuardados.find(p => p.id_pedido === idPedido);
    
    if(pedido) {
      pedido.estado = nuevoEstado;
      sessionStorage.setItem('ds_pedidos', JSON.stringify(pedidosGuardados));
      return true;
    }
    return false;
  } catch(error) {
    console.error('Error al actualizar estado:', error);
    return false;
  }
}

// Verificar conexión al servidor MySQL
function verificarConexionSQL() {
  return fetch('../api/estado.php', {
    method: 'GET'
  })
  .then(response => {
    if (response.ok) {
      console.log('✅ Conexión MySQL OK');
      return true;
    }
    return false;
  })
  .catch(error => {
    console.warn('⚠️ Servidor SQL no disponible (modo offline)');
    return false;
  });
}

