-- Create a role for anonymous users
CREATE ROLE anon NOLOGIN;

-- Create a role for authenticated users
CREATE ROLE authenticated NOLOGIN;

-- Grant usage on the public schema to both roles
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant select permissions on all tables in the public schema to the anon role
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Grant select, insert, update, and delete permissions on all tables in the public schema to the authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- Ensure future tables and sequences in the public schema inherit these permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;