#!/usr/bin/env bash
set -euo pipefail

if [ ! -d .venv ]; then
    python3 -m venv .venv
fi

.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m pytest -v

mkdir -p dist
cp src/hello.py dist/hello.py
cp src/add.py dist/add.py
