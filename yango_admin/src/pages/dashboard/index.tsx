import { Card, Col, Row, Statistic } from "antd";
import { useList } from "@refinedev/core";
import { CarOutlined, UserOutlined, EnvironmentOutlined, DollarOutlined } from "@ant-design/icons";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
// Fix marker icons in Leaflet
import L from 'leaflet';
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconAnchor: [12, 41]
});

L.Marker.prototype.options.icon = DefaultIcon;

export const DashboardPage = () => {
    // Active Rides
    const { data: activeRides } = useList({
        resource: "rides",
        filters: [
            {
                field: "status",
                operator: "in",
                value: ["accepted", "driver_arriving", "in_progress"]
            }
        ],
        pagination: { mode: "off" },
    });

    // All Drivers (online) - Removed filter to show all if needed, or keep for online only
    const { data: driversData } = useList({
        resource: "drivers",
        filters: [{ field: "is_available", operator: "eq", value: true }],
        pagination: { mode: "off" },
    });

    // Users count (real fetch)
    const { data: usersData } = useList({
        resource: "users",
        filters: [{ field: "role", operator: "eq", value: "client" }],
        meta: { select: "count" }
    });

    // Revenue (Mock/Aggr) - Real aggregations need backend function usually
    const dailyRevenue = 254000;

    // Mock map center (Yaoundé)
    const position: [number, number] = [3.8480, 11.5021];

    return (
        <div style={{ padding: 24 }}>
            <h1>Dashboard</h1>

            {/* Stats Cards */}
            <Row gutter={16} style={{ marginBottom: 24 }}>
                <Col span={6}>
                    <Card bordered={false}>
                        <Statistic
                            title="Courses Actives"
                            value={activeRides?.total ?? 0}
                            prefix={<EnvironmentOutlined />}
                            valueStyle={{ color: '#00B14F' }}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card bordered={false}>
                        <Statistic
                            title="Chauffeurs en ligne"
                            value={driversData?.total ?? 0}
                            prefix={<CarOutlined />}
                            valueStyle={{ color: '#3f8600' }}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card bordered={false}>
                        <Statistic
                            title="Clients"
                            value={usersData?.total ?? 0}
                            prefix={<UserOutlined />}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card bordered={false}>
                        <Statistic
                            title="Revenus (Jour)"
                            value={dailyRevenue}
                            prefix={<DollarOutlined />}
                            suffix="FCFA"
                        />
                    </Card>
                </Col>
            </Row>

            <Row gutter={24}>
                {/* Map Section */}
                <Col span={16}>
                    <Card title="Carte Temps Réel (Chauffeurs & Courses)" bodyStyle={{ padding: 0, height: "500px" }}>
                        <MapContainer center={position} zoom={13} style={{ height: "100%", width: "100%" }}>
                            <TileLayer
                                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>'
                                url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
                            />

                            {/* 1. Drivers */}
                            {driversData?.data.map((driver: any) => (
                                driver.current_latitude && driver.current_longitude ? (
                                    <Marker
                                        key={`driver-${driver.id}`}
                                        position={[driver.current_latitude, driver.current_longitude]}
                                        icon={DefaultIcon}
                                    >
                                        <Popup>
                                            <b>{driver.vehicle_model}</b><br />
                                            {driver.license_plate}<br />
                                            <span style={{ color: 'green' }}>En ligne</span>
                                        </Popup>
                                    </Marker>
                                ) : null
                            ))}

                            {/* 2. Active Rides (Pickup & Destination) */}
                            {activeRides?.data.map((ride: any) => (
                                <>
                                    {/* Pickup (Green) */}
                                    <Marker
                                        key={`pickup-${ride.id}`}
                                        position={[ride.pickup_latitude, ride.pickup_longitude]}
                                        icon={L.divIcon({
                                            className: 'custom-icon',
                                            html: '<div style="background-color: green; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white;"></div>'
                                        })}
                                    >
                                        <Popup>Départ: {ride.pickup_address}</Popup>
                                    </Marker>

                                    {/* Destination (Red) */}
                                    <Marker
                                        key={`dest-${ride.id}`}
                                        position={[ride.destination_latitude, ride.destination_longitude]}
                                        icon={L.divIcon({
                                            className: 'custom-icon',
                                            html: '<div style="background-color: red; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white;"></div>'
                                        })}
                                    >
                                        <Popup>Arrivée: {ride.destination_address}</Popup>
                                    </Marker>

                                    {/* Line logic would go here (Polyline) if needed */}
                                </>
                            ))}

                        </MapContainer>
                    </Card>
                </Col>

                {/* Recent Activity */}
                <Col span={8}>
                    <Card title="Activités Récentes" style={{ height: "100%", overflowY: "auto" }}>
                        {activeRides?.data.length === 0 && <p style={{ color: "gray" }}>Aucune course active.</p>}

                        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                            {activeRides?.data.map((ride: any) => (
                                <div key={ride.id} style={{ padding: 10, background: "#f9f9f9", borderRadius: 4, borderLeft: "4px solid #00B14F" }}>
                                    <div style={{ fontWeight: 'bold' }}>Course en cours</div>
                                    <div style={{ fontSize: 12 }}>{ride.pickup_address} <br /> ➔ {ride.destination_address}</div>
                                    <div style={{ fontSize: 11, color: "gray", marginTop: 4 }}>
                                        {ride.status === 'driver_arriving' ? 'Chauffeur en route' : 'En cours'}
                                    </div>
                                </div>
                            ))}
                        </div>
                    </Card>
                </Col>
            </Row>
        </div>
    );
};
