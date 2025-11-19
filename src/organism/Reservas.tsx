import { useEffect, useState } from "react";
import ReservaModal from "../components/modals/ReservasModal";

const API = "http://localhost/proyectos/car-project/api/reservas.php";

interface Reserva {
  id_reserva: number;
  fecha_inicio: string;
  fecha_fin: string;
  observaciones: string;
  placa: string;
  id_usuario: number;
  id_sucursal: number;
  estado: string;
  nombre_usuario?: string;
  precio_dia?: number;
  nombre_sucursal?: string;
}

interface Usuario {
  id_usuario: number;
  rol: string;
}

const ViewReservas = () => {
  const [reservas, setReservas] = useState<Reserva[]>([]);
  const [modalAbierta, setModalAbierta] = useState(false);
  const [reservaEditar, setReservaEditar] = useState<Reserva | null>(null);

  const [paginaActual, setPaginaActual] = useState(1);
  const ITEMS_POR_PAGINA = 10;
  const totalPaginas = Math.ceil(reservas.length / ITEMS_POR_PAGINA);
  const reservasPagina = reservas.slice(
    (paginaActual - 1) * ITEMS_POR_PAGINA,
    paginaActual * ITEMS_POR_PAGINA
  );

  // --- NUEVO: usuario logeado ---  
const [usuarioActual, setUsuarioActual] = useState<Usuario | null>(null);

  const obtenerReservas = async () => {
    try {
      const res = await fetch(API);
      const data = await res.json();
      setReservas(data);
    } catch (err) {
      console.error(err);
      alert("Error al cargar reservas");
    }
  };

  useEffect(() => {
    // Cargar reservas
    obtenerReservas();

    // Cargar usuario logeado
    const stored = localStorage.getItem("usuario");
    if (stored) setUsuarioActual(JSON.parse(stored));
  }, []);

  const guardarReserva = async (formData: FormData) => {
    try {
      const res = await fetch(API, {
        method: "POST",
        body: formData,
      });

      const text = await res.text();
      let data;
      try {
        data = JSON.parse(text);
      } catch {
        console.error("Respuesta inválida de la API:", text);
        alert("Error: La API devolvió un valor inválido");
        return;
      }

      if (data.error) {
        alert("Error: " + data.error);
        return;
      }

      setModalAbierta(false);
      setReservaEditar(null);
      setPaginaActual(1);
      obtenerReservas();
    } catch (err) {
      console.error(err);
      alert("Error al guardar reserva");
    }
  };

  const eliminarReserva = async (id_reserva: number) => {
    if (!window.confirm("¿Seguro que quieres eliminar esta reserva?")) return;

    try {
      const res = await fetch(`${API}?id_reserva=${id_reserva}`, { method: "DELETE" });
      const data = await res.json();
      if (data.error) {
        alert("Error: " + data.error);
        return;
      }
      if ((reservasPagina.length === 1) && paginaActual > 1) {
        setPaginaActual(paginaActual - 1);
      }
      obtenerReservas();
    } catch (err) {
      console.error(err);
      alert("Error al eliminar reserva");
    }
  };

  // Función para determinar el color según el estado
  const colorEstado = (estado: string) => {
    switch (estado) {
      case "Confirmada":
        return "bg-success";
      case "Cancelada":
        return "bg-danger";
      case "Pendiente":
        return "bg-warning text-dark";
      default:
        return "bg-primary";
    }
  };

  return (
    <div className="container py-4" style={{ marginTop: "60px" }}>
      <h2 className="mb-3">Reservas Registradas</h2>

      <button
        className="btn btn-danger mb-3"
        onClick={() => {
          setReservaEditar(null);
          setModalAbierta(true);
        }}
      >
        Nueva Reserva
      </button>

      <table className="table table-hover align-middle shadow-sm">
        <thead>
          <tr>
            <th>ID</th>
            <th>Placa</th>
            <th>Usuario</th>
            <th>Sucursal</th>
            <th>Fecha Inicio</th>
            <th>Fecha Fin</th>
            <th>Precio/Día</th>
            <th>Estado</th>
            <th>Observaciones</th>
            <th>Acciones</th>
          </tr>
        </thead>

        <tbody>
          {reservasPagina.map((r) => (
            <tr key={r.id_reserva}>
              <td>{r.id_reserva}</td>
              <td>{r.placa}</td>
              <td>{r.nombre_usuario ?? "Sin nombre"}</td>
              <td>{r.nombre_sucursal ?? "No asignada"}</td>
              <td>{r.fecha_inicio}</td>
              <td>{r.fecha_fin}</td>
              <td>${r.precio_dia ?? 0}</td>
              <td>
                <span className={`badge ${colorEstado(r.estado)}`}>
                  {r.estado}
                </span>
              </td>
              <td>{r.observaciones || "—"}</td>

              <td className="d-flex gap-2">
                {/* EDITAR */}
                <button
                  className="btn btn-outline-secondary btn-sm"
                  onClick={() => {
                    setReservaEditar(r);
                    setModalAbierta(true);
                  }}
                  title="Editar"
                >
                  <i className="bi bi-pencil"></i>
                </button>

                {/* ELIMINAR */}
                <button
                  className="btn btn-outline-danger btn-sm"
                  onClick={() => eliminarReserva(r.id_reserva)}
                  title="Eliminar"
                >
                  <i className="bi bi-trash"></i>
                </button>

                {/* CONFIRMAR */}
                <button
                  className="btn btn-success btn-sm"
                  onClick={() => {
                    if (r.estado !== "Confirmada") {
                      const formData = new FormData();
                      formData.append("id_reserva", String(r.id_reserva));
                      formData.append("estado", "Confirmada");
                      formData.append("accion", "actualizar");
                      formData.append("fecha_inicio", r.fecha_inicio);
                      formData.append("fecha_fin", r.fecha_fin);
                      formData.append("id_usuario", String(r.id_usuario));
                      formData.append("placa", r.placa);
                      formData.append("id_sucursal", String(r.id_sucursal));
                      formData.append("observaciones", r.observaciones);

                      guardarReserva(formData);
                    } else {
                      alert("Esta reserva ya está confirmada");
                    }
                  }}
                  title="Confirmar"
                >
                  <i className="bi bi-check-lg"></i>
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* PAGINACIÓN */}
      <nav>
        <ul className="pagination justify-content-center">
          <li className={`page-item ${paginaActual === 1 ? "disabled" : ""}`}>
            <button className="page-link text-danger" onClick={() => setPaginaActual(paginaActual - 1)}>Anterior</button>
          </li>

          {Array.from({ length: totalPaginas }, (_, i) => i + 1).map(num => (
            <li key={num} className="page-item">
              <button
                className={`page-link ${paginaActual === num ? "bg-danger text-white" : "text-danger"}`}
                onClick={() => setPaginaActual(num)}
              >
                {num}
              </button>
            </li>
          ))}

          <li className={`page-item ${paginaActual === totalPaginas ? "disabled" : ""}`}>
            <button className="page-link text-danger" onClick={() => setPaginaActual(paginaActual + 1)}>Siguiente</button>
          </li>
        </ul>
      </nav>

      {/* MODAL */}
      {modalAbierta && usuarioActual && (
        <ReservaModal
            abierto={modalAbierta}
            cerrar={() => { setModalAbierta(false); setReservaEditar(null); }}
            reservaEditar={reservaEditar}
            guardar={guardarReserva}
            usuarioLogueado={usuarioActual} // TS ya sabe que no es null
        />
    )}
    </div>
  );
};

export default ViewReservas;
