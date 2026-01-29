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
    // Fetch Stats (Using 'useList' to get counts)
    // For total rides today
    const { data: ridesData } = useList({
        resource: "rides",
        pagination: { mode: "off" }, // Warning: on large DB this is bad, normally use aggregate query
        meta: {
            select: "count",
        }
    });

    // For active drivers
    const { data: driversData } = useList({
        resource: "drivers",
        filters: [{ field: "is_available", operator: "eq", value: true }],
        pagination: { mode: "off" },
        meta: {
            select: "count",
        }
    });

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
                            title="Courses Totales"
                            value={ridesData?.total ?? 0}
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
                            value={1128}
                            prefix={<UserOutlined />}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card bordered={false}>
                        <Statistic
                            title="Revenus (Jour)"
                            value={254000}
                            prefix={<DollarOutlined />}
                            suffix="FCFA"
                        />
                    </Card>
                </Col>
            </Row>

            <Row gutter={24}>
                {/* Map Section */}
                <Col span={16}>
                    <Card title="Carte des Chauffeurs en Temps Réel" bodyStyle={{ padding: 0, height: "400px" }}>
                        <MapContainer center={position} zoom={13} style={{ height: "100%", width: "100%" }}>
                            <TileLayer
                                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>'
                                url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
                            />
                            {/* Mock markers based on driver count or real data if available in list */}
                            {driversData?.data.map((driver: any) => (
                                driver.current_latitude && driver.current_longitude ? (
                                    <Marker
                                        key={driver.id}
                                        position={[driver.current_latitude, driver.current_longitude]}
                                    >
                                        <Popup>
                                            {driver.vehicle_model} - {driver.license_plate}
                                        </Popup>
                                    </Marker>
                                ) : null
                            ))}
                        </MapContainer>
                    </Card>
                </Col>

                {/* Recent Activity */}
                <Col span={8}>
                    <Card title="Activités Récentes" style={{ height: "100%" }}>
                        <p style={{ color: "gray" }}>En attente de nouvelles courses...</p>
                        {/* Placeholder list */}
                        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                            {[1, 2, 3].map(i => (
                                <div key={i} style={{ padding: 10, background: "#f9f9f9", borderRadius: 4 }}>
                                    <div><b>Course #{1000 + i}</b> - En cours</div>
                                    <div style={{ fontSize: 12, color: "gray" }}>Il y a {i * 5} min</div>
                                </div>
                            ))}
                        </div>
                    </Card>
                </Col>
            </Row>
        </div>
    );
};
