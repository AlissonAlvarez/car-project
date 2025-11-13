import { Link } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap-icons/font/bootstrap-icons.css";
import "../styles/styles.css";

export default function Dashboard() {
  const modules = [
    { name: "Vehículos", icon: "bi bi-car-front-fill", color: "bg-danger", path: "/vehiculos" },
    { name: "Campañas", icon: "bi bi-megaphone-fill", color: "bg-primary", path: "/campanas" },
    { name: "Anuncios", icon: "bi bi-badge-ad-fill", color: "bg-success", path: "/anuncios" },
    { name: "Clientes", icon: "bi bi-people-fill", color: "bg-secondary", path: "/clientes" },
    { name: "Conversiones", icon: "bi bi-chat-dots-fill", color: "bg-warning", path: "/conversiones" },
    { name: "Cuentas Publicitarias", icon: "bi bi-briefcase-fill", color: "bg-info", path: "/cuentas" },
    { name: "Métricas", icon: "bi bi-bar-chart-fill", color: "bg-success", path: "/metricas" },
    { name: "Plataformas", icon: "bi bi-display-fill", color: "bg-primary", path: "/plataformas" },
    { name: "Reportes Personalizados", icon: "bi bi-file-earmark-text-fill", color: "bg-dark", path: "/reportes" },
    { name: "Segmentos Audiencias", icon: "bi bi-bullseye", color: "bg-danger", path: "/segmentos" },
    { name: "Usuarios", icon: "bi bi-person-fill", color: "bg-secondary", path: "/usuarios" },
  ];

  return (
    <section className="py-5 bg-light min-vh-100 w-100 dashboard-section">
      <div className="container-fluid px-5">
        <div className="text-center mb-5">
          <h2 className="fw-bold display-5 text-dark">
            <i className="bi bi-speedometer2 me-2"></i> Panel de Control
          </h2>
          <p className="text-muted">
            Gestion de módulos
          </p>
        </div>

        <div className="row g-4">
          {modules.map((module, i) => (
            <div key={i} className="col-12 col-sm-6 col-md-4 col-lg-3">
              {module.path ? (
                <Link to={module.path} className="text-decoration-none text-dark">
                  <div className="card shadow-sm border-0 h-100 text-center p-3 hover-card">
                    <div
                      className={`rounded-circle d-flex align-items-center justify-content-center text-white fs-3 mx-auto ${module.color}`}
                      style={{ width: "60px", height: "60px" }}
                    >
                      <i className={module.icon}></i>
                    </div>
                    <h5 className="mt-3 fw-semibold">{module.name}</h5>
                    <p className="text-muted small mb-0">
                      Acceder y gestionar información
                    </p>
                  </div>
                </Link>
              ) : (
                <div className="card shadow-sm border-0 h-100 text-center p-3 hover-card">
                  <div
                    className={`rounded-circle d-flex align-items-center justify-content-center text-white fs-3 mx-auto ${module.color}`}
                    style={{ width: "60px", height: "60px" }}
                  >
                    <i className={module.icon}></i>
                  </div>
                  <h5 className="mt-3 fw-semibold">{module.name}</h5>
                  <p className="text-muted small mb-0">
                    Acceder y gestionar información
                  </p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
