(function(){
  const canvas = document.getElementById('particles-canvas');
  if(!canvas) return;
  const ctx = canvas.getContext('2d');
  let W, H, particles = [];
  function resize(){ W = canvas.width = innerWidth; H = canvas.height = innerHeight; }
  resize();
  window.addEventListener('resize', resize);
  function rand(a,b){ return Math.random()*(b-a)+a; }
  for(let i=0;i<160;i++){
    particles.push({
      x: rand(0, innerWidth), y: rand(0, innerHeight),
      r: rand(.5, 2.2),
      vx: rand(-.25, .25), vy: rand(-.15, .15),
      a: rand(.3, 1)
    });
  }
  function draw(){
    ctx.clearRect(0, 0, W, H);
    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI*2);
      ctx.fillStyle = `rgba(255,255,255,${p.a})`;
      ctx.fill();
      p.x += p.vx; p.y += p.vy;
      if(p.x < 0) p.x = W; if(p.x > W) p.x = 0;
      if(p.y < 0) p.y = H; if(p.y > H) p.y = 0;
    });
    requestAnimationFrame(draw);
  }
  draw();
})();

function getImagePath(imageName) {
  const currentPath = window.location.pathname;
  if (currentPath.includes('/pages/')) {
    return `../assets/image/${imageName}`;
  }
  return `assets/image/${imageName}`;
}

function toast(msg){
  let t = document.getElementById('toast');
  if(!t){
    t = document.createElement('div');
    t.id = 'toast';
    document.body.appendChild(t);
  }
  t.textContent = msg;
  t.style.opacity = '1';
  clearTimeout(t._timer);
  t._timer = setTimeout(() => t.style.opacity = '0', 2400);
}

function setupScrollReveal(){
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e, i) => {
      if(e.isIntersecting){
        setTimeout(() => e.target.classList.add('visible'), i * 80);
        io.unobserve(e.target);
      }
    });
  }, { threshold: .12 });
  document.querySelectorAll('.product-card').forEach(c => io.observe(c));
  const revealIO = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if(e.isIntersecting){
        e.target.classList.add('visible');
        revealIO.unobserve(e.target);
      }
    });
  }, { threshold: .1 });
  document.querySelectorAll('.reveal').forEach(el => revealIO.observe(el));
}

function setupMarquee(){
  const msg = '🚀 ENVÍO GRATIS EN TODAS LAS PCs &nbsp;&nbsp;·&nbsp;&nbsp; 🛡 GARANTÍA INCLUIDA &nbsp;&nbsp;·&nbsp;&nbsp; ⚡ STOCK DISPONIBLE &nbsp;&nbsp;·&nbsp;&nbsp; 🇲🇽 SOLO ENVÍOS EN MÉXICO &nbsp;&nbsp;·&nbsp;&nbsp; 💳 HASTA 12 MESES SIN INTERESES &nbsp;&nbsp;·&nbsp;&nbsp;';
  const t = document.getElementById('marquee-track');
  if(t) t.innerHTML = `<span>${msg}</span><span>${msg}</span>`;
}

setupMarquee();