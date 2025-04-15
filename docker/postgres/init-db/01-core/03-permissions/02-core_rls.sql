-- -----------------------------------------------------
-- PERMISSIONS CORE: Row Level Security
-- Configuration de la sécurité au niveau des lignes pour les tables core
-- -----------------------------------------------------

-- Activer Row Level Security sur la table users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Politique pour la table users
CREATE POLICY users_self_policy ON users 
    FOR ALL 
    TO authenticated 
    USING (id = current_setting('request.jwt.claim.user_id', true)::UUID);

CREATE POLICY users_admin_policy ON users 
    FOR ALL 
    TO admin 
    USING (true);

-- Politique pour la table audit_logs (seul l'admin peut voir tous les logs)
CREATE POLICY audit_logs_admin_policy ON audit_logs 
    FOR ALL 
    TO admin 
    USING (true);

CREATE POLICY audit_logs_self_policy ON audit_logs 
    FOR SELECT 
    TO authenticated 
    USING (user_id = current_setting('request.jwt.claim.user_id', true)::UUID);