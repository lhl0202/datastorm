function getUser(){ 
  try { 
    return JSON.parse(sessionStorage.getItem('ds_user')); 
  } catch { 
    return null; 
  } 
}

function setUser(u){ 
  sessionStorage.setItem('ds_user', JSON.stringify(u)); 
}

function cerrarSesion(){ 
  sessionStorage.removeItem('ds_user'); 
  renderAuth(); 
  toast('👋 Sesión cerrada'); 
}

function renderAuth(){
  const u = getUser();
  const lb = document.getElementById('auth-label');
  const dd = document.getElementById('auth-dropdown');
  if(!lb || !dd) return;
  if(u){
    const n = u.nombre || u.nombre_cliente || 'Usuario';
    lb.textContent = n.split(' ')[0];
    dd.innerHTML = `
      <div class="dd-header">
        <div class="dd-avatar">${n[0].toUpperCase()}</div>
        <div><div class="dd-name">${n}</div><div class="dd-email">${u.correo || u.correo_cliente || ''}</div></div>
      </div>
      <div class="dd-divider"></div>
      <a class="dd-item" href="#">📦 Mis pedidos</a>
      <a class="dd-item" href="#">⚙️ Mi perfil</a>
      <div class="dd-divider"></div>
      <a class="dd-item dd-logout" onclick="cerrarSesion()">← Cerrar sesión</a>`;
  } else {
    lb.textContent = 'Mi cuenta';
    dd.innerHTML = `
      <p class="dd-welcome">¡Hola! Accede a tu cuenta</p>
      <button class="dd-btn-primary" onclick="abrirModal('login')">Iniciar sesión</button>
      <button class="dd-btn-ghost" onclick="abrirModal('registro')">Crear cuenta</button>
      <div class="dd-divider"></div>
      <a class="dd-item" onclick="abrirModal('login')">📦 Mis pedidos</a>`;
  }
}

function toggleAuthMenu(e){
  e.stopPropagation();
  const dd = document.getElementById('auth-dropdown');
  if(!dd) return;
  const open = dd.classList.toggle('open');
  if(open){ 
    setTimeout(() => document.addEventListener('click', () => dd.classList.remove('open'), { once: true }), 10); 
  }
}

function abrirModal(tab){
  const dd = document.getElementById('auth-dropdown');
  if(dd) dd.classList.remove('open');
  const m = document.getElementById('auth-modal');
  if(!m) return;
  m.style.display = 'flex';
  requestAnimationFrame(() => m.classList.add('visible'));
  switchTab(tab);
}

function cerrarModal(){
  const m = document.getElementById('auth-modal');
  if(!m) return;
  m.classList.remove('visible');
  setTimeout(() => m.style.display = 'none', 250);
}

function switchTab(t){
  ['login', 'registro'].forEach(x => {
    document.getElementById('tab-' + x)?.classList.toggle('active', x === t);
    const p = document.getElementById('panel-' + x);
    if(p) p.style.display = x === t ? 'block' : 'none';
  });
  const bar = document.getElementById('tab-bar');
  if(bar) bar.style.transform = t === 'login' ? 'translateX(0)' : 'translateX(100%)';
}

function loginSubmit(){
  const c = document.getElementById('l-correo')?.value.trim();
  const p = document.getElementById('l-pass')?.value;
  if(!c || !p){ 
    toast('⚠️ Completa todos los campos'); 
    return; 
  }
  setUser({ nombre: c.split('@')[0], correo: c });
  cerrarModal();
  renderAuth();
  toast('✅ ¡Bienvenido/a de vuelta!');
}

function registroSubmit(){
  const n = document.getElementById('r-nombre')?.value.trim();
  const t = document.getElementById('r-tel')?.value.trim();
  const c = document.getElementById('r-correo')?.value.trim();
  const d = document.getElementById('r-dom')?.value.trim();
  const p = document.getElementById('r-pass')?.value;
  if(!n || !t || !c || !d || !p){ 
    toast('⚠️ Completa todos los campos'); 
    return; 
  }
  if(p.length < 6){ 
    toast('⚠️ Contraseña mínimo 6 caracteres'); 
    return; 
  }
  setUser({ nombre: n, correo: c, tel: t, domicilio: d });
  cerrarModal();
  renderAuth();
  toast(`✅ ¡Cuenta creada! Bienvenido/a, ${n.split(' ')[0]}`);
}

const modal = document.getElementById('auth-modal');
if(modal){ 
  modal.addEventListener('click', e => { 
    if(e.target === modal) cerrarModal(); 
  }); 
}
renderAuth();