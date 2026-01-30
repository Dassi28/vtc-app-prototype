-- ================================================================
-- FIX: PERMISSION DE CRÉATION DE COMPTE
-- ================================================================
-- Problème : L'application tente d'insérer manuellement dans public.users après le sign-up via Auth.
-- Erreur : "Violates row-level security policy" car aucune policy d'INSERT n'existe sur public.users.
-- Solution : Autoriser l'insertion pour l'utilisateur authentifié (si l'ID correspond).

CREATE POLICY "Users can insert their own profile"
ON public.users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Vérification : Assurez-vous que RLS est bien activé (déjà fait dans migration.sql, mais rappel)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
