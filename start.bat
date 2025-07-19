@echo off
echo Iniciando n8n con Supabase local...
echo.

REM Verificar si Docker está corriendo
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker no está instalado o no está corriendo
    echo Por favor, inicia Docker Desktop e intenta de nuevo
    pause
    exit /b 1
)

REM Verificar si Docker Desktop está corriendo
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Desktop no está corriendo
    echo Por favor, inicia Docker Desktop e intenta de nuevo
    pause
    exit /b 1
)

echo Docker está corriendo correctamente
echo.

REM Crear directorios necesarios si no existen
if not exist "supabase" mkdir supabase

REM Copiar archivo de configuración de Kong si no existe
if not exist "supabase\kong.yml" (
    echo Creando configuración de Kong...
    call :create_kong_config
)

echo Construyendo imágenes...
docker-compose build

echo.
echo Iniciando servicios...
docker-compose up -d

echo.
echo Esperando que los servicios estén listos...
timeout /t 10 /nobreak

echo.
echo ========================================
echo  SERVICIOS DISPONIBLES:
echo ========================================
echo  n8n:              http://localhost:5678
echo  Supabase API:     http://localhost:8000
echo  PostgreSQL:       localhost:5432
echo ========================================
echo.
echo Para detener los servicios ejecuta: docker-compose down
echo Para ver los logs ejecuta: docker-compose logs -f
echo.
pause
goto :eof

:create_kong_config
(
echo _format_version: "1.1"
echo services:
echo   - name: auth-v1-open
echo     url: http://supabase-auth:9999/verify
echo     routes:
echo       - name: auth-v1-open
echo         strip_path: true
echo         paths:
echo           - /auth/v1/verify
echo   - name: auth-v1-open-callback
echo     url: http://supabase-auth:9999/callback
echo     routes:
echo       - name: auth-v1-open-callback
echo         strip_path: true
echo         paths:
echo           - /auth/v1/callback
echo   - name: auth-v1-open-authorize
echo     url: http://supabase-auth:9999/authorize
echo     routes:
echo       - name: auth-v1-open-authorize
echo         strip_path: true
echo         paths:
echo           - /auth/v1/authorize
echo   - name: auth-v1
echo     url: http://supabase-auth:9999/
echo     routes:
echo       - name: auth-v1-all
echo         strip_path: true
echo         paths:
echo           - /auth/v1/
echo   - name: rest-v1
echo     url: http://supabase-rest:3000/
echo     routes:
echo       - name: rest-v1-all
echo         strip_path: true
echo         paths:
echo           - /rest/v1/
echo   - name: storage-v1
echo     url: http://supabase-storage:5000/
echo     routes:
echo       - name: storage-v1-all
echo         strip_path: true
echo         paths:
echo           - /storage/v1/
) > supabase\kong.yml
goto :eof