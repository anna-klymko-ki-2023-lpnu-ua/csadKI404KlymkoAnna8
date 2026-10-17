@echo off
if not exist ".venv" (
    python -m venv .venv
    if errorlevel 1 exit /b %errorlevel%
)

.venv\Scripts\python -m pip install -r requirements.txt
if errorlevel 1 exit /b %errorlevel%

.venv\Scripts\python -m pytest -v
if errorlevel 1 exit /b %errorlevel%

if not exist "dist" mkdir dist
copy /Y src\hello.py dist\hello.py >nul
if errorlevel 1 exit /b %errorlevel%
copy /Y src\add.py dist\add.py >nul
if errorlevel 1 exit /b %errorlevel%
