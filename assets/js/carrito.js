let carrito = JSON.parse(sessionStorage.getItem('ds_cart') || '[]');

function guardarCarrito(){ 
  sessionStorage.setItem('ds_cart', JSON.stringify(carrito)); 
  updateBadge(); 
}

function updateBadge(){ 
  const n = carrito.reduce((s, i) => s + i.qty, 0); 
  document.querySelectorAll('#cart-count').forEach(el => el.textContent = n); 
}

function agregarCarrito(id){
  const p = PRODUCTOS.find(x => x.id === id);
  if(!p) return;
  const item = carrito.find(x => x.id === id);
  if(item) { 
    item.qty++; 
  } else { 
    carrito.push({ ...p, qty: 1 }); 
  }
  guardarCarrito();
  toast(`✅ ${p.nombre.split('/')[0].trim()} agregado al carrito`);
}

function quitarDelCarrito(id){ 
  carrito = carrito.filter(i => i.id !== id); 
  guardarCarrito(); 
}

function cambiarCantidad(id, nueva){
  const item = carrito.find(i => i.id === id);
  if(item){
    item.qty = nueva;
    if(item.qty <= 0) quitarDelCarrito(id);
    guardarCarrito();
  }
}

updateBadge();