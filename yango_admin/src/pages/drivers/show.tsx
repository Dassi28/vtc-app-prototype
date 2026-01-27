import { Show } from "@refinedev/antd";
import { useShow } from "@refinedev/core";
import { Typography, Descriptions, Tag } from "antd";

const { Title } = Typography;

export const DriverShow = () => {
    const { queryResult } = useShow({
        resource: "drivers",
        meta: {
            select: "*, users(*)",
        },
    });
    const { data, isLoading } = queryResult;
    const record = data?.data;

    if (isLoading) return <div>Loading...</div>;

    return (
        <Show isLoading={isLoading}>
            <Title level={4}>Détails Chauffeur</Title>
            <Descriptions bordered column={1}>
                <Descriptions.Item label="Nom Complet">
                    {record?.users?.full_name}
                </Descriptions.Item>
                <Descriptions.Item label="Email">
                    {record?.users?.email}
                </Descriptions.Item>
                <Descriptions.Item label="Téléphone">
                    {record?.users?.phone}
                </Descriptions.Item>

                <Descriptions.Item label="Statut">
                    <Tag color={record?.is_verified ? "green" : "red"}>
                        {record?.is_verified ? "VÉRIFIÉ" : "NON VÉRIFIÉ"}
                    </Tag>
                </Descriptions.Item>

                <Descriptions.Item label="Véhicule">
                    {record?.vehicle_brand} {record?.vehicle_model} ({record?.vehicle_type})
                </Descriptions.Item>
                <Descriptions.Item label="Plaque Immatriculation">
                    <Tag>{record?.license_plate}</Tag>
                </Descriptions.Item>

                <Descriptions.Item label="Gains Totaux">
                    {record?.total_earnings} FCFA
                </Descriptions.Item>

                <Descriptions.Item label="Note Moyenne">
                    {record?.rating} / 5.0
                </Descriptions.Item>

                <Descriptions.Item label="Dernière Position">
                    {record?.current_latitude}, {record?.current_longitude}
                </Descriptions.Item>
            </Descriptions>
        </Show>
    );
};
