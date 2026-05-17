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
