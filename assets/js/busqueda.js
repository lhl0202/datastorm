function toggleSearch(){
  const box = document.getElementById('search-box');
  if(!box) return;
  box.classList.toggle('open');
  if(box.classList.contains('open')){
    setTimeout(() => document.getElementById('search-input')?.focus(), 100);
    document.addEventListener('click', cerrarSearch, { once: true });
  }
}

function cerrarSearch(e){
  const box = document.getElementById('search-box');
  if(!box) return;
  if(!box.contains(e.target) && e.target.id !== 'search-btn'){
    box.classList.remove('open');
  }
}

function buscar(q){
  const res = document.getElementById('search-results');
  if(!res) return;
  if(!q.trim()){
    res.innerHTML = '<div class="search-empty">Escribe para buscar…</div>';
    return;
  }
  const kw = q.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  const hits = PRODUCTOS.filter(p => {
    const hay = (p.nombre + ' ' + p.specs + ' ' + p.cat).toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    return kw.split(' ').every(w => hay.includes(w));
  });
  if(!hits.length){
    res.innerHTML = '<div class="search-empty">Sin resultados para "' + q + '"</div>';
    return;
  }
  res.innerHTML = hits.map(p => `
    <div class="search-item" onclick="location.href='producto.html?id=${p.id}'; cerrarSearch({target:document.body})">
      <img src="${getImagePath(p.image)}" alt="${p.nombre}" style="width:50px; height:50px; object-fit:contain; border-radius:4px; background:var(--bg3); padding:2px;" onerror="this.style.display='none';">
      <div class="search-item-info">
        <div class="search-item-name">${p.nombre}</div>
        <div class="search-item-cat">${p.cat}</div>
      </div>
      <span class="search-item-price">$${p.precio.toLocaleString('es-MX')}</span>
    </div>
  `).join('');
}