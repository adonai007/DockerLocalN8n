@echo off
echo 🚀 Configurando n8n con archivos locales accesibles...
echo.

REM Verificar Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker no está instalado o no está corriendo
    pause
    exit /b 1
)

echo ✅ Docker verificado
echo.

REM Crear estructura de directorios necesaria
echo 📁 Creando estructura de directorios...

if not exist "data" mkdir data
if not exist "data\research-reports" mkdir data\research-reports
if not exist "data\research-reports\completed" mkdir data\research-reports\completed
if not exist "data\research-reports\temp" mkdir data\research-reports\temp
if not exist "data\research-reports\backups" mkdir data\research-reports\backups

if not exist "data\generated-files" mkdir data\generated-files
if not exist "data\temp" mkdir data\temp
if not exist "logs" mkdir logs
if not exist "configs" mkdir configs

if not exist "workflows\exports" mkdir workflows\exports
if not exist "workflows\imports" mkdir workflows\imports

echo ✅ Directorios creados
echo.

REM Crear archivo .env si no existe
if not exist ".env" (
    echo 📝 Creando archivo .env...
    call :create_env_file
    echo ✅ Archivo .env creado
) else (
    echo ℹ️ Archivo .env ya existe
)

echo.

REM Crear archivo de configuración de ejemplo
echo 📝 Creando configuraciones de ejemplo...
call :create_config_files

echo.

REM Iniciar servicios
echo 🚀 Iniciando servicios de n8n...
docker-compose down
docker-compose up -d

echo.
echo ⏳ Esperando que los servicios estén listos...
timeout /t 15 /nobreak

echo.
echo ========================================
echo  ✅ CONFIGURACIÓN COMPLETA
echo ========================================
echo.
echo 🌐 URLs de acceso:
echo   • n8n UI: http://localhost:5678
echo   • Supabase API: http://localhost:8000
echo   • PostgreSQL: localhost:5433
echo.
echo 📁 Archivos locales mapeados:
echo   • Workflows: .\workflows\ → /home/node/.n8n/workflows-local/
echo   • Datos generados: .\data\ → /home/node/.n8n/
echo   • Logs: .\logs\ → /home/node/.n8n/logs/
echo.
echo 🔧 Comandos útiles:
echo   • Ver logs: docker-compose logs -f n8n
echo   • Entrar al contenedor: docker exec -it n8n-local sh
echo   • Parar servicios: docker-compose down
echo.
echo 📚 Documentación completa en: .\workflows\docs\
echo.
pause
goto :eof

:create_env_file
(
echo # N8N Configuration
echo POSTGRES_DB=n8n
echo POSTGRES_USER=n8n
echo POSTGRES_PASSWORD=n8n_password_123
echo.
echo # Encryption keys - CAMBIAR en producción
echo N8N_ENCRYPTION_KEY=your-encryption-key-here-min-24-chars
echo N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here-min-32-chars
echo JWT_SECRET=your-supabase-jwt-secret-here
echo.
echo # Supabase Configuration
echo SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN0b3JhZ2UiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY0MTc2OTIwMCwiZXhwIjoxOTU3MzQ1MjAwfQ
echo SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN0b3JhZ2UiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNjQxNzY5MjAwLCJleHAiOjE5NTczNDUyMDB9
echo.
echo # Local AI Configuration ^(opcional^)
echo OLLAMA_BASE_URL=http://host.docker.internal:11434
echo OPENAI_API_BASE=http://host.docker.internal:1234/v1
echo OPENAI_API_KEY=lm-studio
) > .env
goto :eof

:create_config_files
REM Crear configuración para agentes locales
(
echo {
echo   "local_ai": {
echo     "ollama": {
echo       "base_url": "http://host.docker.internal:11434",
echo       "default_model": "deepseek-coder:1.3b"
echo     },
echo     "lm_studio": {
echo       "base_url": "http://host.docker.internal:1234/v1",
echo       "api_key": "lm-studio"
echo     }
echo   },
echo   "file_paths": {
echo     "research_reports": "/home/node/.n8n/research-reports/completed/",
echo     "temp_files": "/home/node/.n8n/temp/",
echo     "generated_files": "/home/node/.n8n/generated/"
echo   },
echo   "workflow_settings": {
echo     "default_timeout": 300,
echo     "max_retries": 3,
echo     "enable_logging": true
echo   }
echo }
) > configs\local-agents-config.json

REM Crear guía de uso
(
echo # 📚 Guía de Uso - N8N Local con Archivos Accesibles
echo.
echo ## 🔄 Importar/Exportar Workflows
echo.
echo ### Exportar workflow desde n8n:
echo 1. Ve a n8n ^(http://localhost:5678^)
echo 2. Abre el workflow que quieres exportar
echo 3. Clic en el menú ^(3 puntos^) → "Download"
echo 4. Guarda en: `.\workflows\exports\`
echo.
echo ### Importar workflow a n8n:
echo 1. Ve a n8n ^(http://localhost:5678^)
echo 2. Clic en "Import from file"
echo 3. Selecciona desde: `.\workflows\local_n8n\` o `.\workflows\imports\`
echo.
echo ## 📁 Estructura de Archivos
echo.
echo ```
echo proyecto/
echo ├── workflows/           # Workflows organizados
echo │   ├── local_n8n/      # Workflows adaptados para local
echo │   ├── original_n8n/   # Workflows cloud originales
echo │   └── exports/        # Exports desde n8n UI
echo ├── data/              # Datos generados
echo │   ├── research-reports/ # Reportes de investigación
echo │   ├── generated-files/  # Archivos generados por agentes
echo │   └── temp/            # Archivos temporales
echo └── logs/               # Logs de n8n
echo ```
echo.
echo ## 🤖 Workflows Locales Disponibles
echo.
echo - `21_L_research.json` - Research Agent Local
echo - `22_L_visualization.json` - Visualization Agent Local  
echo - `23_L_manager.json` - Manager Agent Local
echo - `01_test_filesystem.json` - Test de filesystem
echo.
echo ## 🔧 Comandos Docker Útiles
echo.
echo ```bash
echo # Ver archivos generados
echo docker exec n8n-local ls -la /home/node/.n8n/research-reports/
echo.
echo # Acceder al contenedor
echo docker exec -it n8n-local sh
echo.
echo # Ver logs en tiempo real
echo docker-compose logs -f n8n
echo.
echo # Reiniciar solo n8n
echo docker-compose restart n8n
echo ```
) > GUIA-USO.md

goto :eof