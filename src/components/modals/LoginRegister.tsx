import React, { useState } from "react";

interface Usuario {
  id_usuario: number;
  nombres: string;
  apellidos: string;
  email: string;
  rol?: string; // agregado para manejar roles
}

interface Vehiculo {
  placa: string;
  precio_dia: number;
  nombre_modelo?: string;
}

interface Props {
  onClose: () => void;
  modoReserva: boolean;
  vehiculo: Vehiculo | null;
  onReservaExitosa?: (placa: string) => void;
}

const API_USUARIOS = "http://localhost/proyectos/car-project/api/usuarios.php";
const API_RESERVAS = "http://localhost/proyectos/car-project/api/reservas.php";

export default function LoginRegister({ onClose, modoReserva, vehiculo }: Props) {
  const [, setUsuario] = useState<Usuario | null>(null);

  const [isLogin, setIsLogin] = useState(true);
  const [loginData, setLoginData] = useState({ email: "", contrasena: "" });

  const [registroData, setRegistroData] = useState({
    nombres: "",
    apellidos: "",
    email: "",
    contrasena: ""
  });

  // ---------------- LOGIN ----------------
  const loginUsuario = async () => {
  try {
    const res = await fetch(API_USUARIOS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(loginData),
    });

    const data = await res.json();

    if (data.success) {
      const usuario = data.usuario;

      // ADMIN CON CONTRASEÑA POR DEFECTO
      if (usuario.email === "admin@alquiler.com" && loginData.contrasena === "admin123") {
        usuario.rol = "Administrador";
      } else {
        // TODOS LOS DEMÁS SON CLIENTES
        usuario.rol = "Cliente";
      }

      localStorage.setItem("usuario", JSON.stringify(usuario));
      setUsuario(usuario);

      onClose();
      alert("Login exitoso");
      if (usuario.rol === "Administrador") {
        window.location.href = "/dashboard";
      } else {
        window.location.href = "/";
      }

    } else {
      alert("Error: " + data.error);
    }
  } catch {
    alert("Error en login");
  }
};


  // ---------------- REGISTRO ----------------
const registrarUsuario = async () => {
  try {
    const res = await fetch(API_USUARIOS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(registroData),
    });

    const data = await res.json();

    if (data.success) {
      const usuario = data.usuario;
      localStorage.setItem("usuario", JSON.stringify(usuario));
      setUsuario(usuario);
      alert("Registro exitoso");
      onClose();
    } else {
      alert("Error: " + data.error);
    }
  } catch {
    alert("Error al registrar usuario");
  }
};


  // ---------------- RESERVA ----------------
  const reservar = async () => {
    const stored = localStorage.getItem("usuario");
    if (!stored) return alert("Debes iniciar sesión");

    const user = JSON.parse(stored);

    const fechaInicio = (document.getElementById("fechaInicio") as HTMLInputElement).value;
    const fechaFin = (document.getElementById("fechaFin") as HTMLInputElement).value;
    const observaciones = (document.getElementById("observaciones") as HTMLTextAreaElement).value;

    if (!fechaInicio || !fechaFin) return alert("Selecciona fechas");

    const data = {
      fecha_inicio: fechaInicio,
      fecha_fin: fechaFin,
      observaciones,
      placa: vehiculo?.placa,
      id_usuario: user.id_usuario,
      id_sucursal: "SUC001",
    };

    const res = await fetch(API_RESERVAS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    const json = await res.json();

    if (json.success) {
      alert("Reserva creada");
      onClose();
    } else {
      alert("Error al crear reserva");
    }
  };

  return (
    <>
      <div className="modal-backdrop fade show"></div>

      <div className="modal show d-block">
        <div className="modal-dialog modal-dialog-centered">
          <div className="modal-content">

            <div className="modal-header">
              <h5 className="modal-title">
                {modoReserva ? "Reservar Vehículo" : isLogin ? "Iniciar Sesión" : "Registrarse"}
              </h5>
              <button className="btn-close" onClick={onClose}></button>
            </div>

            <div className="modal-body">

              {/* --------------------- MODO RESERVA --------------------- */}
              {modoReserva && vehiculo ? (
                <>
                  <p><strong>Modelo:</strong> {vehiculo.nombre_modelo}</p>
                  <p><strong>Placa:</strong> {vehiculo.placa}</p>
                  <p><strong>Precio/día:</strong> ${vehiculo.precio_dia}</p>

                  <div className="mb-3">
                    <label>Fecha Inicio</label>
                    <input type="date" id="fechaInicio" className="form-control" />
                  </div>

                  <div className="mb-3">
                    <label>Fecha Fin</label>
                    <input type="date" id="fechaFin" className="form-control" />
                  </div>

                  <div className="mb-3">
                    <label>Observaciones</label>
                    <textarea id="observaciones" className="form-control"></textarea>
                  </div>

                  <div className="d-flex w-100 gap-2">
                    <button
                        className="btn btn-secondary w-100"
                        onClick={onClose}
                    >
                        Cancelar
                    </button>

                    <button className="btn btn-danger w-100" onClick={reservar}>
                        Confirmar Reserva
                    </button>
                  </div>
                </>
              ) : (
                <>
                  {/* ------------------- LOGIN / REGISTRO ------------------- */}
                  {isLogin ? (
                    <>
                      <div className="mb-3">
                        <label>Email</label>
                        <input type="email" name="email" className="form-control"
                          onChange={(e) => setLoginData({ ...loginData, email: e.target.value })} />
                      </div>

                      <div className="mb-3">
                        <label>Contraseña</label>
                        <input type="password" name="contrasena" className="form-control"
                          onChange={(e) => setLoginData({ ...loginData, contrasena: e.target.value })} />
                      </div>

                      <button className="btn btn-danger w-100" onClick={loginUsuario}>
                        Iniciar Sesión
                      </button>

                      <p className="text-center mt-2">
                        ¿No tienes cuenta?{" "}
                        <span style={{ color: "blue", cursor: "pointer" }} onClick={() => setIsLogin(false)}>
                          Regístrate
                        </span>
                      </p>
                    </>
                  ) : (
                    <>
                      <div className="mb-3">
                        <label>Nombres</label>
                        <input type="text" name="nombres" className="form-control"
                          onChange={(e) => setRegistroData({ ...registroData, nombres: e.target.value })} />
                      </div>

                      <div className="mb-3">
                        <label>Apellidos</label>
                        <input type="text" name="apellidos" className="form-control"
                          onChange={(e) => setRegistroData({ ...registroData, apellidos: e.target.value })} />
                      </div>

                      <div className="mb-3">
                        <label>Email</label>
                        <input type="email" name="email" className="form-control"
                          onChange={(e) => setRegistroData({ ...registroData, email: e.target.value })} />
                      </div>

                      <div className="mb-3">
                        <label>Contraseña</label>
                        <input type="password" name="contrasena" className="form-control"
                          onChange={(e) => setRegistroData({ ...registroData, contrasena: e.target.value })} />
                      </div>

                      <button className="btn btn-danger w-100" onClick={registrarUsuario}>
                        Registrarse
                    </button>


                      <p className="text-center mt-2">
                        ¿Ya tienes cuenta?{" "}
                        <span style={{ color: "blue", cursor: "pointer" }} onClick={() => setIsLogin(true)}>
                          Iniciar sesión
                        </span>
                      </p>
                    </>
                  )}
                </>
              )}

            </div>
          </div>
        </div>
      </div>
    </>
  );
}
