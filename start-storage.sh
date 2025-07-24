#!/bin/bash

echo "🚀 Iniciando Supabase Storage independiente..."

# Detener cualquier contenedor previo
echo "🛑 Deteniendo contenedores previos..."
docker-compose -f docker-compose-storage.yml down

# Limpiar volúmenes si es necesario (descomenta si quieres empezar limpio)
# echo "🧹 Limpiando volúmenes..."
# docker volume rm dockerlocaln8n_storage_postgres_data dockerlocaln8n_storage_files 2>/dev/null || true

# Iniciar servicios
echo "▶️ Iniciando servicios..."
docker-compose -f docker-compose-storage.yml up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 15

# Verificar estado
echo "📊 Estado de los servicios:"
docker-compose -f docker-compose-storage.yml ps

# Mostrar logs si hay errores
echo "📋 Logs del storage:"
docker logs supabase-storage-standalone --tail 10

echo "✅ Storage disponible en: http://localhost:5001"
echo "📊 Base de datos PostgreSQL en: localhost:5434"
echo ""
echo "🔧 Para ver logs en tiempo real:"
echo "   docker logs -f supabase-storage-standalone"
echo ""
echo "🛑 Para detener:"
echo "   docker-compose -f docker-compose-storage.yml down"