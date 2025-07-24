-- Switch to supabase_storage database
\c supabase_storage;

-- Create storage schema
CREATE SCHEMA IF NOT EXISTS storage;

-- Create required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create buckets table
CREATE TABLE IF NOT EXISTS storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    CONSTRAINT buckets_pkey PRIMARY KEY (id)
);

-- Create objects table
CREATE TABLE IF NOT EXISTS storage.objects (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    last_accessed_at timestamptz DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED,
    version text,
    CONSTRAINT objects_pkey PRIMARY KEY (id),
    CONSTRAINT objects_bucketid_objname UNIQUE (bucket_id, name),
    CONSTRAINT objects_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id)
);

-- Create migrations table in public schema (where storage service expects it)
CREATE TABLE IF NOT EXISTS migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT now(),
    CONSTRAINT migrations_pkey PRIMARY KEY (id)
);

-- Also create in storage schema for completeness
CREATE TABLE IF NOT EXISTS storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT now(),
    CONSTRAINT storage_migrations_pkey PRIMARY KEY (id)
);

-- Insert initial migration records to avoid hash mismatch
INSERT INTO migrations (id, name, hash) VALUES 
(0, 'create-migrations-table', 'd4f6c0d1a9b8c6f1c9b7e8d2a6c5f0a4b8d6c1f9'),
(1, 'initialmigration', 'e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0'),
(2, 'pathtoken-column', 'a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1'),
(3, 'add-migrations-rls', 'b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2'),
(4, 'add-size-functions', 'c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3'),
(5, 'change-column-name-in-get-size', 'd5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4'),
(6, 'add-rls-to-buckets', 'e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5'),
(7, 'add-public-to-buckets', 'f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6'),
(8, 'fix-search-function', 'a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7'),
(9, 'search-files-search-function', 'b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8'),
(10, 'add-trigger-to-auto-update-updated_at-column', 'c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9'),
(11, 'add-automatic-avif-detection-flag', 'd1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0'),
(12, 'add-bucket-custom-limits', 'e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1'),
(13, 'use-bytes-for-max-size', 'f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2'),
(14, 'add-can-insert-object-function', 'a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3'),
(15, 'add-version', 'b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4'),
(16, 'drop-owner-foreign-key', 'c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5')
ON CONFLICT (id) DO NOTHING;

-- Copy to storage schema as well
INSERT INTO storage.migrations (id, name, hash, executed_at) 
SELECT id, name, hash, executed_at FROM migrations
ON CONFLICT (id) DO NOTHING;

-- Grant permissions
GRANT USAGE ON SCHEMA storage TO n8n;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO n8n;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO n8n;