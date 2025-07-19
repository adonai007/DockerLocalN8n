# Diagrama de Arquitectura - n8n + Supabase Local

## 🌐 Visualización Interactiva

**[Ver Diagrama Interactivo en Claude](https://claude.ai/public/artifacts/06dde787-00be-4c4e-b478-10e9fd773be6)**

*Accede al enlace para una visualización interactiva con zoom, navegación y detalles expandibles de cada componente.*

```mermaid
graph TB
    %% Windows Host Environment
    subgraph WIN["🖥️ Windows 10 Host"]
        DOCKER["🐳 Docker Desktop"]
        OLLAMA["🤖 Ollama (localhost:11434)"]
        LM["🧠 LM Studio (localhost:1234)"]
        DEEPSEEK["🔮 DeepSeek API"]
        BROWSER["🌐 Browser"]
    end

    %% Docker Network
    subgraph NETWORK["🔗 Docker Network (n8n-network)"]
        
        %% Core Services
        subgraph N8N_SERVICE["📋 n8n Workflow Engine"]
            N8N["n8n Container<br/>Port: 5678"]
        end
        
        %% Database Layer
        subgraph DB_LAYER["💾 Database Layer"]
            POSTGRES["PostgreSQL<br/>Port: 5432<br/>- n8n DB<br/>- supabase_auth<br/>- supabase_storage<br/>- supabase_realtime"]
        end
        
        %% Supabase Services
        subgraph SUPABASE["🚀 Supabase Local Stack"]
            KONG["Kong API Gateway<br/>Port: 8000/8443"]
            AUTH["Supabase Auth<br/>(GoTrue)<br/>Port: 9999"]
            STORAGE["Supabase Storage<br/>Port: 5000"]
            REST["PostgREST API<br/>Port: 3000"]
        end
    end

    %% Data Persistence
    subgraph VOLUMES["💿 Docker Volumes"]
        N8N_DATA["n8n_data<br/>(Workflows & Config)"]
        PG_DATA["postgres_data<br/>(Database Files)"]
        STORAGE_DATA["storage_data<br/>(File Storage)"]
    end

    %% Connections - External to Services
    BROWSER -->|"HTTP :5678"| N8N
    BROWSER -->|"HTTP :8000"| KONG
    
    %% AI Services Connections
    OLLAMA -.->|"host.docker.internal:11434"| N8N
    LM -.->|"host.docker.internal:1234"| N8N
    DEEPSEEK -.->|"API Calls"| N8N

    %% Internal Service Connections
    N8N -->|"Database Queries"| POSTGRES
    N8N -->|"Supabase API Calls"| KONG
    
    %% Supabase Internal Architecture
    KONG -->|"Auth Routes (/auth/v1/*)"| AUTH
    KONG -->|"API Routes (/rest/v1/*)"| REST
    KONG -->|"Storage Routes (/storage/v1/*)"| STORAGE
    
    AUTH -->|"User Management"| POSTGRES
    STORAGE -->|"File Metadata"| POSTGRES
    REST -->|"Data Access"| POSTGRES

    %% Data Persistence Connections
    N8N -.->|"Persist Data"| N8N_DATA
    POSTGRES -.->|"Persist Data"| PG_DATA
    STORAGE -.->|"Persist Files"| STORAGE_DATA

    %% Styling
    classDef service fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef database fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef ai fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef volume fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef external fill:#ffebee,stroke:#c62828,stroke-width:2px

    class N8N,KONG,AUTH,STORAGE,REST service
    class POSTGRES database
    class OLLAMA,LM,DEEPSEEK ai
    class N8N_DATA,PG_DATA,STORAGE_DATA volume
    class BROWSER,DOCKER external
```

## Flujo de Datos

```mermaid
sequenceDiagram
    participant U as Usuario/Browser
    participant N as n8n
    participant K as Kong Gateway
    participant A as Supabase Auth
    participant P as PostgreSQL
    participant AI as IA Local

    Note over U,AI: 1. Configuración de Workflow
    U->>N: Crear workflow con IA
    N->>AI: Configurar conexión
    AI-->>N: Respuesta de conectividad

    Note over U,AI: 2. Autenticación Supabase
    U->>K: Login request
    K->>A: Forward auth
    A->>P: Validar credenciales
    P-->>A: User data
    A-->>K: JWT Token
    K-->>U: Auth response

    Note over U,AI: 3. Ejecución de Workflow
    U->>N: Trigger workflow
    N->>K: Query Supabase
    K->>P: Database query
    P-->>K: Data response
    K-->>N: API response
    N->>AI: Process with IA
    AI-->>N: IA response
    N-->>U: Workflow result
```

## Componentes Detallados

### 🔧 Servicios Core
- **n8n**: Motor de workflows y automatización
- **Kong**: API Gateway y proxy reverso
- **PostgreSQL**: Base de datos principal
- **GoTrue**: Servicio de autenticación
- **PostgREST**: API REST automática
- **Storage API**: Gestión de archivos

### 🤖 Integración con IAs
- **Ollama**: Modelos locales (Llama, Mistral, etc.)
- **LM Studio**: Interface para modelos locales
- **DeepSeek**: API externa de IA
- **Conexión**: Vía `host.docker.internal` para servicios en Windows

### 💾 Persistencia
- **n8n_data**: Workflows, credenciales, configuraciones
- **postgres_data**: Datos de usuarios, tablas, autenticación
- **storage_data**: Archivos subidos y multimedia

### 🌐 Endpoints Principales
- **n8n UI**: `http://localhost:5678`
- **Supabase API**: `http://localhost:8000`
- **PostgreSQL**: `localhost:5432`
- **Direct Services**: Acceso interno vía red Docker

## Beneficios de esta Arquitectura

1. **Aislamiento**: Cada servicio en su propio contenedor
2. **Escalabilidad**: Fácil añadir más servicios
3. **Persistencia**: Datos seguros en volúmenes
4. **Flexibilidad**: Compatible con múltiples IAs
5. **Desarrollo Local**: Sin dependencias externas
6. **Windows Compatible**: Configuración específica para W10