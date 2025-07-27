-- ============================================
-- SCHEMA DE BASE DE DATOS PARA AGENTES DE INVESTIGACIÓN
-- ============================================
-- Creado: 2025-07-27
-- Descripción: Esquema completo para almacenar reportes de investigación,
-- fuentes, insights y métricas de ejecución de agentes de n8n

-- Crear el esquema agents
CREATE SCHEMA IF NOT EXISTS agents;

-- Configurar permisos
GRANT ALL ON SCHEMA agents TO n8n;

-- ============================================
-- TABLA PRINCIPAL: RESEARCH REPORTS
-- ============================================
CREATE TABLE agents.research_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    query_original TEXT NOT NULL,
    company_primary VARCHAR(100),
    companies_analyzed TEXT[], -- Array de empresas analizadas
    sector VARCHAR(100),
    report_type VARCHAR(50) DEFAULT 'competitive', -- competitive, market, company
    
    -- Contenido
    content_markdown TEXT NOT NULL,
    summary TEXT,
    recommendations TEXT[],
    key_findings TEXT[],
    
    -- Metadata de calidad
    status VARCHAR(20) DEFAULT 'completed',
    sources_count INT DEFAULT 0,
    tier1_sources_count INT DEFAULT 0,
    tier2_sources_count INT DEFAULT 0,
    tier3_sources_count INT DEFAULT 0,
    word_count INT,
    
    -- Execution data
    execution_time_ms INT,
    model_used VARCHAR(100) DEFAULT 'deepseek-coder:1.3b',
    perplexity_calls INT DEFAULT 0,
    
    -- Archivos (backward compatibility)
    file_path TEXT,
    file_size_bytes BIGINT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: RESEARCH SOURCES
-- ============================================
CREATE TABLE agents.research_sources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_id UUID REFERENCES agents.research_reports(id) ON DELETE CASCADE,
    
    -- Source info
    url TEXT,
    title TEXT NOT NULL,
    author VARCHAR(255),
    publication_date DATE,
    access_date DATE DEFAULT CURRENT_DATE,
    
    -- Classification
    source_type VARCHAR(50) NOT NULL, -- academic, government, corporate, news, etc
    tier INT NOT NULL CHECK (tier IN (1,2,3)),
    credibility_score INT CHECK (credibility_score BETWEEN 1 AND 10),
    
    -- Citation
    citation_apa TEXT,
    citation_note TEXT,
    
    -- Content
    excerpt TEXT, -- Fragmento utilizado
    context_usage TEXT, -- Cómo se usó en el reporte
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: RESEARCH INSIGHTS
-- ============================================
CREATE TABLE agents.research_insights (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_id UUID REFERENCES agents.research_reports(id) ON DELETE CASCADE,
    
    -- Insight classification
    category VARCHAR(100) NOT NULL, -- market_share, financial, competitive_advantage, etc
    subcategory VARCHAR(100),
    insight_type VARCHAR(50), -- finding, recommendation, trend, risk
    
    -- Content
    insight_text TEXT NOT NULL,
    supporting_data JSONB, -- Datos estructurados que soportan el insight
    confidence_level INT CHECK (confidence_level BETWEEN 1 AND 10),
    
    -- Relations
    related_companies TEXT[], -- Empresas mencionadas en este insight
    related_sources UUID[], -- IDs de fuentes que soportan este insight
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: RESEARCH EXECUTIONS (Metadata)
-- ============================================
CREATE TABLE agents.research_executions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_id UUID REFERENCES agents.research_reports(id) ON DELETE CASCADE,
    
    -- Execution context
    workflow_id VARCHAR(100),
    execution_id VARCHAR(100),
    agent_version VARCHAR(50),
    user_id VARCHAR(100),
    
    -- Performance metrics
    total_execution_time_ms INT,
    perplexity_calls_count INT,
    perplexity_total_tokens INT,
    ollama_tokens_input INT,
    ollama_tokens_output INT,
    
    -- Quality metrics
    sources_collected INT,
    sources_validated INT,
    sources_cited INT,
    
    -- System info
    system_info JSONB, -- Docker, versions, etc
    errors_encountered JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLA: COMPANIES (Master data)
-- ============================================
CREATE TABLE agents.companies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    name_variations TEXT[], -- Tesla, Tesla Inc, Tesla Motors
    sector VARCHAR(100),
    industry VARCHAR(100),
    country VARCHAR(100),
    founded_year INT,
    
    -- Research metadata
    total_reports_count INT DEFAULT 0,
    last_researched_at TIMESTAMP WITH TIME ZONE,
    research_frequency INT DEFAULT 0, -- Veces que se ha investigado
    
    -- External IDs
    ticker_symbol VARCHAR(10),
    website VARCHAR(255),
    linkedin_url VARCHAR(255),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

-- Research Reports indexes
CREATE INDEX idx_research_reports_company ON agents.research_reports(company_primary);
CREATE INDEX idx_research_reports_sector ON agents.research_reports(sector);
CREATE INDEX idx_research_reports_created ON agents.research_reports(created_at);
CREATE INDEX idx_research_reports_type ON agents.research_reports(report_type);
CREATE INDEX idx_research_reports_status ON agents.research_reports(status);

-- Sources indexes
CREATE INDEX idx_research_sources_report ON agents.research_sources(report_id);
CREATE INDEX idx_research_sources_tier ON agents.research_sources(tier);
CREATE INDEX idx_research_sources_type ON agents.research_sources(source_type);

-- Insights indexes
CREATE INDEX idx_research_insights_report ON agents.research_insights(report_id);
CREATE INDEX idx_research_insights_category ON agents.research_insights(category);
CREATE INDEX idx_research_insights_confidence ON agents.research_insights(confidence_level);

-- Companies indexes
CREATE INDEX idx_companies_name ON agents.companies(name);
CREATE INDEX idx_companies_sector ON agents.companies(sector);

-- ============================================
-- TRIGGERS PARA AUTO-UPDATE
-- ============================================

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION agents.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_research_reports_updated_at 
    BEFORE UPDATE ON agents.research_reports 
    FOR EACH ROW EXECUTE FUNCTION agents.update_updated_at_column();

CREATE TRIGGER update_companies_updated_at 
    BEFORE UPDATE ON agents.companies 
    FOR EACH ROW EXECUTE FUNCTION agents.update_updated_at_column();

-- Auto-count sources trigger
CREATE OR REPLACE FUNCTION agents.update_sources_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE agents.research_reports 
    SET 
        sources_count = (SELECT COUNT(*) FROM agents.research_sources WHERE report_id = NEW.report_id),
        tier1_sources_count = (SELECT COUNT(*) FROM agents.research_sources WHERE report_id = NEW.report_id AND tier = 1),
        tier2_sources_count = (SELECT COUNT(*) FROM agents.research_sources WHERE report_id = NEW.report_id AND tier = 2),
        tier3_sources_count = (SELECT COUNT(*) FROM agents.research_sources WHERE report_id = NEW.report_id AND tier = 3)
    WHERE id = NEW.report_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_sources_count_trigger
    AFTER INSERT OR DELETE ON agents.research_sources
    FOR EACH ROW EXECUTE FUNCTION agents.update_sources_count();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE agents.research_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents.research_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents.research_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents.research_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents.companies ENABLE ROW LEVEL SECURITY;

-- Políticas básicas (ajustar según necesidades)
CREATE POLICY "Public access to research_reports" ON agents.research_reports FOR ALL USING (true);
CREATE POLICY "Public access to research_sources" ON agents.research_sources FOR ALL USING (true);
CREATE POLICY "Public access to research_insights" ON agents.research_insights FOR ALL USING (true);
CREATE POLICY "Public access to research_executions" ON agents.research_executions FOR ALL USING (true);
CREATE POLICY "Public access to companies" ON agents.companies FOR ALL USING (true);

-- ============================================
-- DATOS DE EJEMPLO
-- ============================================

-- Insertar algunas empresas de ejemplo
INSERT INTO agents.companies (name, name_variations, sector, industry, country, founded_year, ticker_symbol) VALUES
('Tesla Inc', ARRAY['Tesla', 'Tesla Motors', 'Tesla Inc.'], 'Technology', 'Electric Vehicles', 'USA', 2003, 'TSLA'),
('BYD Company', ARRAY['BYD', 'Build Your Dreams'], 'Technology', 'Electric Vehicles', 'China', 1995, 'BYDDY'),
('Apple Inc', ARRAY['Apple', 'Apple Computer'], 'Technology', 'Consumer Electronics', 'USA', 1976, 'AAPL'),
('Microsoft Corporation', ARRAY['Microsoft', 'MSFT'], 'Technology', 'Software', 'USA', 1975, 'MSFT');

-- ============================================
-- FUNCIONES HELPER
-- ============================================

-- Función helper para búsquedas de empresas
CREATE OR REPLACE FUNCTION agents.find_company_by_name(company_name TEXT)
RETURNS UUID AS $$
DECLARE
    company_id UUID;
BEGIN
    SELECT id INTO company_id 
    FROM agents.companies 
    WHERE LOWER(name) = LOWER(company_name) 
       OR LOWER(company_name) = ANY(SELECT LOWER(unnest(name_variations)));
    
    -- Si no existe, crear entrada nueva
    IF company_id IS NULL THEN
        INSERT INTO agents.companies (name, sector) 
        VALUES (company_name, 'Unknown') 
        RETURNING id INTO company_id;
    END IF;
    
    RETURN company_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista de reportes con métricas agregadas
CREATE VIEW agents.v_reports_summary AS
SELECT 
    r.id,
    r.title,
    r.company_primary,
    r.sector,
    r.report_type,
    r.status,
    r.sources_count,
    r.tier1_sources_count + r.tier2_sources_count + r.tier3_sources_count as total_sources,
    r.word_count,
    r.execution_time_ms,
    r.created_at,
    COUNT(i.id) as insights_count,
    AVG(i.confidence_level) as avg_confidence
FROM agents.research_reports r
LEFT JOIN agents.research_insights i ON r.id = i.report_id
GROUP BY r.id, r.title, r.company_primary, r.sector, r.report_type, r.status, 
         r.sources_count, r.tier1_sources_count, r.tier2_sources_count, 
         r.tier3_sources_count, r.word_count, r.execution_time_ms, r.created_at;

-- Vista de top empresas por investigación
CREATE VIEW agents.v_top_researched_companies AS
SELECT 
    c.name,
    c.sector,
    c.industry,
    COUNT(r.id) as reports_count,
    MAX(r.created_at) as last_report_date,
    AVG(r.execution_time_ms) as avg_execution_time
FROM agents.companies c
LEFT JOIN agents.research_reports r ON c.name = r.company_primary
GROUP BY c.id, c.name, c.sector, c.industry
ORDER BY reports_count DESC;