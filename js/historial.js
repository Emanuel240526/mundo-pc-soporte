/**
 * historial.js — Gestión del historial de consultas
 */

let todasConsultas = [];

document.addEventListener('DOMContentLoaded', () => {
  todasConsultas = DB.getConsultas();
  poblarFiltro();
  renderTabla(todasConsultas);
});

function poblarFiltro() {
  const select = document.getElementById('catFilter');
  const cats = [...new Set(todasConsultas.map(c => c.categoria))];
  cats.forEach(cat => {
    const opt = document.createElement('option');
    opt.value = cat;
    opt.textContent = cat;
    select.appendChild(opt);
  });
}

function renderTabla(consultas) {
  const body = document.getElementById('historialBody');
  const empty = document.getElementById('emptyState');

  if (consultas.length === 0) {
    body.innerHTML = '';
    empty.style.display = 'block';
    return;
  }

  empty.style.display = 'none';
  const sevClass = { 'Leve': 'badge-leve', 'Moderado': 'badge-medio', 'Crítico': 'badge-critico' };
  const resueltoLabel = { true: '✅ Resuelto', false: '❌ No resuelto', null: '— Pendiente' };

  body.innerHTML = consultas.map((c, i) => `
    <tr>
      <td style="color:var(--text-dim)">${c.id}</td>
      <td>${c.fecha}</td>
      <td>${c.categoria}</td>
      <td>${c.problema}</td>
      <td><span class="badge ${sevClass[c.severidad] || ''}">${c.severidad}</span></td>
      <td>${resueltoLabel[c.resuelto] ?? '— Pendiente'}</td>
      <td>
        ${c.solucion_id
          ? `<button class="btn-ghost" style="padding:4px 10px;font-size:0.75rem" onclick="verGuia(${c.solucion_id})">Ver guía</button>`
          : '<span style="color:var(--text-dim);font-size:0.8rem">Sin solución</span>'
        }
      </td>
    </tr>
  `).join('');
}

function filtrarHistorial() {
  const texto = document.getElementById('searchInput').value.toLowerCase();
  const cat = document.getElementById('catFilter').value;

  const filtradas = todasConsultas.filter(c => {
    const matchTexto = !texto || c.problema.toLowerCase().includes(texto) || c.categoria.toLowerCase().includes(texto);
    const matchCat = !cat || c.categoria === cat;
    return matchTexto && matchCat;
  });

  renderTabla(filtradas);
}

function verGuia(solId) {
  sessionStorage.setItem('ts_solucion_id', solId);
  window.location.href = 'guia.html';
}

function limpiarHistorial() {
  if (confirm('¿Eliminar todo el historial? Esta acción no se puede deshacer.')) {
    DB.clearConsultas();
    todasConsultas = [];
    renderTabla([]);
  }
}
