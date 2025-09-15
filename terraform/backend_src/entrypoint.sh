#!/bin/sh
set -e

pip install --no-cache-dir flask flask-cors pyjwt

exec python /backend/app.py
