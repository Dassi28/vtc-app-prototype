import { List, Table } from "antd";
import { useTable } from "@refinedev/antd";

export const ClientList = () => {
    const { tableProps } = useTable({
        resource: "users",
        filters: {
            initial: [
                { field: "role", operator: "eq", value: "client" }
            ]
        }
    });

    return (
        <List>
            <h1>Clients</h1>
            <Table {...tableProps} rowKey="id">
                <Table.Column dataIndex="full_name" title="Nom" />
                <Table.Column dataIndex="email" title="Email" />
                <Table.Column dataIndex="phone" title="Téléphone" />
                <Table.Column
                    dataIndex="created_at"
                    title="Inscrit le"
                    render={(value) => new Date(value).toLocaleDateString()}
                />
            </Table>
        </List>
    );
};
