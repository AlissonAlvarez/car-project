import { useEffect, useState } from "react";
import "../styles/styles.css";

const API = "http://localhost/proyectos/car-project/api/vehiculos.php";
const API_USUARIOS = "http://localhost/proyectos/car-project/api/usuarios.php"; // tu API para login
const API_RESERVAS = "http://localhost/proyectos/car-project/api/reservas.php";

interface Vehiculo {
  placa: string;
  estado: string;
  color: string;
  año: number;
  precio_dia: number;
  kilometraje: number;
  id_modelo: string;
  id_seguro: string;
  descripcion: string;
  imagen_principal: string;
  nombre_modelo?: string;
  nombre_compania?: string;
}

interface Usuario {
  id_usuario: number;
  nombres: string;
  apellidos: string;
  email: string;
}

const HomeVehiculos = () => {
  const [vehiculos, setVehiculos] = useState<Vehiculo[]>([]);
  const [vehiculoSeleccionado, setVehiculoSeleccionado] = useState<Vehiculo | null>(null);
  const [modalReservaAbierto, setModalReservaAbierto] = useState(false);
  const [modalLoginAbierto, setModalLoginAbierto] = useState(false);
  const [usuario, setUsuario] = useState<Usuario | null>(null);

  // Login / Registro
  const [isLogin, setIsLogin] = useState(true); // true = login, false = registro
  const [loginData, setLoginData] = useState({ email: "", contraseña: "" });
  const [registroData, setRegistroData] = useState({ nombres: "", apellidos: "", email: "", contraseña: "" });

  // ------------------- Obtener vehículos -------------------
  const obtenerVehiculos = async () => {
    try {
      const res = await fetch(API);
      const data = await res.json();
      setVehiculos(data);
    } catch (err) {
      console.error(err);
      alert("Error al cargar vehículos");
    }
  };

  useEffect(() => {
    obtenerVehiculos();
  }, []);

  // ------------------- Modal reserva -------------------
  const abrirModalReserva = (vehiculo: Vehiculo) => {
    if (!usuario) {
      setModalLoginAbierto(true);
      return;
    }
    setVehiculoSeleccionado(vehiculo);
    setModalReservaAbierto(true);
  };

  const cerrarModalReserva = () => {
    setVehiculoSeleccionado(null);
    setModalReservaAbierto(false);
  };

  const cerrarModalLogin = () => setModalLoginAbierto(false);

// ------------------- Login / Registro -------------------
const manejarLoginChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setLoginData({ ...loginData, [e.target.name]: e.target.value });
};

const manejarRegistroChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setRegistroData({ ...registroData, [e.target.name]: e.target.value });
};

// Login
const loginUsuario = async () => {
  try {
    const res = await fetch(API_USUARIOS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: loginData.email,
        contrasena: loginData.contraseña, // mapear al enviar
      }),
    });
    const data = await res.json();
    if (data.success) {
      setUsuario(data.usuario);
      setModalLoginAbierto(false);
      alert("Login exitoso");
    } else {
      alert("Error en login: " + data.error);
    }
  } catch (err) {
    console.error(err);
    alert("Error al iniciar sesión");
  }
};

// Registro
const registrarUsuario = async () => {
  if (!registroData.nombres || !registroData.apellidos || !registroData.email || !registroData.contraseña) {
    alert("Todos los campos son obligatorios");
    return;
  }

  try {
    const res = await fetch(API_USUARIOS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        nombres: registroData.nombres,
        apellidos: registroData.apellidos,
        email: registroData.email,
        contrasena: registroData.contraseña, // mapear aquí
      }),
    });

    const data = await res.json();

    if (data.success) {
      // Login automático
      const loginRes = await fetch(API_USUARIOS, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: registroData.email,
          contrasena: registroData.contraseña, // mapear aquí también
        }),
      });
      const loginDataResponse = await loginRes.json();

      if (loginDataResponse.success) {
        setUsuario(loginDataResponse.usuario);
        setModalLoginAbierto(false);
        alert("Registro exitoso");
      } else {
        alert("Registro exitoso. Por favor inicia sesión");
        setIsLogin(true);
      }
    } else {
      alert("Error en registro: " + data.error);
    }
  } catch (err) {
    console.error(err);
    alert("Error al registrar usuario");
  }
};

  // ------------------- Confirmar reserva -------------------
  const confirmarReserva = async () => {
    if (!vehiculoSeleccionado || !usuario) return;

    const fechaInicio = (document.getElementById("fechaInicio") as HTMLInputElement).value;
    const fechaFin = (document.getElementById("fechaFin") as HTMLInputElement).value;
    const observaciones = (document.getElementById("observaciones") as HTMLTextAreaElement).value || "";

    if (!fechaInicio || !fechaFin) {
      alert("Debes seleccionar fechas de inicio y fin");
      return;
    }

    const reserva = {
      fecha_inicio: fechaInicio,
      fecha_fin: fechaFin,
      observaciones: observaciones,
      placa: vehiculoSeleccionado.placa,
      id_usuario: usuario.id_usuario,
    };

    try {
      const res = await fetch(API_RESERVAS, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(reserva),
      });
      const data = await res.json();
      if (data.success) {
        alert("Reserva creada con éxito");
        cerrarModalReserva();
      } else {
        alert("Error al crear la reserva: " + data.error);
      }
    } catch (err) {
      console.error(err);
      alert("Error al crear la reserva");
    }
  };

  return (
    <section className="container my-5">
      <h2 className="text-center fw-bold mb-4">Autos Disponibles</h2>

      <div className="row g-4">
        {vehiculos.map((v) => (
          <div key={v.placa} className="col-lg-3 col-md-6">
            <div className="card car-card shadow-sm h-100 rounded-0 overflow-hidden tarjeta">
              {v.imagen_principal ? (
                <img
                  src={v.imagen_principal}
                  className="card-img-top"
                  alt={v.nombre_modelo}
                  style={{ height: "200px", objectFit: "cover", transition: "transform 0.3s", borderRadius: "0" }}
                  onMouseOver={(e) => (e.currentTarget.style.transform = "scale(1.05)")}
                  onMouseOut={(e) => (e.currentTarget.style.transform = "scale(1)")}
                />
              ) : (
                <div
                  style={{
                    height: "200px",
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    backgroundColor: "#e9ecef",
                    color: "#6c757d",
                    fontWeight: 500,
                  }}
                >
                  Sin imagen
                </div>
              )}

              <div className="card-body text-center">
                <h5 className="fw-bold">{v.nombre_modelo}</h5>
                <p className="text-muted mb-2">{v.descripcion}</p>
                <ul className="list-unstyled mb-2 text-start" style={{ fontSize: "0.85rem" }}>
                  <li><strong>Placa:</strong> {v.placa}</li>
                  <li><strong>Estado:</strong> {v.estado}</li>
                  <li><strong>Color:</strong> {v.color}</li>
                  <li><strong>Año:</strong> {v.año}</li>
                  <li><strong>Kilometraje:</strong> {v.kilometraje} km</li>
                  <li><strong>Precio/día:</strong> <span className="text-danger fw-bold">${v.precio_dia}</span></li>
                </ul>
              </div>

              <div className="card-footer bg-white border-0 p-2">
                <button className="btn btn-secondary fw-bold w-100" onClick={() => abrirModalReserva(v)}>
                  Reservar
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* ------------------- Modal Login / Registro ------------------- */}
      {modalLoginAbierto && (
        <div className="modal show d-block" tabIndex={-1}>
          <div className="modal-dialog modal-sm modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">{isLogin ? "Iniciar Sesión" : "Registrarse"}</h5>
                <button type="button" className="btn-close" onClick={cerrarModalLogin}></button>
              </div>
              <div className="modal-body">
                {isLogin ? (
                  <>
                    <div className="mb-3">
                      <label className="form-label">Email</label>
                      <input type="email" className="form-control" name="email" onChange={manejarLoginChange} />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Contraseña</label>
                      <input type="password" className="form-control" name="contraseña" onChange={manejarLoginChange} />
                    </div>
                    <button className="btn btn-danger w-100" onClick={loginUsuario}>Iniciar Sesión</button>
                    <p className="mt-2 text-center">
                      ¿No tienes cuenta? <span style={{ cursor: "pointer", color: "blue" }} onClick={() => setIsLogin(false)}>Regístrate</span>
                    </p>
                  </>
                ) : (
                  <>
                    <div className="mb-3">
                      <label className="form-label">Nombres</label>
                      <input type="text" className="form-control" name="nombres" onChange={manejarRegistroChange} />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Apellidos</label>
                      <input type="text" className="form-control" name="apellidos" onChange={manejarRegistroChange} />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Email</label>
                      <input type="email" className="form-control" name="email" onChange={manejarRegistroChange} />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Contraseña</label>
                      <input type="password" className="form-control" name="contraseña" onChange={manejarRegistroChange} />
                    </div>
                    <button className="btn btn-danger w-100" onClick={registrarUsuario}>Registrarse</button>
                    <p className="mt-2 text-center">
                      ¿Ya tienes cuenta? <span style={{ cursor: "pointer", color: "blue" }} onClick={() => setIsLogin(true)}>Iniciar sesión</span>
                    </p>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ------------------- Modal Reserva ------------------- */}
      {modalReservaAbierto && vehiculoSeleccionado && (
        <div className="modal show d-block" tabIndex={-1}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content">
              <div className="modal-header">
                <h5 className="modal-title">Reservar: {vehiculoSeleccionado.nombre_modelo}</h5>
                <button type="button" className="btn-close" onClick={cerrarModalReserva}></button>
              </div>
              <div className="modal-body">
                <p><strong>Placa:</strong> {vehiculoSeleccionado.placa}</p>
                <p><strong>Precio/día:</strong> ${vehiculoSeleccionado.precio_dia}</p>
                <form>
                  <div className="mb-3">
                    <label htmlFor="fechaInicio" className="form-label">Fecha de Inicio</label>
                    <input type="date" className="form-control" id="fechaInicio" />
                  </div>
                  <div className="mb-3">
                    <label htmlFor="fechaFin" className="form-label">Fecha de Fin</label>
                    <input type="date" className="form-control" id="fechaFin" />
                  </div>
                  <div className="mb-3">
                    <label htmlFor="observaciones" className="form-label">Observaciones</label>
                    <textarea className="form-control" id="observaciones" rows={3}></textarea>
                  </div>
                </form>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-secondary" onClick={cerrarModalReserva}>Cancelar</button>
                <button type="button" className="btn btn-danger" onClick={confirmarReserva}>Confirmar Reserva</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </section>
  );
};

export default HomeVehiculos;
