(function checkAuth() {
  if (!localStorage.getItem('loggedIn') && !window.location.pathname.endsWith('login.html')) {
    window.location.href = 'login.html';
  }
})();

function logout() {
  localStorage.removeItem('loggedIn');
  window.location.href = 'login.html';
}

const API_BASE = "http://localhost:5000/api";

async function loadData() {
  const res = await fetch(API_BASE);
  return res.json();
}

function renderTable(targetId, rows, columns) {
  const el = document.getElementById(targetId);
  if (!el) return;
  if (!rows || rows.length === 0) { el.innerHTML = "<p style='padding:15px;color:#8b95a7;'>No records found.</p>"; return; }
  let html = "<table><thead><tr>";
  columns.forEach(c => html += `<th>${c.label}</th>`);
  html += "</tr></thead><tbody>";
  rows.forEach(r => {
    html += "<tr>";
    columns.forEach(c => {
      let val = r[c.key];
      if (val === null || val === undefined) val = '-';
      if (c.badge) val = `<span class="badge ${val}">${val}</span>`;
      if (c.render) val = c.render(r);
      html += `<td>${val}</td>`;
    });
    html += "</tr>";
  });
  html += "</tbody></table>";
  el.innerHTML = html;
}

async function init() {
  try {
    const data = await loadData();
    
    const nameEl = document.getElementById('user-name');
    if (nameEl) nameEl.textContent = localStorage.getItem('username') || 'Admin';

    if (document.getElementById('card-processes')) {
      document.getElementById('card-processes').textContent = data.processes.length;
      document.getElementById('card-files').textContent = data.file_events.length;
      document.getElementById('card-network').textContent = data.network_events.length;
      document.getElementById('card-alerts').textContent = data.alerts.length;
    }

    renderTable('processes-table', data.processes, [
      {key:'pid', label:'PID'}, {key:'process_name', label:'Process'}, {key:'parent_pid', label:'PPID'}, {key:'username', label:'User'}, {key:'status', label:'Status', badge:true}
    ]);
    renderTable('files-table', data.file_events, [
      {key:'event_id', label:'ID'}, {key:'file_path', label:'File Path'}, {key:'event_type', label:'Event', badge:true}, {key:'timestamp', label:'Timestamp'}
    ]);
    renderTable('network-table', data.network_events, [
      {key:'event_id', label:'ID'}, {key:'local_ip', label:'Local IP'}, {key:'remote_ip', label:'Remote IP'}, {key:'remote_port', label:'Port'}, {key:'timestamp', label:'Time'}
    ]);
    renderTable('alerts-table', data.alerts, [
      {key:'rule_name', label:'Rule'}, {key:'severity', label:'Severity', badge:true}, {key:'description', label:'Description'}, {key:'timestamp', label:'Timestamp'}
    ]);
    renderTable('timeline-table', data.timeline, [
      {key:'event_time', label:'Time'}, {key:'severity', label:'Severity', badge:true}, {key:'rule_name', label:'Rule'}, {key:'process_name', label:'Process'}, {key:'description', label:'Details'}
    ]);
  } catch (err) {
    console.error("Failed to load live data", err);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  init(); 
  
  
  setInterval(() => {
    if (window.location.pathname.includes('.html') && !window.location.pathname.includes('login')) {
      init();
    }
  }, 2000); 
});