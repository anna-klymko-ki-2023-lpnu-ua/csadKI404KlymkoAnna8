@echo off
if not exist ".venv" (
    python -m venv .venv
    if errorlevel 1 exit /b %errorlevel%
)

.venv\Scripts\python -m pip install -r requirements.txt
if errorlevel 1 exit /b %errorlevel%

.venv\Scripts\python src\hello.py
if errorlevel 1 exit /b %errorlevel%
