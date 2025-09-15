const s = (sel) => document.querySelector(sel);
let TOKEN = null;
let API = window.__CONFIG__.BACKEND_URL;

async function api(path, opts = {}) {
  const res = await fetch(`${API}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(TOKEN ? { Authorization: `Bearer ${TOKEN}` } : {}),
    },
    ...opts,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(JSON.stringify(data));
  return data;
}

async function loadClients() {
  const clients = await api("/clients");
  const sel = s("#clientSelect");
  sel.innerHTML = clients.map(c => `<option value="${c.id}">${c.name} (${c.id})</option>`).join("");
}

async function loadIncidents() {
  const incidents = await api("/incidents");
  s("#incidentsList").innerHTML = incidents
    .map(i => `<li><b>${i.id}</b> [${i.client_id}] ${i.severity} - ${i.title}</li>`)
    .join("");
}

async function loadTicketsForSelected() {
  const cid = s("#clientSelect").value;
  const tickets = await api(`/clients/${cid}/tickets`);
  s("#ticketsList").innerHTML = tickets
    .map(t => `<li>#${t.id} — incident: <b>${t.incident_id}</b> — ${t.status}</li>`)
    .join("");
}

async function login() {
  const username = s("#u").value.trim();
  const password = s("#p").value.trim();
  try {
    const { token } = await api("/login", { method: "POST", body: JSON.stringify({ username, password }) });
    TOKEN = token;
    s("#loginStatus").textContent = "✅ logged in";
  } catch (e) {
    s("#loginStatus").textContent = "❌ login failed";
  }
}

async function createTicket() {
  const client_id = s("#newClientId").value.trim();
  const incident_id = s("#newIncidentId").value.trim();
  try {
    const t = await api("/tickets", { method: "POST", body: JSON.stringify({ client_id, incident_id }) });
    s("#createTicketResult").textContent = JSON.stringify(t, null, 2);
  } catch (e) {
    s("#createTicketResult").textContent = e.message;
  }
}

document.addEventListener("DOMContentLoaded", async () => {
  await loadClients();
  await loadIncidents();
  s("#loginBtn").onclick = login;
  s("#loadTicketsBtn").onclick = loadTicketsForSelected;
  s("#createTicketBtn").onclick = createTicket;
});
