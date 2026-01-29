-- ============================================
-- SEED DATA POUR DÉMONSTRATION VTC
-- ============================================

-- 1. Nettoyage (Optionnel - décommenter si besoin)
-- TRUNCATE TABLE public.rides CASCADE;
-- TRUNCATE TABLE public.drivers CASCADE;
-- TRUNCATE TABLE public.clients CASCADE;
-- DELETE FROM auth.users WHERE email LIKE '%@demo.com';

-- Pour la démo, on va créer des utilisateurs via SQL directement
-- NOTE: Dans un vrai scénario Supabase, on utilise l'API Auth
-- Ici on simule juste les entrées dans la table public.users et les tables liées

-- 2. Création de 5 Chauffeurs autour de Yaoundé (3.8480, 11.5021)

-- Helper pour créer un UUID constant pour la démo
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$
DECLARE
    driver1_id UUID := uuid_generate_v4();
    driver2_id UUID := uuid_generate_v4();
    driver3_id UUID := uuid_generate_v4();
    driver4_id UUID := uuid_generate_v4();
    driver5_id UUID := uuid_generate_v4();
    client_id UUID := uuid_generate_v4();
BEGIN

    -- Insérer les Users (Mock)
    -- On insère d'abord dans auth.users si possible, sinon on suppose que le trigger ne bloque pas
    -- Pour ce seed SQL pur, on insère directement dans public.users en assumant que l'ID existe ou que la FK est différée/mockée
    -- ATTENTION: Sur Supabase réel, il faut créer les users via l'Auth API.
    -- Ce script suppose que vous avez désactivé la FK stricte ou que vous avez créé ces users.
    
    -- Pour simplifier la démo, on va insérer des données qui "match" l'affichage frontend
    -- sans toucher à auth.users (ce qui pourrait échouer sans les bons droits admin).
    -- Si FK constraint error : Créez ces users manuellement dans Supabase Auth Dashboard.

    -- Simulation Drivers
    INSERT INTO public.users (id, email, phone, full_name, role, is_active) VALUES
    (driver1_id, 'driver1@demo.com', '+237600000001', 'Jean Dupont', 'driver', true),
    (driver2_id, 'driver2@demo.com', '+237600000002', 'Michel Fokou', 'driver', true),
    (driver3_id, 'driver3@demo.com', '+237600000003', 'Alain Talla', 'driver', true),
    (driver4_id, 'driver4@demo.com', '+237600000004', 'Ibrahim Sani', 'driver', true),
    (driver5_id, 'driver5@demo.com', '+237600000005', 'Paul Biya (Chauffeur)', 'driver', true)
    ON CONFLICT DO NOTHING;

    INSERT INTO public.drivers (id, vehicle_type, vehicle_brand, vehicle_model, vehicle_year, license_plate, driver_license, is_available, is_verified, current_latitude, current_longitude, rating) VALUES
    (driver1_id, 'standard', 'Toyota', 'Yaris', 2018, 'CE 123 AA', 'DL123456', true, true, 3.8480 + 0.002, 11.5021 + 0.002, 4.8),
    (driver2_id, 'comfort', 'Toyota', 'Camry', 2020, 'CE 888 BB', 'DL888888', true, true, 3.8480 - 0.003, 11.5021 - 0.001, 4.9),
    (driver3_id, 'moto', 'Honda', 'Ace', 2022, 'MOTO 11', 'DLMOTO1', true, true, 3.8480 + 0.001, 11.5021 - 0.004, 4.5),
    (driver4_id, 'standard', 'Hyundai', 'Accent', 2019, 'CE 777 CC', 'DL777777', true, true, 3.8480 - 0.005, 11.5021 + 0.005, 4.7),
    (driver5_id, 'van', 'Toyota', 'Hiace', 2015, 'CE 999 VV', 'DL999999', true, true, 3.8480 + 0.004, 11.5021 + 0.001, 5.0)
    ON CONFLICT DO NOTHING;

    -- Création d'un client démo
    INSERT INTO public.users (id, email, phone, full_name, role, is_active) VALUES
    (client_id, 'client@demo.com', '+237699999999', 'Demo Client', 'client', true)
    ON CONFLICT DO NOTHING;

    INSERT INTO public.clients (id, total_rides) VALUES
    (client_id, 12)
    ON CONFLICT DO NOTHING;

    -- 3. Création de quelques courses passées pour l'historique
    INSERT INTO public.rides (
        client_id, driver_id, 
        pickup_latitude, pickup_longitude, pickup_address,
        destination_latitude, destination_longitude, destination_address,
        status, vehicle_type, distance_km, total_price, 
        created_at, completed_at
    ) VALUES
    (client_id, driver1_id, 3.8, 11.5, 'Poste Centrale', 3.9, 11.6, 'Bastos', 'completed', 'standard', 5.2, 2500, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '20 minutes'),
    (client_id, driver2_id, 3.8, 11.5, 'Mvan', 3.82, 11.51, 'Tropicana', 'completed', 'comfort', 3.1, 2000, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '15 minutes'),
    (client_id, driver3_id, 3.85, 11.52, 'Mokolo', 3.86, 11.53, 'Madagascar', 'cancelled', 'moto', 0.0, 0, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '5 minutes');

END $$;
