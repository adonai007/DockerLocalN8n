# 🚀 Configuración de IA Local para N8N

Guía completa para configurar modelos de IA locales con n8n workflows.

## 🎯 Modelos Soportados

### 1. Ollama
**Puerto**: 11434  
**URL Base**: `http://host.docker.internal:11434`

#### Instalación
```bash
# Windows/Mac - Descargar desde https://ollama.ai
# Linux
curl -fsSL https://ollama.ai/install.sh | sh
```

#### Modelos Recomendados
```bash
# Modelos de chat
ollama pull llama2
ollama pull mistral
ollama pull codellama

# Modelos de embedding
ollama pull nomic-embed-text
```

#### Configuración en N8N
- **Base URL**: `http://host.docker.internal:11434`
- **Model**: `llama2` (o el modelo que hayas instalado)
- **Headers**: No requiere autenticación

### 2. LM Studio
**Puerto**: 1234  
**URL Base**: `http://host.docker.internal:1234/v1`

#### Configuración
1. Descargar LM Studio desde https://lmstudio.ai
2. Cargar un modelo (ej: Llama-2-7b-chat)
3. Iniciar el servidor local en puerto 1234

#### Configuración en N8N
- **Base URL**: `http://host.docker.internal:1234/v1`
- **API Key**: `lm-studio`
- **Model**: Usar el nombre del modelo cargado

### 3. DeepSeek (API)
**URL Base**: `https://api.deepseek.com/v1`

#### Configuración en N8N
- **Base URL**: `https://api.deepseek.com/v1`
- **API Key**: Tu API key de DeepSeek
- **Model**: `deepseek-chat` o `deepseek-coder`

## 🔧 Configuración en N8N

### Usando HTTP Request Node
```json
{
  "method": "POST",
  "url": "http://host.docker.internal:11434/api/generate",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "model": "llama2",
    "prompt": "{{ $json.message }}",
    "stream": false
  }
}
```

### Usando OpenAI Node (Compatible)
Para LM Studio y DeepSeek que soportan la API de OpenAI:
- **Base URL**: Configurar según el proveedor
- **API Key**: Configurar según sea necesario
- **Model**: Nombre del modelo específico

## 🛠️ Nodos Personalizados

### Ollama Chat Node
```json
{
  "parameters": {
    "resource": "chat",
    "operation": "generate",
    "model": "llama2",
    "prompt": "={{ $json.message }}",
    "options": {
      "temperature": 0.7,
      "max_tokens": 2048
    }
  },
  "type": "n8n-nodes-base.httpRequest"
}
```

### Error Handling
```json
{
  "parameters": {
    "rules": {
      "rule": [
        {
          "type": "set",
          "properties": {
            "error": "AI service unavailable",
            "fallback": "Lo siento, no puedo procesar tu solicitud en este momento."
          }
        }
      ]
    }
  },
  "type": "n8n-nodes-base.set"
}
```

## 📊 Monitoreo y Logs

### Health Check
Crear un workflow que verifique regularmente la disponibilidad:
```http
GET http://host.docker.internal:11434/api/tags
```

### Logging
Usar el nodo Logger para trackear:
- Tiempo de respuesta
- Tokens utilizados
- Errores y reintentos

## 🔄 Mejores Prácticas

### 1. Fallback Strategy
- Configurar múltiples proveedores
- Implementar fallback automático
- Cache de respuestas frecuentes

### 2. Rate Limiting
- Limitar requests por minuto
- Queue para manejar picos de tráfico
- Throttling automático

### 3. Context Management
- Mantener contexto de conversación
- Limpiar contexto periódicamente
- Límites de memoria

### 4. Security
- No hardcodear API keys
- Usar variables de entorno
- Validar inputs del usuario

## 🚨 Troubleshooting

### Ollama No Responde
```bash
# Verificar que Ollama esté corriendo
ollama list

# Reiniciar servicio
ollama serve
```

### LM Studio Connection Issues
- Verificar que el servidor esté activo
- Comprobar puerto 1234 disponible
- Revisar firewall/antivirus

### Performance Issues
- Usar modelos más pequeños para testing
- Implementar streaming para respuestas largas
- Considerar GPU acceleration

## 📈 Optimización

### Model Selection
- **Chat General**: Llama2 7B
- **Código**: CodeLlama 7B
- **Embeddings**: nomic-embed-text
- **Multimodal**: llava

### Parameters Tuning
```json
{
  "temperature": 0.7,  // Creatividad (0.1-1.0)
  "max_tokens": 2048,  // Longitud máxima
  "top_p": 0.9,       // Nucleus sampling
  "stop": ["\n\n"]    // Stop sequences
}
```

### Caching Strategy
- Cache respuestas comunes
- TTL apropiado por tipo de query
- Invalidación automática