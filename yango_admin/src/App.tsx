import { Refine } from "@refinedev/core";
import { useNotificationProvider } from "@refinedev/antd";
import routerBindings, {
  CatchAllNavigate,
  DocumentTitleHandler,
  UnsavedChangesNotifier,
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
              <Route
                element={
                  <div style={{ display: "flex", flexDirection: "row", minHeight: "100vh" }}>
                    <CustomSider />
                    <div style={{ flex: 1, padding: "24px", background: "#f0f2f5" }}>
                      <Outlet />
                    </div>
                  </div>
                }
              >
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
