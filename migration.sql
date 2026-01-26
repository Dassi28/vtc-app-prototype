-- ============================================
-- 1. CRÉATION DES ENUMS
-- ============================================

CREATE TYPE user_role AS ENUM ('client', 'driver', 'admin');
CREATE TYPE ride_status AS ENUM ('pending', 'accepted', 'driver_arriving', 'in_progress', 'completed', 'cancelled');
CREATE TYPE vehicle_type AS ENUM ('moto', 'standard', 'comfort', 'van');
CREATE TYPE payment_method AS ENUM ('cash', 'mobile_money', 'card');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed');

-- ============================================
-- 2. TABLE USERS (Extension de auth.users)
-- ============================================

CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE,
    phone TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role user_role NOT NULL,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour recherche rapide
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_phone ON users(phone);

-- ============================================
-- 3. TABLE CLIENTS
-- ============================================

CREATE TABLE public.clients (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    address TEXT,
    favorite_locations JSONB DEFAULT '[]'::jsonb,
    total_rides INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 4. TABLE DRIVERS (CHAUFFEURS)
-- ============================================

CREATE TABLE public.drivers (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type vehicle_type NOT NULL,
    vehicle_brand TEXT NOT NULL,
    vehicle_model TEXT NOT NULL,
    vehicle_year INTEGER,
    license_plate TEXT UNIQUE NOT NULL,
    driver_license TEXT NOT NULL,
    is_available BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3,2) DEFAULT 5.00,
    total_rides INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    -- Position actuelle du chauffeur (sans PostGIS)
    current_latitude DOUBLE PRECISION,
    current_longitude DOUBLE PRECISION,
    last_location_update TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour recherche de chauffeurs disponibles
CREATE INDEX idx_drivers_available ON drivers(is_available) WHERE is_available = true;
CREATE INDEX idx_drivers_location ON drivers(current_latitude, current_longitude);

-- ============================================
-- 5. TABLE ADMINS
-- ============================================

CREATE TABLE public.admins (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    permissions JSONB DEFAULT '{"can_manage_users": true, "can_manage_rides": true, "can_view_stats": true}'::jsonb,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 6. TABLE RIDES (COURSES)
-- ============================================

CREATE TABLE public.rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id),
    driver_id UUID REFERENCES drivers(id),
    
    -- Informations de départ
    pickup_latitude DOUBLE PRECISION NOT NULL,
    pickup_longitude DOUBLE PRECISION NOT NULL,
    pickup_address TEXT NOT NULL,
    
    -- Informations de destination
    destination_latitude DOUBLE PRECISION NOT NULL,
    destination_longitude DOUBLE PRECISION NOT NULL,
    destination_address TEXT NOT NULL,
    
    -- Détails de la course
    status ride_status DEFAULT 'pending',
    vehicle_type vehicle_type NOT NULL,
    distance_km DECIMAL(10,2),
    duration_minutes INTEGER,
    
    -- Prix
    base_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    
    -- Paiement
    payment_method payment_method DEFAULT 'cash',
    payment_status payment_status DEFAULT 'pending',
    
    -- Évaluation
    client_rating INTEGER CHECK (client_rating >= 1 AND client_rating <= 5),
    driver_rating INTEGER CHECK (driver_rating >= 1 AND driver_rating <= 5),
    client_comment TEXT,
    driver_comment TEXT,
    
    -- Timestamps
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX idx_rides_client ON rides(client_id);
CREATE INDEX idx_rides_driver ON rides(driver_id);
CREATE INDEX idx_rides_status ON rides(status);
CREATE INDEX idx_rides_created ON rides(created_at DESC);

-- ============================================
-- 7. TABLE RIDE_REQUESTS (Demandes en attente)
-- ============================================

CREATE TABLE public.ride_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    driver_id UUID NOT NULL REFERENCES drivers(id),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'rejected', 'expired')),
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 seconds')
);

CREATE INDEX idx_ride_requests_driver ON ride_requests(driver_id);
CREATE INDEX idx_ride_requests_ride ON ride_requests(ride_id);

-- ============================================
-- 8. TABLE NOTIFICATIONS
-- ============================================

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- ============================================
-- 9. TABLE TRANSACTIONS
-- ============================================

CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES rides(id),
    driver_id UUID NOT NULL REFERENCES drivers(id),
    amount DECIMAL(10,2) NOT NULL,
    commission DECIMAL(10,2) NOT NULL,
    driver_earnings DECIMAL(10,2) NOT NULL,
    payment_method payment_method NOT NULL,
    status payment_status DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_transactions_driver ON transactions(driver_id);
CREATE INDEX idx_transactions_ride ON transactions(ride_id);

-- ============================================
-- 10. FONCTIONS UTILITAIRES (Version simplifiée)
-- ============================================

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour users
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour rides
CREATE TRIGGER update_rides_updated_at BEFORE UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer la distance entre deux points (formule Haversine)
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DOUBLE PRECISION,
    lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    earth_radius DOUBLE PRECISION := 6371; -- Rayon de la Terre en km
    dlat DOUBLE PRECISION;
    dlon DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
BEGIN
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    
    a := sin(dlat / 2) * sin(dlat / 2) +
         cos(radians(lat1)) * cos(radians(lat2)) *
         sin(dlon / 2) * sin(dlon / 2);
    
    c := 2 * atan2(sqrt(a), sqrt(1 - a));
    
    RETURN earth_radius * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Fonction pour trouver les chauffeurs disponibles à proximité
CREATE OR REPLACE FUNCTION find_nearby_drivers(
    pickup_lat DOUBLE PRECISION,
    pickup_lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5,
    vehicle_type_filter vehicle_type DEFAULT NULL
)
RETURNS TABLE (
    driver_id UUID,
    driver_name TEXT,
    vehicle_type vehicle_type,
    rating DECIMAL,
    distance_km DOUBLE PRECISION,
    current_latitude DOUBLE PRECISION,
    current_longitude DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        u.full_name,
        d.vehicle_type,
        d.rating,
        calculate_distance(pickup_lat, pickup_lon, d.current_latitude, d.current_longitude) AS distance,
        d.current_latitude,
        d.current_longitude
    FROM drivers d
    JOIN users u ON d.id = u.id
    WHERE d.is_available = true
        AND d.is_verified = true
        AND u.is_active = true
        AND d.current_latitude IS NOT NULL
        AND d.current_longitude IS NOT NULL
        AND (vehicle_type_filter IS NULL OR d.vehicle_type = vehicle_type_filter)
        AND calculate_distance(pickup_lat, pickup_lon, d.current_latitude, d.current_longitude) <= radius_km
    ORDER BY distance
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 11. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE ride_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Policies pour USERS
CREATE POLICY "Users can view their own profile"
    ON users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id);

-- Policies pour CLIENTS
CREATE POLICY "Clients can view their own data"
    ON clients FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Clients can update their own data"
    ON clients FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Clients can insert their own data"
    ON clients FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Policies pour DRIVERS
CREATE POLICY "Drivers can view their own data"
    ON drivers FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Drivers can update their own data"
    ON drivers FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Anyone can view available drivers"
    ON drivers FOR SELECT
    USING (is_available = true AND is_verified = true);

-- Policies pour RIDES
CREATE POLICY "Clients can view their own rides"
    ON rides FOR SELECT
    USING (client_id = auth.uid());

CREATE POLICY "Drivers can view their assigned rides"
    ON rides FOR SELECT
    USING (driver_id = auth.uid());

CREATE POLICY "Clients can create rides"
    ON rides FOR INSERT
    WITH CHECK (client_id = auth.uid());

CREATE POLICY "Drivers can update their assigned rides"
    ON rides FOR UPDATE
    USING (driver_id = auth.uid());

CREATE POLICY "Clients can update their rides"
    ON rides FOR UPDATE
    USING (client_id = auth.uid());

-- Policies pour NOTIFICATIONS
CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications"
    ON notifications FOR UPDATE
    USING (user_id = auth.uid());

-- Policies pour ADMINS (accès complet)
CREATE POLICY "Admins can view all users"
    ON users FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all rides"
    ON rides FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can update all rides"
    ON rides FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all drivers"
    ON drivers FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins WHERE id = auth.uid()
        )
    );

CREATE POLICY "Admins can view all clients"
    ON clients FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins WHERE id = auth.uid()
        )
    );