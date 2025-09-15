import os, json, time, glob
from flask import Flask, request, jsonify
from flask_cors import CORS
import jwt
from datetime import datetime, timedelta

SECRET = os.getenv("FLASK_SECRET", "devsecret")
PORT   = int(os.getenv("BACKEND_PORT", "5000"))

app = Flask(__name__)
CORS(app)  # permitir CORS desde el frontend local

# "Base de datos" simple en ficheros dentro del volumen
BASE = "/backend"  # aquí viven app.py y los JSON
DATA_DIR = os.path.join(BASE, "data")
INC_DIR  = os.path.join(DATA_DIR, "incidents")
FILES = {
    "clients": os.path.join(DATA_DIR, "clients.json"),
    "tickets": os.path.join(DATA_DIR, "tickets.json"),
    "users":   os.path.join(DATA_DIR, "users.json"),
}

def ensure_data():
    os.makedirs(INC_DIR, exist_ok=True)
    # Inicializa clientes
    if not os.path.exists(FILES["clients"]):
        with open(FILES["clients"], "w") as f:
            json.dump([
                {"id":"acme", "name":"ACME Corp"},
                {"id":"globex","name":"Globex"},
            ], f)
    # Inicializa tickets
    if not os.path.exists(FILES["tickets"]):
        with open(FILES["tickets"], "w") as f:
            json.dump([], f)
    # Inicializa usuarios (DEMO: plaintext, ¡no en prod!)
    if not os.path.exists(FILES["users"]):
        with open(FILES["users"], "w") as f:
            json.dump([{"username":"admin","password":"admin"}], f)
    # Incidentes de ejemplo si está vacío
    if len(glob.glob(os.path.join(INC_DIR, "*.json"))) == 0:
        sample1 = {"id":"inc-1","client_id":"acme","severity":"HIGH","title":"Intento de acceso","timestamp":"2025-09-15T10:00:00Z"}
        sample2 = {"id":"inc-2","client_id":"globex","severity":"CRITICAL","title":"Malware detectado","timestamp":"2025-09-15T11:30:00Z"}
        with open(os.path.join(INC_DIR, "inc-1.json"), "w") as f: json.dump(sample1, f)
        with open(os.path.join(INC_DIR, "inc-2.json"), "w") as f: json.dump(sample2, f)

def read_json(path, default=None):
    if not os.path.exists(path):
        return default
    with open(path) as f:
        return json.load(f)

def write_json(path, data):
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f)
    os.replace(tmp, path)

def token_for(user):
    payload = {"sub": user, "exp": datetime.utcnow() + timedelta(hours=8)}
    return jwt.encode(payload, SECRET, algorithm="HS256")

def require_auth(fn):
    def wrapper(*args, **kwargs):
        auth = request.headers.get("Authorization", "")
        if auth.startswith("Bearer "):
            token = auth.split(" ", 1)[1]
            try:
                jwt.decode(token, SECRET, algorithms=["HS256"])
                return fn(*args, **kwargs)
            except Exception as e:
                return jsonify({"error":"invalid_token","detail":str(e)}), 401
        return jsonify({"error":"missing_token"}), 401
    wrapper.__name__ = fn.__name__
    return wrapper

@app.get("/health")
def health():
    return {"status":"ok","ts":int(time.time())}

@app.post("/login")
def login():
    body = request.json or {}
    username = body.get("username")
    password = body.get("password")
    users = read_json(FILES["users"], [])
    if any(u["username"] == username and u["password"] == password for u in users):
        return {"token": token_for(username)}
    return {"error":"invalid_credentials"}, 401

# --- Incidentes ---
@app.get("/incidents")
def list_incidents():
    items = []
    for p in glob.glob(os.path.join(INC_DIR, "*.json")):
        items.append(read_json(p, {}))
    return jsonify(items)

@app.get("/incidents/<iid>")
def get_incident(iid):
    p = os.path.join(INC_DIR, f"{iid}.json")
    data = read_json(p)
    if not data: return {"error":"not_found"}, 404
    return data

# --- Clientes ---
@app.get("/clients")
def list_clients():
    return jsonify(read_json(FILES["clients"], []))

@app.get("/clients/<cid>")
def get_client(cid):
    clients = read_json(FILES["clients"], [])
    for c in clients:
        if c.get("id")==cid: return c
    return {"error":"not_found"}, 404

@app.get("/clients/<cid>/tickets")
def tickets_by_client(cid):
    tickets = read_json(FILES["tickets"], [])
    return jsonify([t for t in tickets if t.get("client_id")==cid])

# --- Tickets ---
@app.get("/tickets")
def list_tickets():
    return jsonify(read_json(FILES["tickets"], []))

@app.post("/tickets")
@require_auth
def create_ticket():
    body = request.json or {}
    # Espera: client_id e incident_id
    client_id  = body.get("client_id")
    incident_id= body.get("incident_id")
    if not client_id or not incident_id:
        return {"error":"missing_fields"}, 400

    tickets = read_json(FILES["tickets"], [])
    new_id = (max((t.get("id",0) for t in tickets), default=0) + 1) if tickets else 1
    ticket = {
        "id": new_id,
        "client_id": client_id,
        "incident_id": incident_id,
        "status": "OPEN",
        "created_at": datetime.utcnow().isoformat()+"Z"
    }
    tickets.append(ticket)
    write_json(FILES["tickets"], tickets)
    return ticket, 201

if __name__ == "__main__":
    ensure_data()
    app.run(host="0.0.0.0", port=PORT)
