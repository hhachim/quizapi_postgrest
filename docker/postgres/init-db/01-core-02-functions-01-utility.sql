-- -----------------------------------------------------
-- FONCTIONS CORE: Utilitaires
-- Fonctions utilitaires pour le système
-- -----------------------------------------------------

-- Fonction pour mettre à jour les timestamps des enregistrements modifiés
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;