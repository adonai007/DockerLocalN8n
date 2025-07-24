#!/bin/bash

echo "🧪 Probando Supabase Storage..."

# Test basic health
echo "📊 Verificando salud del servicio..."
response=$(curl -s -w "%{http_code}" http://localhost:5001/status -o /tmp/storage_response.txt)
echo "Status code: $response"

if [ "$response" = "200" ]; then
    echo "✅ Storage API está funcionando!"
    echo "📝 Respuesta:"
    cat /tmp/storage_response.txt
    echo ""
else
    echo "❌ Storage API no responde correctamente"
    echo "🔍 Logs del contenedor:"
    docker logs supabase-storage-standalone --tail 20
fi

# Test bucket list
echo ""
echo "📂 Intentando listar buckets..."
curl -s -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN0b3JhZ2UiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY0MTc2OTIwMCwiZXhwIjoxOTU3MzQ1MjAwfQ" \
     http://localhost:5001/bucket || echo "Error al conectar con buckets"

echo ""
echo "🎯 URLs de prueba:"
echo "   http://localhost:5001/status"
echo "   http://localhost:5001/bucket"

echo ""
echo "🔧 Para detener el storage:"
echo "   docker-compose -f docker-compose-storage.yml down"

rm -f /tmp/storage_response.txt