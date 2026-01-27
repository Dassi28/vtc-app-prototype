import { Show } from "@refinedev/antd";
import { useShow } from "@refinedev/core";
import { Typography, Descriptions, Row, Col, Card } from "antd";
import { MapContainer, TileLayer, Marker, Popup, Polyline } from "react-leaflet";

const { Title } = Typography;

export const RideShow = () => {
    const { queryResult } = useShow({
        resource: "rides",
        meta: {
            select: "*, clients:client_id(users(full_name, phone)), drivers:driver_id(users(full_name, phone))",
        },
    });
    const { data, isLoading } = queryResult;
    const record = data?.data;

    if (isLoading || !record) return <div>Loading...</div>;

    const pickup = [record.pickup_latitude, record.pickup_longitude];
    const dropoff = [record.destination_latitude, record.destination_longitude];
    const hasCoords = record.pickup_latitude && record.destination_latitude;

    return (
        <Show isLoading={isLoading}>
            <Title level={4}>Détails Course #{record.id ? String(record.id).substring(0, 8) : ''}</Title>

            <Row gutter={24}>
                <Col span={12}>
                    <Card title="Info Course">
                        <Descriptions column={1}>
                            <Descriptions.Item label="Statut">{record.status}</Descriptions.Item>
                            <Descriptions.Item label="Prix">{record.total_price} FCFA</Descriptions.Item>
                            <Descriptions.Item label="Distance">{record.distance_km} km</Descriptions.Item>
                            <Descriptions.Item label="Date">{new Date(record.created_at).toLocaleString()}</Descriptions.Item>
                        </Descriptions>
                    </Card>
                    <Card title="Acteurs" style={{ marginTop: 24 }}>
                        <Descriptions column={1}>
                            <Descriptions.Item label="Client">
                                {record.clients?.users?.full_name} ({record.clients?.users?.phone})
                            </Descriptions.Item>
                            <Descriptions.Item label="Chauffeur">
                                {record.drivers?.users?.full_name ?? 'Non assigné'}
                                {record.drivers?.users?.phone ? `(${record.drivers.users.phone})` : ''}
                            </Descriptions.Item>
                        </Descriptions>
                    </Card>
                    <Card title="Adresses" style={{ marginTop: 24 }}>
                        <Descriptions column={1}>
                            <Descriptions.Item label="Départ">{record.pickup_address}</Descriptions.Item>
                            <Descriptions.Item label="Arrivée">{record.destination_address}</Descriptions.Item>
                        </Descriptions>
                    </Card>
                </Col>

                <Col span={12}>
                    <Card title="Carte" bodyStyle={{ padding: 0, height: 400 }}>
                        {hasCoords ? (
                            <MapContainer
                                center={pickup as any}
                                zoom={13}
                                style={{ height: "100%", width: "100%" }}
                            >
                                <TileLayer
                                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                    attribution='&copy; OpenStreetMap contributors'
                                />
                                <Marker position={pickup as any}>
                                    <Popup>Départ: {record.pickup_address}</Popup>
                                </Marker>
                                <Marker position={dropoff as any}>
                                    <Popup>Arrivée: {record.destination_address}</Popup>
                                </Marker>
                                <Polyline positions={[pickup, dropoff] as any} color="red" />
                            </MapContainer>
                        ) : (
                            <div style={{ padding: 20 }}>Pas de coordonnées GPS</div>
                        )}
                    </Card>
                </Col>
            </Row>
        </Show>
    );
};
