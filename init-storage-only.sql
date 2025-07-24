-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create storage schema
CREATE SCHEMA IF NOT EXISTS storage;

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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS objects_bucket_id_idx ON storage.objects(bucket_id);
CREATE INDEX IF NOT EXISTS objects_name_idx ON storage.objects(name);
CREATE INDEX IF NOT EXISTS objects_owner_idx ON storage.objects(owner);

-- Insert a default bucket for testing
INSERT INTO storage.buckets (id, name, public) VALUES ('default', 'default', true)
ON CONFLICT (id) DO NOTHING;

-- Grant permissions
GRANT USAGE ON SCHEMA storage TO storage_user;
GRANT ALL ON ALL TABLES IN SCHEMA storage TO storage_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO storage_user;