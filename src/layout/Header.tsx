import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap-icons/font/bootstrap-icons.css";
import Menu from "../components/Menu";
import "../styles/styles.css";
import user from "../svg/admin.svg";

const Header = () => {
  return (
    <>
      <nav className="navbar navbar-dark bg-dark shadow-lg fixed-top header">
        <div className="container-fluid">
          <button
            className="btn btn-outline-danger fs-6"
            type="button"
            data-bs-toggle="offcanvas"
            data-bs-target="#offcanvasNavbar"
            aria-controls="offcanvasNavbar"
          >
            <i className="bi bi-list"></i>
          </button>
          <img src={user} alt="Logo" height="40" className="ms-3" />
        </div>
      </nav>

      <Menu />
    </>
  );
};

export default Header;
