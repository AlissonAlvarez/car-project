import { useState, createContext, useEffect } from "react";
import logo from "../svg/logo-alqui-auto-.svg";
import LoginRegister from "../components/modals/LoginRegister";

export const AbrirLoginContext = createContext<() => void>(() => {});

interface Usuario {
  id_usuario: number;
  nombres: string;
  apellidos: string;
  email: string;
}

const HeaderWeb = ({ children }: { children?: React.ReactNode }) => {

  const [showModal, setShowModal] = useState(false);

  const [usuario, setUsuario] = useState<Usuario | null>(null);

  useEffect(() => {
    const data = localStorage.getItem("usuario");
    if (data) setUsuario(JSON.parse(data) as Usuario);
  }, []);

  const openLoginExternamente = () => setShowModal(true);

  const cerrarSesion = () => {
    localStorage.removeItem("usuario");
    setUsuario(null);
    window.location.reload();
  };

  return (
    <AbrirLoginContext.Provider value={openLoginExternamente}>
      <header style={{ zIndex: 1000 }}>
        <div className="bg-dark text-white py-1">
          <div className="container d-flex justify-content-between align-items-center">
            <div>
              <i className="bi bi-telephone me-2"></i>
              Llámanos gratis: +57 310 000 0000
            </div>
          </div>
        </div>

        <nav
          className="navbar navbar-expand-lg"
          style={{ backgroundColor: "#800020", padding: "0.5rem 0" }}
        >
          <div className="container d-flex justify-content-between align-items-center">
            <a className="navbar-brand d-flex align-items-center" href="/">
              <img
                src={logo}
                alt="Logo"
                style={{ height: "60px", marginRight: "10px" }}
              />
              <span className="fw-bold text-white">AlquiAuto</span>
            </a>

            <ul className="list-unstyled d-flex mb-0 gap-4">
              <li>
                <a
                  href="/"
                  className="text-white fw-medium text-decoration-none"
                  style={{ transition: "color 0.3s" }}
                  onMouseOver={(e) => (e.currentTarget.style.color = "#f0a500")}
                  onMouseOut={(e) => (e.currentTarget.style.color = "#fff")}
                >
                  Alquiler de vehciulos
                </a>
              </li>
            </ul>

            {/* SI EL USUARIO NO ESTÁ LOGUEADO */}
            {!usuario && (
              <a
                className="btn btn-outline-light"
                style={{ minWidth: "120px" }}
                onClick={() => setShowModal(true)}
              >
                Iniciar Sesión
              </a>
            )}

            {/* SI EL USUARIO ESTÁ LOGUEADO → ICONO CON DROPDOWN */}
            {usuario && (
              <div className="dropdown">
                <i
                  className="bi bi-person-circle text-white"
                  style={{
                    fontSize: "2.2rem",
                    cursor: "pointer",
                  }}
                  data-bs-toggle="dropdown"
                  title="Mi cuenta"
                ></i>

                <ul className="dropdown-menu dropdown-menu-end mt-2 shadow">
                  <li className="dropdown-item text-center fw-bold">
                    {usuario.nombres}
                  </li>

                  <li><hr className="dropdown-divider" /></li>

                  <li>
                    <button
                      className="dropdown-item text-danger fw-bold"
                      onClick={cerrarSesion}
                    >
                      <i className="bi bi-box-arrow-right me-2"></i>
                      Cerrar sesión
                    </button>
                  </li>
                </ul>
              </div>
            )}

            {showModal && (
              <LoginRegister
                onClose={() => setShowModal(false)}
                modoReserva={false}
                vehiculo={null}
              />
            )}
          </div>
        </nav>

        {children}
      </header>
    </AbrirLoginContext.Provider>
  );
};

export default HeaderWeb;
