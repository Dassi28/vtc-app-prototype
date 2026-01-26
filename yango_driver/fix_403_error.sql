-- ACTIVEZ ces commandes dans l'éditeur SQL de Supabase

-- 1. Autoriser l'insertion dans la table users pour les utilisateurs authentifiés (pour qu'ils puissent créer leur propre profil)
CREATE POLICY "Enable insert for authenticated users only" ON "public"."users"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK ((auth.uid() = id));

-- 2. Autoriser l'insertion dans la table drivers
CREATE POLICY "Enable insert for authenticated users only" ON "public"."drivers"
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK ((auth.uid() = id));

-- 3. Alternative : Si vous avez des problèmes d'insertion lors du sign up (car l'utilisateur n'est pas encore 'complètement' authentifié selon le timing),
-- vous pouvez utiliser un TRIGGER automatique (Meilleure solution).

-- D'abord, supprimer l'insertion manuelle côté Flutter si vous utilisez ce trigger.
-- CREATE OR REPLACE FUNCTION public.handle_new_user()
-- RETURNS trigger AS $$
-- BEGIN
--   INSERT INTO public.users (id, email, full_name, phone, role)
--   VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'phone', 'driver');
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- POUR L'INSTANT, testez simplement en désactivant RLS sur ces tables si vous êtes en développement :
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.drivers DISABLE ROW LEVEL SECURITY;
