#!/bin/bash

# =============================================================================
# Script de configuración del esquema de agentes
# =============================================================================
# Descripción: Ejecuta el script SQL para crear el esquema de agentes
# Uso: ./setup_agents_schema.sh
# Prerequisitos: Docker con Supabase corriendo

set -e

echo "🚀 Configurando esquema de agentes en Supabase..."

# Variables de configuración
DB_HOST="localhost"
DB_PORT="54322"
DB_NAME="postgres"
DB_USER="postgres"
DB_PASSWORD="your-super-secret-and-long-postgres-password"
SCHEMA_FILE="../schema/agents_schema.sql"

# Verificar que el archivo SQL existe
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo $SCHEMA_FILE"
    exit 1
fi

# Verificar que Supabase está corriendo
echo "🔍 Verificando conexión a la base de datos..."
if ! docker exec -it supabase_db_dockerlocaln8n pg_isready -h localhost -p 5432 -U postgres > /dev/null 2>&1; then
    echo "❌ Error: Supabase no está corriendo o no es accesible"
    echo "💡 Ejecuta: docker-compose up -d"
    exit 1
fi

# Ejecutar el script SQL
echo "📝 Ejecutando script SQL..."
docker exec -i supabase_db_dockerlocaln8n psql -U postgres -d postgres < "$SCHEMA_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Esquema de agentes configurado exitosamente"
    echo ""
    echo "📊 Tablas creadas:"
    echo "  - agents.research_reports"
    echo "  - agents.research_sources" 
    echo "  - agents.research_insights"
    echo "  - agents.research_executions"
    echo "  - agents.companies"
    echo ""
    echo "🔍 Vistas creadas:"
    echo "  - agents.v_reports_summary"
    echo "  - agents.v_top_researched_companies"
    echo ""
    echo "⚡ El esquema está listo para usar con n8n"
else
    echo "❌ Error al ejecutar el script SQL"
    exit 1
fi