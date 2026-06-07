/**
 * app.js — Lógica del index.html (v2)
 */

document.addEventListener('DOMContentLoaded', () => {
  renderCategorias();
  renderStats();
  iniciarBusqueda();
});

function renderCategorias() {
  const grid = document.getElementById('catGrid');
  if (!grid) return;
  const categorias = DB.getCategorias();
  grid.innerHTML = categorias.map(cat => {
    const problemas = DB.getProblemas(cat.id);
    return `
      <div class="cat-card" onclick="irADiagnostico(${cat.id})">
        <span class="cat-icon">${cat.icono}</span>
        <div class="cat-name">${cat.nombre}</div>
        <div class="cat-count">${problemas.length} problema${problemas.length !== 1 ? 's' : ''}</div>
      </div>`;
  }).join('');
}

function renderStats() {
  const stats = DB.getStats();
  animateCounter('statSoluciones', stats.soluciones);
  animateCounter('statCategorias', stats.categorias);
  animateCounter('statProblemas',  stats.problemas);
}

function animateCounter(id, target) {
  const el = document.getElementById(id);
  if (!el) return;
  let current = 0;
  const step = Math.ceil(target / 40);
  const timer = setInterval(() => {
    current += step;
    if (current >= target) { current = target; clearInterval(timer); }
    el.textContent = current;
  }, 30);
}

function iniciarBusqueda() {
  const input = document.getElementById('searchGlobal');
  const resultados = document.getElementById('searchResultados');
  if (!input) return;
  input.addEventListener('input', () => {
    const t = input.value.trim();
    if (t.length < 2) { resultados.style.display = 'none'; return; }
    const encontrados = DB.buscarProblemas(t).slice(0, 6);
    if (!encontrados.length) { resultados.innerHTML = '<div class="sr-item">Sin resultados</div>'; resultados.style.display='block'; return; }
    const cats = DB.getCategorias();
    resultados.innerHTML = encontrados.map(p => {
      const cat = cats.find(c => c.id === p.categoria_id);
      return `<div class="sr-item" onclick="irADiagnosticoProblema(${p.categoria_id},${p.id})">
        <span class="sr-cat">${cat ? cat.icono + ' ' + cat.nombre : ''}</span>
        <span class="sr-prob">${p.nombre}</span>
      </div>`;
    }).join('');
    resultados.style.display = 'block';
  });
  document.addEventListener('click', e => {
    if (!e.target.closest('#searchWrap')) resultados.style.display = 'none';
  });
}

function irADiagnostico(categoriaId) {
  sessionStorage.setItem('ts_preselect_cat', categoriaId);
  window.location.href = 'views/diagnostico.html';
}

function irADiagnosticoProblema(catId, probId) {
  sessionStorage.setItem('ts_preselect_cat', catId);
  sessionStorage.setItem('ts_preselect_prob', probId);
  window.location.href = 'views/diagnostico.html';
}
