import React, { createContext, useState, useEffect } from "react";

interface Usuario {
  id_usuario: number;
  nombres: string;
  apellidos: string;
  email: string;
  rol: string;
}

interface UsuarioContextProps {
  usuario: Usuario | null;
  setUsuario: (u: Usuario | null) => void;
}

export const UsuarioContext = createContext<UsuarioContextProps>({
  usuario: null,
  setUsuario: () => {},
});

export const UsuarioProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [usuario, setUsuario] = useState<Usuario | null>(null);

  // Opcional: al montar la app puedes consultar backend para validar sesión
  useEffect(() => {
    fetch("http://localhost/proyectos/car-project/api/usuarios.php", {
      method: "GET",
      credentials: "include", // si usas cookies para sesión
    })
      .then(res => res.json())
      .then(data => {
        if (data.usuario) setUsuario(data.usuario);
      })
      .catch(() => setUsuario(null));
  }, []);

  return (
    <UsuarioContext.Provider value={{ usuario, setUsuario }}>
      {children}
    </UsuarioContext.Provider>
  );
};
