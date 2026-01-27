import { List, Table, Tag, Button } from "antd";
import { useTable } from "@refinedev/antd";
import { EyeOutlined } from "@ant-design/icons";
import { useNavigate } from "react-router-dom";

export const RideList = () => {
    const { tableProps } = useTable({
        resource: "rides",
        meta: {
            select: "*, clients:client_id(users(full_name)), drivers:driver_id(users(full_name))",
        },
        sorters: {
            initial: [
                { field: "created_at", order: "desc" }
            ]
        }
    });

    const navigate = useNavigate();

    return (
        <List>
            <h1>Courses</h1>
            <Table {...tableProps} rowKey="id">
                <Table.Column
                    dataIndex="created_at"
                    title="Date"
                    render={(val) => new Date(val).toLocaleString()}
                />
                <Table.Column
                    title="Client"
                    dataIndex={['clients', 'users', 'full_name']}
                    render={(val) => val ?? 'Inconnu'}
                />
                <Table.Column
                    title="Chauffeur"
                    dataIndex={['drivers', 'users', 'full_name']}
                    render={(val) => val ?? 'En attente'}
                />
                <Table.Column
                    dataIndex="status"
                    title="Statut"
                    render={(val) => (
                        <Tag color={
                            val === 'completed' ? 'green' :
                                val === 'cancelled' ? 'red' :
                                    val === 'in_progress' ? 'blue' : 'orange'
                        }>
                            {val.toUpperCase()}
                        </Tag>
                    )}
                />
                <Table.Column
                    dataIndex="total_price"
                    title="Prix"
                    render={(val) => `${val} FCFA`}
                />
                <Table.Column
                    title="Actions"
                    render={(_, record: any) => (
                        <Button
                            icon={<EyeOutlined />}
                            onClick={() => navigate(`show/${record.id}`)}
                        >
                            Détails
                        </Button>
                    )}
                />
            </Table>
        </List>
    );
};
