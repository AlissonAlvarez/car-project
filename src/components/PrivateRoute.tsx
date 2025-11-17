import React from "react";
import { Navigate } from "react-router-dom";

interface PrivateRouteProps {
  children: JSX.Element;
  rolesPermitidos: string[]; // Ej: ["Administrador", "Empleado"]
}

const PrivateRoute: React.FC<PrivateRouteProps> = ({ children, rolesPermitidos }) => {
  const stored = localStorage.getItem("usuario");
  if (!stored) return <Navigate to="/" />; // no logueado → home

  const usuario = JSON.parse(stored);

  if (!rolesPermitidos.includes(usuario.rol)) return <Navigate to="/" />;

  return children;
};

export default PrivateRoute;
