import logo from "../svg/logo-alqui-auto-.svg"

const HeaderWeb = () => {

  return (
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
                Inicio
              </a>
            </li>
            <li>
              <a
                href="/conocenos"
                className="text-white fw-medium text-decoration-none"
                style={{ transition: "color 0.3s" }}
                onMouseOver={(e) => (e.currentTarget.style.color = "#f0a500")}
                onMouseOut={(e) => (e.currentTarget.style.color = "#fff")}
              >
                Sobre Nosotros
              </a>
            </li>
          </ul>

          <a
            href="/cuenta"
            className="btn btn-outline-light"
            style={{ minWidth: "120px" }}
          >
            Iniciar Sesión
          </a>
        </div>
      </nav>
    </header>
  );
};

export default HeaderWeb;
