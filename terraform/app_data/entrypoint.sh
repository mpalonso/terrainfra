#!/bin/sh
set -e

pip install --no-cache-dir flask

cat > /app.py <<'PYCODE'
from flask import Flask, jsonify
import json

app = Flask(__name__)

with open("/data/incidents.json") as f:
    data = json.load(f)

@app.route("/incidents")
def list_incidents():
    return jsonify(data)

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYCODE

python /app.py
