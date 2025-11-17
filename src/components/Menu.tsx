import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";
import { Link } from "react-router-dom";

const Menu = () => {
  // Función para cerrar sesión del admin/empleado
  const cerrarSesion = () => {
    localStorage.removeItem("usuario"); // elimina el usuario logeado
    window.location.href = "/"; // redirige a la home pública
  };

  return (
    <div
      className="offcanvas offcanvas-start text-bg-light menu"
      id="offcanvasNavbar"
      aria-labelledby="offcanvasNavbarLabel"
      data-bs-scroll="true"
      data-bs-backdrop="false"
    >
      <div className="offcanvas-header border-bottom">
        <h5 className="offcanvas-title fw-bold text-dark" id="offcanvasNavbarLabel">
          Menú Principal
        </h5>
        <button
          type="button"
          className="btn-close btn-close-dark"
          data-bs-dismiss="offcanvas"
          aria-label="Close"
        ></button>
      </div>

      <div className="offcanvas-body">
        <ul className="navbar-nav justify-content-end flex-grow-1 pe-3">
          <li className="nav-item navegacion">
            <Link to="/dashboard" className="nav-link text-dark d-flex align-items-center gap-0">
              <i className="bi bi-speedometer2 me-2"></i> Dashboard
            </Link>
          </li>
          <li className="nav-item navegacion">
            <Link to="/vehiculos" className="nav-link text-dark d-flex align-items-center gap-2">
              <i className="bi bi-car-front-fill"></i> Vehículos
            </Link>
          </li>
          <li className="nav-item navegacion">
            <Link to="/clientes" className="nav-link text-dark d-flex align-items-center gap-2" data-bs-dismiss="offcanvas">
              <i className="bi bi-people-fill"></i> Clientes
            </Link>
          </li>
          <li className="nav-item navegacion">
            <Link to="/campanas" className="nav-link text-dark d-flex align-items-center gap-2" data-bs-dismiss="offcanvas">
              <i className="bi bi-megaphone-fill"></i> Campañas
            </Link>
          </li>
          <li className="nav-item navegacion">
            <Link to="/metricas" className="nav-link text-dark d-flex align-items-center gap-2" data-bs-dismiss="offcanvas">
              <i className="bi bi-bar-chart-fill"></i> Métricas
            </Link>
          </li>
          <li className="nav-item navegacion">
            <Link to="/reportes" className="nav-link text-dark d-flex align-items-center gap-2" data-bs-dismiss="offcanvas">
              <i className="bi bi-file-earmark-text-fill"></i> Reportes
            </Link>
          </li>
          <li className="nav-item navegacion">
            <Link to="/usuarios" className="nav-link text-dark d-flex align-items-center gap-2" data-bs-dismiss="offcanvas">
              <i className="bi bi-person-fill"></i> Usuarios
            </Link>
          </li>

          {/* BOTÓN CERRAR SESIÓN ADMIN */}
          <li className="nav-item navegacion mt-3">
            <button className="btn btn-danger w-100" onClick={cerrarSesion}>
              <i className="bi bi-box-arrow-right me-2"></i> Cerrar sesión
            </button>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default Menu;
