import { useMenu, useLogout } from "@refinedev/core";
import { Layout, Menu, Button } from "antd";
import {
    DashboardOutlined,
    UserOutlined,
    CarOutlined,
    EnvironmentOutlined,
    LogoutOutlined,
} from "@ant-design/icons";
import { Link } from "react-router-dom";

const { Sider } = Layout;

export const CustomSider = () => {
    const { menuItems, selectedKey } = useMenu();
    const { mutate: logout } = useLogout();

    return (
        <Sider width={200} style={{ background: "#fff", height: "100vh", position: "fixed", left: 0, top: 0, bottom: 0 }}>
            {/* Logo Area */}
            <div style={{ padding: "20px", textAlign: "center", borderBottom: "1px solid #f0f0f0" }}>
                <h1 style={{ color: "#00B14F", margin: 0, fontSize: "20px" }}>Yango Admin</h1>
            </div>

            {/* Menu */}
            <Menu
                mode="inline"
                selectedKeys={[selectedKey]}
                style={{ height: "calc(100% - 150px)", borderRight: 0 }}
                items={menuItems.map((item) => ({
                    key: item.key,
                    icon: getIcon(item.name),
                    label: <Link to={item.route ?? "/"}>{item.label}</Link>,
                }))}
            />

            {/* Logout Button */}
            <div style={{ position: "absolute", bottom: 20, width: "100%", padding: "0 20px" }}>
                <Button
                    type="primary"
                    danger
                    block
                    icon={<LogoutOutlined />}
                    onClick={() => logout()}
                >
                    Déconnexion
                </Button>
            </div>
        </Sider>
    );
};

// Helper for icons
const getIcon = (name: string) => {
    switch (name) {
        case "dashboard": return <DashboardOutlined />;
        case "drivers": return <CarOutlined />;
        case "clients": return <UserOutlined />;
        case "rides": return <EnvironmentOutlined />;
        default: return <DashboardOutlined />;
    }
};
