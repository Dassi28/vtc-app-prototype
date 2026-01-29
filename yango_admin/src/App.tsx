import { Refine, Authenticated } from "@refinedev/core";
import { useNotificationProvider, AuthPage } from "@refinedev/antd";
import routerBindings, {
  CatchAllNavigate,
  DocumentTitleHandler,
  UnsavedChangesNotifier,
  NavigateToResource,
} from "@refinedev/react-router-v6";
import { dataProvider } from "@refinedev/supabase";
import { BrowserRouter, Outlet, Route, Routes } from "react-router-dom";
import { ConfigProvider, App as AntdApp } from "antd";

import { supabaseClient } from "./supabaseClient";
import { authProvider } from "./authProvider";
import { CustomSider } from "./components/layout/CustomSider"; // We will create this
import { DashboardPage } from "./pages/dashboard"; // We will create this
import { DriverList, DriverShow, DriverCreate } from "./pages/drivers"; // We will create this
import { ClientList } from "./pages/clients"; // We will create this
import { RideList, RideShow } from "./pages/rides"; // We will create this

import "./index.css";

function App() {
  return (
    <BrowserRouter>
      <ConfigProvider
        theme={{
          token: {
            colorPrimary: "#00B14F",
            fontFamily: "Montserrat, sans-serif",
          },
        }}
      >
        <AntdApp>
          <Refine
            dataProvider={dataProvider(supabaseClient)}
            authProvider={authProvider}
            routerProvider={routerBindings}
            notificationProvider={useNotificationProvider}
            resources={[
              {
                name: "dashboard",
                list: "/dashboard",
              },
              {
                name: "drivers",
                list: "/drivers",
                show: "/drivers/show/:id",
                create: "/drivers/create",
                meta: { label: "Chauffeurs" },
              },
              {
                name: "clients",
                list: "/clients",
                meta: { label: "Clients" },
              },
              {
                name: "rides",
                list: "/rides",
                show: "/rides/show/:id",
                meta: { label: "Courses" },
              },
            ]}
            options={{
              syncWithLocation: true,
              warnWhenUnsavedChanges: true,
            }}
          >
            <Routes>
              {/* Public Routes (Login/Register) */}
              <Route
                element={
                  <Authenticated
                    key="authenticated-outer"
                    fallback={<Outlet />}
                  >
                    <NavigateToResource />
                  </Authenticated>
                }
              >
                <Route
                  path="/login"
                  element={
                    <AuthPage
                      type="login"
                      title={
                        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "10px" }}>
                          <div style={{ width: 32, height: 32, background: "#00B14F", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", color: "white", fontWeight: "bold" }}>Y</div>
                          <span style={{ color: "#00B14F", fontSize: "20px", fontWeight: "bold" }}>Yango Admin</span>
                        </div>
                      }
                      formProps={{
                        initialValues: { email: "admin@demo.com", password: "password123" },
                      }}
                    />
                  }
                />
                <Route
                  path="/register"
                  element={<AuthPage type="register" />}
                />
              </Route>

              {/* Protected Routes */}
              <Route
                element={
                  <Authenticated
                    key="authenticated-inner"
                    fallback={<CatchAllNavigate to="/login" />}
                  >
                    <div style={{ display: "flex", flexDirection: "row", minHeight: "100vh" }}>
                      <CustomSider />
                      <div style={{ flex: 1, padding: "24px", background: "#f0f2f5", marginLeft: "200px" }}>
                        <Outlet />
                      </div>
                    </div>
                  </Authenticated>
                }
              >
                <Route path="/" element={<NavigateToResource resource="dashboard" />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/drivers">
                  <Route index element={<DriverList />} />
                  <Route path="show/:id" element={<DriverShow />} />
                  <Route path="create" element={<DriverCreate />} />
                </Route>
                <Route path="/clients" element={<ClientList />} />
                <Route path="/rides">
                  <Route index element={<RideList />} />
                  <Route path="show/:id" element={<RideShow />} />
                </Route>
                <Route path="*" element={<CatchAllNavigate to="/dashboard" />} />
              </Route>
            </Routes>
            <UnsavedChangesNotifier />
            <DocumentTitleHandler />
          </Refine>
        </AntdApp>
      </ConfigProvider>
    </BrowserRouter >
  );
}

export default App;
