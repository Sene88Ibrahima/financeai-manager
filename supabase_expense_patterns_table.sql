-- Création de la table expense_patterns
CREATE TABLE IF NOT EXISTS public.expense_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom TEXT NOT NULL,
    categorie TEXT NOT NULL,
    montant_journalier DECIMAL(10,2) NOT NULL,
    jours_actifs INTEGER[] NOT NULL,
    est_actif BOOLEAN DEFAULT true,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activer RLS (Row Level Security)
ALTER TABLE public.expense_patterns ENABLE ROW LEVEL SECURITY;

-- Politique pour que les utilisateurs ne voient que leurs propres patterns
CREATE POLICY "Users can view own expense patterns" ON public.expense_patterns
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expense patterns" ON public.expense_patterns
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expense patterns" ON public.expense_patterns
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expense patterns" ON public.expense_patterns
    FOR DELETE USING (auth.uid() = user_id);

-- Ajouter un trigger pour updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER expense_patterns_updated_at
    BEFORE UPDATE ON public.expense_patterns
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
