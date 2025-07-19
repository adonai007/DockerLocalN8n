-- Esquema de base de datos para workflows de agentes de IA
-- Ejecutar en Supabase SQL Editor

-- Tabla para conversaciones de agentes
CREATE TABLE IF NOT EXISTS conversations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id VARCHAR(100) NOT NULL,
    user_message TEXT NOT NULL,
    assistant_message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}',
    
    -- Índices para búsqueda rápida
    INDEX idx_conversations_session_id (session_id),
    INDEX idx_conversations_created_at (created_at)
);

-- Tabla para usuarios de agentes
CREATE TABLE IF NOT EXISTS agent_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    external_id VARCHAR(100) UNIQUE NOT NULL, -- ID del sistema externo
    name VARCHAR(255),
    email VARCHAR(255),
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Índices
    INDEX idx_agent_users_external_id (external_id),
    INDEX idx_agent_users_email (email)
);

-- Tabla para configuración de agentes
CREATE TABLE IF NOT EXISTS agents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL, -- chatbot, automation, data-processing, integration
    config JSONB NOT NULL DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, maintenance
    workflow_id VARCHAR(100), -- ID del workflow en n8n
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Índices
    INDEX idx_agents_type (type),
    INDEX idx_agents_status (status),
    INDEX idx_agents_workflow_id (workflow_id)
);

-- Tabla para ejecuciones de workflows
CREATE TABLE IF NOT EXISTS workflow_executions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workflow_id VARCHAR(100) NOT NULL,
    execution_id VARCHAR(100) NOT NULL, -- ID de ejecución en n8n
    agent_id UUID REFERENCES agents(id),
    user_id UUID REFERENCES agent_users(id),
    status VARCHAR(20) NOT NULL, -- running, success, failed, cancelled
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,
    execution_time_ms INTEGER,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    finished_at TIMESTAMP WITH TIME ZONE,
    
    -- Índices
    INDEX idx_workflow_executions_workflow_id (workflow_id),
    INDEX idx_workflow_executions_status (status),
    INDEX idx_workflow_executions_started_at (started_at)
);

-- Tabla para logs de sistema
CREATE TABLE IF NOT EXISTS system_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    level VARCHAR(10) NOT NULL, -- debug, info, warn, error
    source VARCHAR(100) NOT NULL, -- workflow, agent, system
    message TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    workflow_id VARCHAR(100),
    execution_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Índices
    INDEX idx_system_logs_level (level),
    INDEX idx_system_logs_source (source),
    INDEX idx_system_logs_created_at (created_at)
);

-- Tabla para métricas de uso
CREATE TABLE IF NOT EXISTS usage_metrics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    agent_id UUID REFERENCES agents(id),
    metric_type VARCHAR(50) NOT NULL, -- requests, tokens, execution_time, errors
    metric_value NUMERIC NOT NULL,
    unit VARCHAR(20), -- count, ms, tokens, etc
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}',
    
    -- Índices
    INDEX idx_usage_metrics_agent_id (agent_id),
    INDEX idx_usage_metrics_type (metric_type),
    INDEX idx_usage_metrics_recorded_at (recorded_at)
);

-- Triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_conversations_updated_at 
    BEFORE UPDATE ON conversations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_users_updated_at 
    BEFORE UPDATE ON agent_users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agents_updated_at 
    BEFORE UPDATE ON agents 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS)
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_metrics ENABLE ROW LEVEL SECURITY;

-- Políticas básicas (ajustar según necesidades)
CREATE POLICY "Public access to conversations" ON conversations FOR ALL USING (true);
CREATE POLICY "Public access to agent_users" ON agent_users FOR ALL USING (true);
CREATE POLICY "Public access to agents" ON agents FOR ALL USING (true);
CREATE POLICY "Public access to workflow_executions" ON workflow_executions FOR ALL USING (true);
CREATE POLICY "Public access to system_logs" ON system_logs FOR ALL USING (true);
CREATE POLICY "Public access to usage_metrics" ON usage_metrics FOR ALL USING (true);

-- Insertar datos de ejemplo
INSERT INTO agents (name, description, type, config) VALUES
('Customer Support Bot', 'Agente de soporte al cliente 24/7', 'chatbot', 
 '{"model": "gpt-3.5-turbo", "temperature": 0.7, "max_tokens": 500, "language": "es"}'),

('Lead Qualification Agent', 'Calificación automática de leads', 'automation',
 '{"model": "gpt-4", "temperature": 0.3, "criteria": {"budget": 1000, "timeline": "3 months"}}'),

('Data Analysis Agent', 'Análisis y procesamiento de datos', 'data-processing',
 '{"model": "gpt-4", "temperature": 0.1, "output_format": "json", "max_rows": 10000}'),

('CRM Sync Agent', 'Sincronización con sistemas CRM', 'integration',
 '{"crm_type": "salesforce", "sync_interval": "5m", "fields": ["name", "email", "phone"]}');

-- Insertar usuario de ejemplo
INSERT INTO agent_users (external_id, name, email, preferences) VALUES
('user_001', 'Usuario Demo', 'demo@example.com', 
 '{"language": "es", "timezone": "America/Mexico_City", "notifications": true}');

-- Insertar conversación de ejemplo
INSERT INTO conversations (session_id, user_message, assistant_message, metadata) VALUES
('demo_session_001', 
 '¿Cómo puedo configurar un agente de IA?', 
 'Para configurar un agente de IA, primero debes definir el tipo de agente que necesitas: chatbot, automatización, procesamiento de datos o integración. Luego, selecciona el modelo de IA apropiado y configura los parámetros según tus necesidades.',
 '{"model": "gpt-3.5-turbo", "tokens": 145, "response_time": 850}');