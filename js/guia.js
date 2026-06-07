/**
 * guia.js — Renderiza la guía de solución completa (v2)
 */
document.addEventListener('DOMContentLoaded', () => {
  const solId = parseInt(sessionStorage.getItem('ts_solucion_id'));
  if (!solId) {
    document.querySelector('.guia-header h1').textContent = 'Solución no encontrada';
    return;
  }
  const sol = DB.getSolucionById(solId);
  if (!sol) { document.querySelector('.guia-header h1').textContent = 'No encontrada en la base de datos'; return; }

  const problema  = DB.getProblemas().find(p => p.id === sol.problema_id);
  const categoria = problema ? DB.getCategorias().find(c => c.id === problema.categoria_id) : null;

  document.getElementById('guiaCategoria').textContent = categoria ? `${categoria.icono} ${categoria.nombre}` : 'Soporte Técnico';
  document.getElementById('guiaTitulo').textContent    = sol.titulo;
  const difLabel = { facil:'✅ Fácil', medio:'⚠️ Medio', avanzado:'🔴 Avanzado', experto:'💀 Experto' };
  document.getElementById('guiaDificultad').textContent = `Dificultad: ${difLabel[sol.dificultad] || sol.dificultad}`;
  document.getElementById('guiaTiempo').textContent     = `⌛ Tiempo estimado: ${sol.tiempo_minutos} minutos`;

  // Badges
  const badges = [];
  if (sol.requiere_reinicio) badges.push('🔄 Requiere reinicio');
  if (sol.requiere_admin)    badges.push('🛡 Necesita permisos de administrador');
  if (badges.length) {
    const div = document.createElement('div');
    div.className = 'sol-badges';
    div.innerHTML = badges.map(b=>`<span class="sol-badge">${b}</span>`).join('');
    document.getElementById('guiaTitulo').after(div);
  }

  // Resumen
  if (sol.resumen) {
    const r = document.createElement('p');
    r.className = 'sol-resumen'; r.style.marginBottom = '24px';
    r.textContent = sol.resumen;
    document.getElementById('stepsList').before(r);
  }

  // Pasos
  document.getElementById('stepsList').innerHTML = sol.pasos.map((p,i) => `
    <div class="step-item">
      <div class="step-num-badge">${i+1}</div>
      <div class="step-item-text">${p}</div>
    </div>`).join('');

  // Herramientas
  const tl = document.getElementById('toolsList');
  tl.innerHTML = (sol.herramientas && sol.herramientas.length)
    ? sol.herramientas.map(h=>`<li>${h}</li>`).join('')
    : '<li>No se requieren herramientas adicionales.</li>';

  // Comandos
  if (sol.comandos && sol.comandos.length) {
    const sec = document.createElement('div');
    sec.className = 'tools-section';
    sec.innerHTML = `<h3>💻 Comandos útiles</h3><div class="cmd-block">${sol.comandos.map(c=>`<code>${c}</code>`).join('')}</div>`;
    document.querySelector('.notas-section').before(sec);
  }

  // Advertencias
  if (sol.advertencias && sol.advertencias.length) {
    const sec = document.createElement('div');
    sec.className = 'tools-section';
    sec.style.borderLeft = '3px solid var(--accent2)';
    sec.innerHTML = `<h3 style="color:var(--accent2)">⚠️ Advertencias</h3><ul>${sol.advertencias.map(a=>`<li style="color:var(--accent2)">${a}</li>`).join('')}</ul>`;
    document.querySelector('.notas-section').before(sec);
  }

  // Notas
  if (sol.notas) {
    document.getElementById('notasSection').style.display = 'block';
    document.getElementById('notasTexto').textContent = sol.notas;
  }
});

function darFeedback(util) {
  const solId = parseInt(sessionStorage.getItem('ts_solucion_id'));
  if (solId) DB.votarSolucion(solId, util);
  const consultaId = parseInt(sessionStorage.getItem('ts_ultima_consulta'));
  if (consultaId) DB.marcarResuelta(consultaId, util);
  const msg = document.getElementById('feedbackMsg');
  msg.style.display = 'block';
  msg.textContent = util
    ? '¡Perfecto! Nos alegra que se haya resuelto el problema. 🎉'
    : 'Lamentamos que no funcionó. Puedes contactar a un técnico o revisar el Panel Admin para más soluciones.';
  document.querySelectorAll('.fb-btn').forEach(b => b.disabled = true);
}
