-- Indexes pour les tables core
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_is_active ON users(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_last_login ON users(last_login_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_name ON users(first_name, last_name) WHERE deleted_at IS NULL;
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);