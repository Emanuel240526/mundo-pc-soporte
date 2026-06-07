/**
 * diagnostico.js — Flujo de diagnóstico (v2)
 */

let estado = { paso:1, categoria_id:null, problema_id:null, severidad:null, solucion:null };

document.addEventListener('DOMContentLoaded', () => {
  renderCategorias();
  const precat  = sessionStorage.getItem('ts_preselect_cat');
  const preprob = sessionStorage.getItem('ts_preselect_prob');
  if (precat) {
    sessionStorage.removeItem('ts_preselect_cat');
    setTimeout(() => {
      seleccionarCategoria(parseInt(precat), false);
      if (preprob) {
        sessionStorage.removeItem('ts_preselect_prob');
        setTimeout(() => seleccionarProblema(parseInt(preprob), false), 100);
      }
    }, 100);
  }
});

// ---- PASO 1: Categorías ----
function renderCategorias() {
  const grid = document.getElementById('categoriaGrid');
  grid.innerHTML = DB.getCategorias().map(cat => `
    <button class="option-btn" onclick="seleccionarCategoria(${cat.id})" data-id="${cat.id}">
      <span class="option-icon">${cat.icono}</span>${cat.nombre}
    </button>`).join('');
}

function seleccionarCategoria(id, animar = true) {
  estado.categoria_id = id;
  document.querySelectorAll('#categoriaGrid .option-btn').forEach(b =>
    b.classList.toggle('selected', parseInt(b.dataset.id) === id));
  renderProblemas(id);
  if (animar) setTimeout(() => irAPaso(2), 200); else irAPaso(2);
}

// ---- PASO 2: Problemas ----
function renderProblemas(categoria_id) {
  const grid = document.getElementById('problemaGrid');
  const probs = DB.getProblemas(categoria_id);
  if (!probs.length) {
    grid.innerHTML = '<p style="color:var(--text-dim);grid-column:1/-1">No hay problemas registrados para esta categoría.</p>';
    return;
  }
  grid.innerHTML = probs.map(p => `
    <button class="option-btn" onclick="seleccionarProblema(${p.id})" data-id="${p.id}">
      ${p.nombre}
    </button>`).join('');
}

function seleccionarProblema(id, animar = true) {
  estado.problema_id = id;
  document.querySelectorAll('#problemaGrid .option-btn').forEach(b =>
    b.classList.toggle('selected', parseInt(b.dataset.id) === id));
  if (animar) setTimeout(() => irAPaso(3), 200); else irAPaso(3);
}

// ---- PASO 3: Severidad ----
function selectSeveridad(nivel) {
  estado.severidad = nivel;
  document.querySelectorAll('.sev-btn').forEach(b =>
    b.classList.toggle('selected', parseInt(b.dataset.sev) === nivel));
  buscarSolucion();
  setTimeout(() => irAPaso(4), 400);
}

// ---- BÚSQUEDA EN BD ----
function buscarSolucion() {
  const sols = DB.getSoluciones(estado.problema_id);
  if (!sols.length) { estado.solucion = null; mostrarSinSolucion(); return; }
  let sol;
  if (estado.severidad >= 3)      sol = sols.find(s => s.dificultad === 'experto' || s.dificultad === 'avanzado') || sols[sols.length-1];
  else if (estado.severidad === 1) sol = sols.find(s => s.dificultad === 'facil') || sols[0];
  else                             sol = sols[0];
  estado.solucion = sol;
  mostrarResultado(sol);
}

function mostrarResultado(sol) {
  const box = document.getElementById('resultadoBox');
  const difLabel = { facil:'✅ Fácil', medio:'⚠️ Medio', avanzado:'🔴 Avanzado', experto:'💀 Experto' };
  const sevLabel = ['','Leve','Moderado','Crítico'];
  const badges = [];
  if (sol.requiere_reinicio) badges.push('<span class="sol-badge">🔄 Requiere reinicio</span>');
  if (sol.requiere_admin)    badges.push('<span class="sol-badge">🛡 Admin requerido</span>');
  box.innerHTML = `
    <h3>${sol.titulo}</h3>
    <p class="sol-resumen">${sol.resumen || ''}</p>
    <div class="sol-meta">
      <span>${difLabel[sol.dificultad] || sol.dificultad}</span>
      <span>⌛ ${sol.tiempo_minutos} min aprox.</span>
      <span>🎚 ${sevLabel[estado.severidad]}</span>
    </div>
    <div class="sol-badges">${badges.join('')}</div>
    <ol class="sol-pasos">
      ${sol.pasos.slice(0,3).map(p=>`<li>${p}</li>`).join('')}
      ${sol.pasos.length>3?`<li style="color:var(--accent)">… y ${sol.pasos.length-3} pasos más en la guía completa</li>`:''}
    </ol>
    ${sol.advertencias && sol.advertencias.length ? `
      <div class="sol-warn">⚠️ ${sol.advertencias[0]}</div>` : ''}`;
  sessionStorage.setItem('ts_solucion_id', sol.id);
  if (estado.severidad === 3) {
    const a = document.getElementById('alertCritico');
    if (a) a.style.display = 'block';
  }
}

function mostrarSinSolucion() {
  document.getElementById('resultadoBox').innerHTML = `
    <h3 style="color:var(--accent3)">⚠️ Sin solución registrada</h3>
    <p style="color:var(--text-mid);font-size:0.9rem">Aún no hay guía para este problema.
    Puedes agregarla desde el <a href="admin.html">Panel Admin</a>.</p>`;
}

// ---- NAVEGACIÓN ----
function irAPaso(paso) {
  document.querySelectorAll('.step-card').forEach(c => c.classList.remove('active'));
  document.getElementById(`step${paso}`).classList.add('active');
  estado.paso = paso;
  const pct = {1:'25%',2:'50%',3:'75%',4:'100%'};
  document.getElementById('progressBar').style.width = pct[paso];
  document.getElementById('progressLabel').textContent = `Paso ${paso} de 4`;
}

function goBack(paso) { irAPaso(paso); }

function reiniciar() {
  estado = {paso:1,categoria_id:null,problema_id:null,severidad:null,solucion:null};
  document.querySelectorAll('.option-btn,.sev-btn').forEach(b=>b.classList.remove('selected'));
  document.getElementById('resultadoBox').innerHTML='';
  const a=document.getElementById('alertCritico'); if(a) a.style.display='none';
  irAPaso(1);
}

function guardarConsulta() {
  if (!estado.categoria_id||!estado.problema_id||!estado.severidad) { alert('Completa el diagnóstico primero.'); return; }
  const sevLabel=['','Leve','Moderado','Crítico'];
  const c = DB.addConsulta(estado.categoria_id, estado.problema_id, sevLabel[estado.severidad], estado.solucion?estado.solucion.id:null);
  sessionStorage.setItem('ts_ultima_consulta', c.id);
  const btn=document.querySelector('[onclick="guardarConsulta()"]');
  if(btn){btn.textContent='✓ Guardado';btn.disabled=true;}
}
