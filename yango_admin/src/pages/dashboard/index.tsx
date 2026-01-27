import { Card, Col, Row, Statistic } from "antd";
import { useList } from "@refinedev/core";
import { CarOutlined, UserOutlined, EnvironmentOutlined, DollarOutlined } from "@ant-design/icons";

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

    return (
        <div style={{ padding: 24, marginLeft: 200 }}>
            <h1>Dashboard</h1>

            {/* Stats Cards */}
            <Row gutter={16}>
                <Col span={6}>
                    <Card>
                        <Statistic
                            title="Courses Totales"
                            value={ridesData?.total ?? 0}
                            prefix={<EnvironmentOutlined />}
                            valueStyle={{ color: '#00B14F' }}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card>
                        <Statistic
                            title="Chauffeurs en ligne"
                            value={driversData?.total ?? 0}
                            prefix={<CarOutlined />}
                            valueStyle={{ color: '#3f8600' }}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card>
                        <Statistic
                            title="Clients"
                            value={1128} // Placeholder
                            prefix={<UserOutlined />}
                        />
                    </Card>
                </Col>
                <Col span={6}>
                    <Card>
                        <Statistic
                            title="Revenus (Jour)"
                            value={254000} // Placeholder
                            prefix={<DollarOutlined />}
                            suffix="FCFA"
                        />
                    </Card>
                </Col>
            </Row>

            {/* TODO: Add Map and Charts here */}
            <div style={{ marginTop: 24 }}>
                <Card title="Courses récentes">
                    <p>Table placeholder...</p>
                </Card>
            </div>
        </div>
    );
};
