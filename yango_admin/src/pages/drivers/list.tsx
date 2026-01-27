import { List, Table, Tag, Space, Button, notification } from "antd";
import { useTable } from "@refinedev/antd";
import { useNavigation } from "@refinedev/core";
import { CheckOutlined, CloseOutlined, EyeOutlined } from "@ant-design/icons";
import { supabaseClient } from "../../supabaseClient";

export const DriverList = () => {
    const { tableProps } = useTable({
        resource: "drivers",
        meta: {
            select: "*, users(full_name, phone, email)",
        },
    });

    const { show } = useNavigation();

    // Verify Driver Action
    const handleVerify = async (id: string, status: boolean) => {
        const { error } = await supabaseClient
            .from('drivers')
            .update({ is_verified: status })
            .eq('id', id);

        if (!error) {
            notification.success({ message: status ? 'Chauffeur vérifié' : 'Chauffeur rejeté' });
            // Ideally trigger refresh, but Refine might need manual invalidation or wait for SWR
        } else {
            notification.error({ message: 'Erreur', description: error.message });
        }
    };

    return (
        <List>
            <h1>Chauffeurs</h1>
            <Table {...tableProps} rowKey="id">
                <Table.Column
                    dataIndex={['users', 'full_name']}
                    title="Nom"
                    render={(val) => val ?? 'N/A'}
                />
                <Table.Column
                    dataIndex={['users', 'phone']}
                    title="Téléphone"
                />
                <Table.Column dataIndex="vehicle_type" title="Véhicule" />
                <Table.Column dataIndex="license_plate" title="Plaque" />
                <Table.Column
                    dataIndex="is_verified"
                    title="Statut"
                    render={(val) => (
                        <Tag color={val ? "green" : "red"}>
                            {val ? "VÉRIFIÉ" : "NON VÉRIFIÉ"}
                        </Tag>
                    )}
                />
                <Table.Column
                    dataIndex="is_available"
                    title="Dispo"
                    render={(val) => (
                        <Tag color={val ? "blue" : "default"}>
                            {val ? "EN LIGNE" : "HORS LIGNE"}
                        </Tag>
                    )}
                />
                <Table.Column
                    title="Actions"
                    render={(_, record: any) => (
                        <Space>
                            <Button
                                size="small"
                                icon={<EyeOutlined />}
                                onClick={() => show("drivers", record.id)}
                            />
                            {!record.is_verified && (
                                <Button
                                    size="small"
                                    type="primary"
                                    icon={<CheckOutlined />}
                                    onClick={() => handleVerify(record.id, true)}
                                >
                                    Valider
                                </Button>
                            )}
                            {record.is_verified && (
                                <Button
                                    size="small"
                                    danger
                                    icon={<CloseOutlined />}
                                    onClick={() => handleVerify(record.id, false)}
                                >
                                    Bloquer
                                </Button>
                            )}
                        </Space>
                    )}
                />
            </Table>
        </List>
    );
};
