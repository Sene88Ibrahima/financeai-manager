-- Ajouter la colonne dernier_mois_applique à la table goals
ALTER TABLE goals 
ADD COLUMN dernier_mois_applique VARCHAR(7);

-- Mettre à jour les objectifs existants avec le mois courant
UPDATE goals 
SET dernier_mois_applique = TO_CHAR(CURRENT_DATE, 'YYYY-MM')
WHERE dernier_mois_applique IS NULL;

-- Ajouter un commentaire pour documenter la colonne
COMMENT ON COLUMN goals.dernier_mois_applique IS 'Format YYYY-MM pour tracker le dernier mois où le progrès a été appliqué';
