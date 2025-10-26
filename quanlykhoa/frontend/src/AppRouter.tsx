import { createBrowserRouter, RouterProvider, Navigate } from "react-router-dom";
import { useAuth } from "./context/AuthContext";
import type { ReactElement } from "react";

import AppFrame from "./layout/AppFrame";

import HomePage from "./pages/HomePage";
import ClassDetailPage from "./pages/ClassDetailPage";
import Feature1 from "./pages/features/Feature1";
import Feature2 from "./pages/features/Feature2";
import Feature3 from "./pages/features/Feature3";
import Feature4 from "./pages/features/Feature4";
import Feature5 from "./pages/features/Feature5";
import Feature6 from "./pages/features/Feature6";
import AnnouncementDetailPage from "./pages/AnnouncementDetailPage";

import LoginPage from "./pages/auth/LoginPage";
import RegisterPage from "./pages/auth/RegisterPage";

function Guarded({ children }: { children: ReactElement }) {
  const { token } = useAuth();
  return token ? children : <Navigate to="/login" replace />;
}

function GuestOnly({ children }: { children: ReactElement }) {
  const { token } = useAuth();
  return token ? <Navigate to="/" replace /> : children;
}

const router = createBrowserRouter([
  {
    path: "/",
    element: (
      <Guarded>
        <AppFrame />
      </Guarded>
    ),
    children: [
      { index: true, element: <HomePage /> },
      { path: "classes/Flutter_11_CNPM1", element: <ClassDetailPage /> },
      { path: "classes/Flutter_11_CNPM1/announcements/0905", element: <AnnouncementDetailPage /> },
    ],
  },

  { path: "/login", element: <GuestOnly><LoginPage /></GuestOnly> },
  { path: "/register", element: <GuestOnly><RegisterPage /></GuestOnly> },

  { path: "*", element: <Navigate to="/" replace /> },
]);

export default function AppRouter() {
  return <RouterProvider router={router} />;
}
