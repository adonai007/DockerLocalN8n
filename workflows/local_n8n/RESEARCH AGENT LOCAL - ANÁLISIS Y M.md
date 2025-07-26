# 🔍 RESEARCH AGENT LOCAL - ANÁLISIS Y MEJORES IMPLEMENTACIONES

## 📊 ANÁLISIS DEL RESEARCH AGENT ACTUAL

### **🔄 FLUJO ACTUAL (Cloud):**
```
User Query → Research Agent → Perplexity API → Google Docs Create/Update → Google Doc Link
```

### **🛠️ COMPONENTES ACTUALES:**
- **Modelo:** Anthropic Claude 3.7 Sonnet
- **Tools:** Perplexity, Google Docs (Get/Create/Update)
- **Input:** Execute Workflow Trigger + Chat Trigger
- **Output:** Google Doc link compartible
- **Prompt:** Enfocado en crear documentos cloud

---

## 🏗️ MIGRACIÓN A ENTORNO LOCAL: CAMBIOS CRÍTICOS

### **1. MODELO IA: ANTHROPIC → OLLAMA**

**ANTES (Cloud):**
```yaml
modelo: "claude-3-7-sonnet-20250219"
memoria: 16GB (sin límites)
costo: Por token/uso
```

**DESPUÉS (Local):**
```yaml
modelo: "deepseek-coder:1.3b"
memoria: 1.1GB (optimizado para 4GB VRAM)
costo: $0 (una vez descargado)
optimización: "Especializado en documentos y código"
```

### **2. TOOLS MIGRATION: GOOGLE DOCS → FILESYSTEM**

**ANTES (Cloud Tools):**
```javascript
available_tools: [
  "Google Docs Get",      // Leer documentos cloud
  "Google Docs Create",   // Crear nuevo doc
  "Google Docs Update",   // Actualizar contenido
  "Perplexity API"        // Investigación externa ✅
]
```

**DESPUÉS (Local Tools):**
```javascript
available_tools: [
  "filesystem_read_file",     // Leer archivos .md locales
  "filesystem_write_file",    // Crear reportes nuevos
  "filesystem_append_file",   // Actualizar reportes
  "filesystem_list_files",    // Listar reportes disponibles
  "filesystem_create_dir",    // Crear directorios
  "perplexity_api"           // Investigación externa ✅
]
```

---

## 🎯 IMPLEMENTACIONES ESPECÍFICAS RECOMENDADAS

### **A. FILESYSTEM TOOLS DESIGN:**

#### **1. READ FILE TOOL:**
```yaml
name: "Read Research File"
description: "Lee archivos de investigación existentes para contexto"
parameters:
  file_path: 
    type: string
    description: "Ruta completa: /project-data/reports/filename.md"
    required: true
output: "Contenido del archivo como string"
error_handling: "File not found, permission denied"
```

#### **2. WRITE FILE TOOL:**
```yaml
name: "Create Research Report"
description: "Crea nuevo reporte de investigación en markdown"
parameters:
  filename:
    type: string
    description: "research_[empresa]_[YYYY-MM-DD].md"
    required: true
  content:
    type: string
    description: "Contenido completo en formato markdown"
    required: true
  overwrite:
    type: boolean
    description: "Sobrescribir si existe"
    default: false
output: "Ruta completa del archivo creado"
```

#### **3. APPEND FILE TOOL:**
```yaml
name: "Update Research Report"
description: "Añade contenido a reporte existente"
parameters:
  file_path: 
    type: string
    required: true
  content:
    type: string
    description: "Contenido a añadir (markdown)"
    required: true
  section:
    type: string
    description: "Sección específica a actualizar"
    required: false
```

#### **4. LIST FILES TOOL:**
```yaml
name: "List Available Reports"
description: "Lista archivos de investigación disponibles"
parameters:
  directory:
    type: string
    default: "/project-data/reports/"
  filter:
    type: string
    description: "Filtro por empresa o fecha"
    required: false
output: "Array de archivos con metadata"
```

### **B. ESTRUCTURA DE ARCHIVOS OPTIMIZADA:**

#### **TEMPLATE MARKDOWN ESTÁNDAR:**
```markdown
# Research Report: [EMPRESA] vs [COMPETIDOR]
**Fecha:** [YYYY-MM-DD]  
**Investigador:** Research Agent Local  
**Fuentes:** [Número] fuentes verificadas  

## 📋 Resumen Ejecutivo
[2-3 párrafos clave]

## 🔍 Metodología
- Fuentes consultadas: Perplexity AI + Web Research
- Período analizado: [fechas]
- Enfoque: [Competitivo/Mercado/Estratégico]

## 📊 Hallazgos Principales

### 1. [EMPRESA PRINCIPAL]
**Fortalezas:**
- [Punto 1]
- [Punto 2]

**Debilidades:**
- [Punto 1]
- [Punto 2]

### 2. [COMPETIDOR/MERCADO]
[Análisis similar]

## 🎯 Insights Estratégicos
1. **Oportunidades:** [Lista]
2. **Amenazas:** [Lista]
3. **Recomendaciones:** [Lista priorizada]

## 📚 Fuentes y Referencias
[Lista numerada con links cuando disponibles]

---
*Reporte generado por Research Agent Local*  
*Archivo: [ruta_completa]*  
*Última actualización: [timestamp]*
```

#### **NAMING CONVENTION INTELIGENTE:**
```javascript
naming_patterns = {
  basic_research: "research_[empresa]_[YYYY-MM-DD].md",
  competitive: "research_[empresa]_vs_[competidor]_[YYYY-MM-DD].md",
  market_analysis: "research_market_[sector]_[YYYY-MM-DD].md",
  update: "research_[empresa]_[YYYY-MM-DD]_v[numero].md"
}

// Ejemplos reales:
examples = [
  "research_tesla_2024-12-23.md",
  "research_tesla_vs_byd_2024-12-23.md", 
  "research_market_fintech_bolivia_2024-12-23.md"
]
```


---

## 🚀 WORKFLOW STRUCTURE RECOMENDADA

### **NODOS PRINCIPALES:**

1. **Execute Workflow Trigger** (mantener para Manager)
2. **Chat Trigger** (para testing independiente)
3. **Ollama Chat Model** (deepseek-coder:1.3b)
4. **Research Agent** (con prompt migrado)
5. **Perplexity Tool** (investigación externa)
6. **Filesystem Tools** (read/write/list/append)

### **FLUJO OPTIMIZADO LOCAL:**
```
Input Query 
    ↓
Research Agent Local (Ollama)
    ↓
Perplexity Investigation
    ↓
Content Processing & Analysis
    ↓
Markdown Report Generation
    ↓
File System Write (/project-data/reports/)
    ↓
Metadata Logging (Supabase)
    ↓
Return File Path + Summary
```

---

## 🔧 IMPLEMENTACIONES TÉCNICAS ESPECÍFICAS

### **A. PERPLEXITY INTEGRATION OPTIMIZADA:**

```javascript
// Configuración Perplexity para investigación local
perplexity_config = {
  model: "sonar-pro", // Mejor calidad para research
  max_tokens: 4000,   // Respuestas detalladas
  temperature: 0.2,   // Consistencia alta
  search_recency_filter: "month", // Información reciente
  return_citations: true,         // Para referencias
  return_images: false           // Solo texto para markdown
}

// Query optimization para mejor research
query_patterns = {
  competitive: "[empresa1] vs [empresa2] market share revenue strategy 2024",
  market: "[sector] market trends Bolivia Latin America 2024",
  strategic: "[empresa] business model strategy competitive advantage",
  financial: "[empresa] revenue profits financial performance 2024"
}
```

### **B. ERROR HANDLING ESPECÍFICO:**

```javascript
error_scenarios = {
  perplexity_api_failure: {
    fallback: "Use cached research data if available",
    retry_strategy: "3 attempts with exponential backoff",
    user_message: "🔍 API temporalmente no disponible. Usando datos base disponibles."
  },
  
  filesystem_permission_error: {
    fallback: "Try alternative path /tmp/research-reports/",
    fix_suggestion: "chmod 755 /project-data/ && chown user:user /project-data/",
    user_message: "📁 Error de permisos. Usando ruta temporal alternativa."
  },
  
  ollama_model_loading: {
    fallback: "Wait 60s or use alternative model",
    monitoring: "Check memory usage and free if needed",
    user_message: "🤖 Cargando modelo especializado. Tiempo estimado: 45s."
  },
  
  file_naming_conflict: {
    fallback: "Auto-append version number",
    strategy: "research_tesla_2024-12-23_v2.md",
    user_message: "📄 Archivo existente. Creando versión nueva."
  }
}
```

### **C. PERFORMANCE OPTIMIZATIONS:**

```javascript
performance_settings = {
  memory_management: {
    max_file_size: "10MB",
    auto_cleanup_temp: "after 24h",
    cache_perplexity: "last 10 queries"
  },
  
  ollama_optimization: {
    preload_model: "on_first_research_request",
    keep_alive: "10_minutes_idle",
    memory_limit: "1.5GB_max"
  },
  
  file_operations: {
    async_writes: true,
    compression: "gzip for archives",
    backup_strategy: "daily to /project-data/backups/"
  }
}
```

---

## 📋 PROMPT MIGRATION ESPECÍFICA

### **CAMBIOS CRÍTICOS EN EL PROMPT:**

#### **ANTES (Cloud):**
```
## OUTPUT SPECIFICATIONS
**Delivery Method:**  
- **REQUIRED**: Provide direct Google Doc link to user in final response
- Include brief summary of key findings alongside the link
- Created with sharing permissions set to "Anyone with link can view"
```

#### **DESPUÉS (Local):**
```
## OUTPUT SPECIFICATIONS
**Delivery Method:**  
- **REQUIRED**: Provide direct local file path to user in final response
- Include brief summary of key findings alongside the file location
- File saved with structured naming: research_[empresa]_[fecha].md
- Metadata logged to Supabase local for tracking
```

#### **TOOLS SECTION UPDATE:**
```
## AVAILABLE TOOLS

**Perplexity Research (External):**  
- Use for: Real-time competitive intelligence and market data
- When to use: Primary research tool for all external information gathering
- Limitations: API rate limits; verify information currency

**Local File System (Read/Write):**  
- Use for: Creating, reading, and updating research reports locally
- When to use: Final step to document findings + reading existing context
- File format: Structured markdown with consistent templates
- Location: /project-data/reports/ with standardized naming

**Supabase Local (Metadata):**  
- Use for: Tracking research tasks, sources, and performance metrics
- When to use: Log metadata after successful file creation
- Limitations: Optional - system works without DB if needed
```

---

## ✅ VENTAJAS DE LA IMPLEMENTACIÓN LOCAL

### **🔒 CONTROL TOTAL:**
- ✅ Datos completamente privados y seguros
- ✅ Sin dependencias externas (excepto Perplexity)
- ✅ Customización total de templates y estructura

### **💰 EFICIENCIA DE COSTOS:**
- ✅ Sin costos recurrentes de Anthropic API
- ✅ Solo Perplexity como costo externo
- ✅ Escalable sin límites de uso

### **⚡ PERFORMANCE OPTIMIZADA:**
- ✅ Archivos locales = acceso instantáneo
- ✅ Templates reutilizables = consistencia
- ✅ Metadata tracking = mejor gestión de proyectos

---

## 🎯 PRÓXIMOS PASOS RECOMENDADOS

1. **¿Te parece correcta esta migración de tools Google Docs → Filesystem?**
2. **¿Apruebas el template de markdown propuesto para los reportes?**
3. **¿Prefieres implementar primero las tools básicas o el prompt completo?**
4. **¿Algún ajuste específico en la integración Perplexity o estructura de archivos?**

Una vez confirmes estos puntos, puedo generar:
- **Prompt completo migrado** del Research Agent Local
- **JSON workflow** completo para n8n
- **Tools específicas** para filesystem operations