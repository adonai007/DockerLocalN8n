# 📚 Guía de Uso - N8N Local con Archivos Accesibles

## 🔄 Importar/Exportar Workflows

### Exportar workflow desde n8n:
1. Ve a n8n (http://localhost:5678)
2. Abre el workflow que quieres exportar
3. Clic en el menú (3 puntos) → "Download"
4. Guarda en: `.\workflows\exports\`

### Importar workflow a n8n:
1. Ve a n8n (http://localhost:5678)
2. Clic en "Import from file"
3. Selecciona desde: `.\workflows\local_n8n\` o `.\workflows\imports\`

## 📁 Estructura de Archivos

```
proyecto/
├── workflows/           # Workflows organizados
│   ├── local_n8n/      # Workflows adaptados para local
│   ├── original_n8n/   # Workflows cloud originales
│   └── exports/        # Exports desde n8n UI
├── data/              # Datos generados
│   ├── research-reports/ # Reportes de investigación
│   ├── generated-files/  # Archivos generados por agentes
│   └── temp/            # Archivos temporales
└── logs/               # Logs de n8n
```

## 🤖 Workflows Locales Disponibles

- `21_L_research.json` - Research Agent Local
- `22_L_visualization.json` - Visualization Agent Local  
- `23_L_manager.json` - Manager Agent Local
- `01_test_filesystem.json` - Test de filesystem

## 🔧 Comandos Docker Útiles

```bash
# Ver archivos generados
docker exec n8n-local ls -la /home/node/.n8n/research-reports/

# Acceder al contenedor
docker exec -it n8n-local sh

# Ver logs en tiempo real
docker-compose logs -f n8n

# Reiniciar solo n8n
docker-compose restart n8n
```
