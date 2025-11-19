import { useEffect, useState } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap-icons/font/bootstrap-icons.css";
import Menu from "../components/Menu";
import "../styles/styles.css";
import userImg from "../svg/admin.svg";

interface Usuario {
  id_usuario: number;
  nombres: string;
  apellidos: string;
  email: string;
  rol?: string;
}

const Header = () => {
  const [usuario, setUsuario] = useState<Usuario | null>(null);

  useEffect(() => {
    const stored = localStorage.getItem("usuario");
    if (stored) {
      setUsuario(JSON.parse(stored));
    }
  }, []);

  return (
    <>
      <nav className="navbar navbar-dark bg-dark shadow-lg fixed-top header">
        <div className="container-fluid d-flex align-items-center justify-content-between">

          <button
            className="btn btn-outline-danger fs-6"
            type="button"
            data-bs-toggle="offcanvas"
            data-bs-target="#offcanvasNavbar"
          >
            <i className="bi bi-list"></i>
          </button>

          <div className="d-flex align-items-center gap-2 position-relative">
            {usuario && (
              <span className="text-white fw-semibold">
                {usuario.nombres}
              </span>
            )}

            <div className="position-relative">
              <img src={userImg} alt="Logo" height="40" className="rounded-circle" />

              {usuario && (
                <span
                  className="position-absolute bg-success rounded-circle"
                  style={{
                    width: "12px",
                    height: "12px",
                    bottom: "0",
                    right: "0",
                    border: "2px solid white",
                  }}
                ></span>
              )}
            </div>
          </div>

        </div>
      </nav>

      <Menu />
    </>
  );
};

export default Header;
