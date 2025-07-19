# 🤖 N8N Workflows para Agentes de IA

Estructura optimizada para organizar y gestionar workflows de agentes inteligentes.

## 📁 Estructura de Carpetas

```
workflows/
├── agents/                     # Workflows específicos por tipo de agente
│   ├── chatbots/              # Agentes conversacionales
│   │   ├── customer-support/   # Soporte al cliente
│   │   ├── sales-assistant/    # Asistente de ventas
│   │   └── knowledge-base/     # Base de conocimiento
│   ├── automation/            # Agentes de automatización
│   │   ├── data-entry/        # Entrada de datos
│   │   ├── report-generation/ # Generación de reportes
│   │   └── workflow-triggers/ # Disparadores automáticos
│   ├── data-processing/       # Agentes de procesamiento
│   │   ├── text-analysis/     # Análisis de texto
│   │   ├── image-processing/  # Procesamiento de imágenes
│   │   └── data-transformation/ # Transformación de datos
│   └── integrations/          # Agentes de integración
│       ├── crm-sync/         # Sincronización CRM
│       ├── email-management/ # Gestión de emails
│       └── api-connectors/   # Conectores API
├── templates/                 # Plantillas reutilizables
│   ├── basic/                # Plantillas básicas
│   ├── advanced/             # Plantillas avanzadas
│   └── enterprise/           # Plantillas empresariales
├── shared/                   # Recursos compartidos
│   ├── common-nodes/         # Nodos comunes reutilizables
│   ├── utilities/            # Utilidades y helpers
│   └── configs/              # Configuraciones compartidas
└── docs/                     # Documentación
    ├── setup-guides/         # Guías de configuración
    ├── best-practices/       # Mejores prácticas
    └── troubleshooting/      # Solución de problemas
```

## 🎯 Convenciones de Nomenclatura

### Archivos de Workflow
- **Formato**: `[categoria]-[nombre]-[version].json`
- **Ejemplos**: 
  - `chatbot-support-v1.0.json`
  - `automation-leads-v2.1.json`
  - `integration-crm-sync-v1.5.json`

### Carpetas
- Usar nombres descriptivos en inglés
- Separar palabras con guiones (kebab-case)
- Incluir versión en subcarpetas si aplica

## 🚀 Tipos de Agentes Soportados

### 1. Chatbots Inteligentes
- **Soporte al Cliente**: Resolución automatizada de tickets
- **Asistente de Ventas**: Calificación y seguimiento de leads
- **Base de Conocimiento**: Respuestas basadas en documentación

### 2. Automatización de Procesos
- **Entrada de Datos**: Procesamiento automático de formularios
- **Generación de Reportes**: Creación automática de informes
- **Disparadores**: Activación basada en eventos

### 3. Procesamiento de Datos
- **Análisis de Texto**: NLP y sentiment analysis
- **Procesamiento de Imágenes**: OCR y clasificación
- **Transformación**: ETL y limpieza de datos

### 4. Integraciones
- **CRM Sync**: Sincronización con sistemas CRM
- **Email Management**: Gestión automática de correos
- **API Connectors**: Conexión con servicios externos

## 📋 Plantillas Disponibles

### Básicas
- Webhook → Procesamiento → Respuesta
- Timer → Acción → Notificación
- Form → Validación → Almacenamiento

### Avanzadas
- Multi-step conversational flows
- Error handling y retry logic
- Conditional branching con IA

### Empresariales
- High-availability workflows
- Advanced monitoring y logging
- Multi-tenant configurations

## 🛠️ Recursos Compartidos

### Nodos Comunes
- **AI Chat Node**: Configuración estándar para LLMs
- **Database Connector**: Conexión optimizada a Supabase
- **Error Handler**: Manejo consistente de errores
- **Logger**: Sistema de logging unificado

### Utilidades
- **Data Validators**: Validación de datos de entrada
- **Format Converters**: Conversión entre formatos
- **Rate Limiters**: Control de frecuencia de peticiones

## 📚 Documentación

### Guías de Configuración
- Setup inicial de agentes
- Configuración de conexiones a IA local
- Integración con Supabase

### Mejores Prácticas
- Patrones de diseño recomendados
- Manejo de errores y excepciones
- Optimización de performance

### Solución de Problemas
- Debugging de workflows
- Problemas comunes y soluciones
- FAQ sobre agentes de IA

## 🔧 Cómo Usar Esta Estructura

1. **Identificar el tipo de agente** que necesitas crear
2. **Revisar templates** disponibles en la carpeta correspondiente
3. **Copiar y personalizar** el template más cercano a tu necesidad
4. **Usar recursos compartidos** para funcionalidad común
5. **Documentar** tu workflow en la carpeta docs

## 🔄 Importar/Exportar Workflows

### Exportar desde n8n
```bash
# Exportar workflow específico
curl -X GET http://localhost:5678/api/v1/workflows/[ID] > workflows/agents/chatbots/my-agent-v1.0.json

# Exportar todos los workflows
curl -X GET http://localhost:5678/api/v1/workflows > workflows/backup/all-workflows.json
```

### Importar a n8n
1. Abrir n8n UI (http://localhost:5678)
2. Ir a "Workflows" → "Import"
3. Seleccionar archivo JSON del workflow
4. Configurar credenciales y conexiones

## 🎨 Personalización

Esta estructura es flexible y puede adaptarse a tus necesidades específicas:
- Añadir nuevas categorías de agentes
- Crear subcarpetas por proyecto
- Implementar versionado más granular
- Integrar con sistemas de CI/CD