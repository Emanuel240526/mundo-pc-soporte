/**
 * admin.js — Panel de administración de la base de datos
 */

document.addEventListener('DOMContentLoaded', () => {
  renderListaCategorias();
  renderListaProblemas();
  renderListaSoluciones();
  poblarSelectores();
});

// =============================================
// TABS
// =============================================
function switchTab(tab) {
  document.querySelectorAll('.tab-btn').forEach((btn, i) => {
    const tabs = ['categorias', 'problemas', 'soluciones'];
    btn.classList.toggle('active', tabs[i] === tab);
  });
  document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
  document.getElementById(`tab-${tab}`).classList.add('active');
}

// =============================================
// CATEGORÍAS
// =============================================
function agregarCategoria() {
  const nombre = document.getElementById('catNombre').value.trim();
  const icono = document.getElementById('catIcono').value.trim() || '📁';

  if (!nombre) { alert('Escribe un nombre para la categoría.'); return; }

  DB.addCategoria(nombre, icono);
  document.getElementById('catNombre').value = '';
  document.getElementById('catIcono').value = '';
  renderListaCategorias();
  poblarSelectores();
}

function renderListaCategorias() {
  const lista = document.getElementById('listaCategorias');
  const cats = DB.getCategorias();
  lista.innerHTML = cats.map(c => `
    <div class="admin-item">
      <div class="admin-item-info">${c.icono} <strong>${c.nombre}</strong></div>
      <div class="admin-item-actions">
        <button class="btn-delete" onclick="eliminarCategoria(${c.id})">Eliminar</button>
      </div>
    </div>
  `).join('') || '<p style="color:var(--text-dim);font-size:0.85rem">No hay categorías.</p>';
}

function eliminarCategoria(id) {
  if (confirm('¿Eliminar esta categoría?')) {
    DB.deleteCategoria(id);
    renderListaCategorias();
    poblarSelectores();
  }
}

// =============================================
// PROBLEMAS
// =============================================
function agregarProblema() {
  const cat = document.getElementById('probCategoria').value;
  const nombre = document.getElementById('probNombre').value.trim();

  if (!cat || !nombre) { alert('Selecciona categoría y escribe el nombre del problema.'); return; }

  DB.addProblema(cat, nombre);
  document.getElementById('probNombre').value = '';
  renderListaProblemas();
  poblarSelectores();
}

function renderListaProblemas() {
  const lista = document.getElementById('listaProblemas');
  const probs = DB.getProblemas();
  const cats = DB.getCategorias();

  lista.innerHTML = probs.map(p => {
    const cat = cats.find(c => c.id === p.categoria_id);
    return `
      <div class="admin-item">
        <div class="admin-item-info">
          <span style="color:var(--text-dim);font-size:0.75rem">${cat ? cat.nombre : '—'}</span>
          <br/>${p.nombre}
        </div>
        <div class="admin-item-actions">
          <button class="btn-delete" onclick="eliminarProblema(${p.id})">Eliminar</button>
        </div>
      </div>
    `;
  }).join('') || '<p style="color:var(--text-dim);font-size:0.85rem">No hay problemas.</p>';
}

function eliminarProblema(id) {
  if (confirm('¿Eliminar este problema?')) {
    DB.deleteProblema(id);
    renderListaProblemas();
    poblarSelectores();
  }
}

// =============================================
// SOLUCIONES
// =============================================
function agregarSolucion() {
  const probId = document.getElementById('solProblema').value;
  const titulo = document.getElementById('solTitulo').value.trim();
  const pasosRaw = document.getElementById('solPasos').value.trim();
  const herramientasRaw = document.getElementById('solHerramientas').value.trim();
  const dificultad = document.getElementById('solDificultad').value;
  const tiempo = parseInt(document.getElementById('solTiempo').value) || 15;

  if (!probId || !titulo || !pasosRaw) {
    alert('Completa al menos: problema, título y pasos.');
    return;
  }

  const pasos = pasosRaw.split('\n').map(p => p.trim()).filter(Boolean);
  const herramientas = herramientasRaw ? herramientasRaw.split(',').map(h => h.trim()) : [];

  DB.addSolucion({
    problema_id: parseInt(probId),
    titulo,
    pasos,
    herramientas,
    dificultad,
    tiempo_minutos: tiempo
  });

  // Limpiar form
  ['solProblema','solTitulo','solPasos','solHerramientas','solTiempo'].forEach(id => {
    document.getElementById(id).value = '';
  });

  renderListaSoluciones();
}

function renderListaSoluciones() {
  const lista = document.getElementById('listaSoluciones');
  const sols = DB.getSoluciones();
  const probs = DB.getProblemas();
  const difLabel = { facil: '✅ Fácil', medio: '⚠️ Medio', avanzado: '🔴 Avanzado' };

  lista.innerHTML = sols.map(s => {
    const prob = probs.find(p => p.id === s.problema_id);
    return `
      <div class="admin-item">
        <div class="admin-item-info">
          <span style="color:var(--text-dim);font-size:0.75rem">${prob ? prob.nombre : '—'} · ${difLabel[s.dificultad]} · ${s.tiempo_minutos} min</span>
          <br/><strong>${s.titulo}</strong>
          <br/><span style="font-size:0.75rem;color:var(--text-dim)">${s.pasos.length} pasos</span>
        </div>
        <div class="admin-item-actions">
          <button class="btn-delete" onclick="eliminarSolucion(${s.id})">Eliminar</button>
        </div>
      </div>
    `;
  }).join('') || '<p style="color:var(--text-dim);font-size:0.85rem">No hay soluciones.</p>';
}

function eliminarSolucion(id) {
  if (confirm('¿Eliminar esta solución?')) {
    DB.deleteSolucion(id);
    renderListaSoluciones();
  }
}

// =============================================
// POBLAR SELECTORES
// =============================================
function poblarSelectores() {
  const cats = DB.getCategorias();
  const probs = DB.getProblemas();

  // Selector de categoría en tab Problemas
  const probCatSel = document.getElementById('probCategoria');
  const prevCat = probCatSel.value;
  probCatSel.innerHTML = '<option value="">Selecciona categoría</option>' +
    cats.map(c => `<option value="${c.id}" ${c.id == prevCat ? 'selected' : ''}>${c.icono} ${c.nombre}</option>`).join('');

  // Selector de problema en tab Soluciones
  const solProbSel = document.getElementById('solProblema');
  const prevProb = solProbSel.value;
  solProbSel.innerHTML = '<option value="">Selecciona problema</option>' +
    probs.map(p => `<option value="${p.id}" ${p.id == prevProb ? 'selected' : ''}>${p.nombre}</option>`).join('');
}
