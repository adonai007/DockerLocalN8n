# n8n + Supabase Local Setup

Configuración completa de n8n con Supabase corriendo localmente en Windows 10 para uso con agentes de IA.

## 📊 Diagrama de Arquitectura

Visualiza la arquitectura completa del sistema: [**Ver Diagrama Interactivo**](https://claude.ai/public/artifacts/06dde787-00be-4c4e-b478-10e9fd773be6)

También disponible en: [architecture-diagram.md](./architecture-diagram.md)

## Prerrequisitos

- Docker Desktop instalado y corriendo
- Windows 10
- Al menos 4GB de RAM disponible

## Inicio Rápido

1. **Clonar/Descargar** este directorio
2. **Ejecutar** `start.bat`
3. **Esperar** que todos los servicios inicien
4. **Acceder** a n8n en http://localhost:5678

## Servicios Incluidos

- **n8n**: Automatización de workflows (Puerto 5678)
- **Supabase**: Backend completo con Auth, Database, Storage
  - API Gateway (Kong): Puerto 8000
  - PostgreSQL: Puerto 5433
- **Configuración para IAs locales**: Ollama, LM Studio, DeepSeek

## Configuración de Variables

Edita el archivo `.env` para personalizar:

- Claves de encriptación
- Credenciales de base de datos
- APIs de servicios de IA locales

## IAs Locales Soportadas

### Ollama
```
OLLAMA_BASE_URL=http://host.docker.internal:11434
```

### LM Studio
```
OPENAI_API_BASE=http://host.docker.internal:1234/v1
OPENAI_API_KEY=lm-studio
```

### DeepSeek
```
DEEPSEEK_API_KEY=tu-api-key
DEEPSEEK_BASE_URL=http://localhost:11434/v1
```

## Comandos Útiles

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar servicios
docker-compose down

# Reiniciar servicios
docker-compose restart

# Ver estado de servicios
docker-compose ps
```

## Volúmenes de Datos

Los datos persisten en volúmenes Docker:
- `n8n_data`: Workflows y configuraciones de n8n
- `postgres_data`: Base de datos PostgreSQL
- `storage_data`: Archivos de Supabase Storage

## URLs de Acceso

- **n8n UI**: http://localhost:5678
- **Supabase API**: http://localhost:8000
- **PostgreSQL**: localhost:5433

## Configuración de n8n para Supabase

En n8n, puedes usar estos valores para conectar con Supabase:

- **URL**: http://supabase-kong:8000
- **Anon Key**: Ver en archivo `.env`
- **Service Role Key**: Ver en archivo `.env`

## Troubleshooting

### Docker no inicia
- Verificar que Docker Desktop esté corriendo
- Reiniciar Docker Desktop

### Puertos ocupados
- Verificar que los puertos 5678, 8000, 5433 estén libres
- Cambiar puertos en `docker-compose.yml` si es necesario

### Servicios no responden
- Esperar más tiempo al inicio (pueden tardar 1-2 minutos)
- Verificar logs con `docker-compose logs -f`