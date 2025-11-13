import { useState, useEffect } from "react";
import VehiculoModal from "../components/modals/VehiculoModal";
import AlertModal from "../components/modals/AlertModal";

const API_URL = "http://localhost/proyectos/car-project/api/vehiculos.php";

interface Vehiculo {
  placa: string;
  color: string;
  año: number;
  precio_dia: string | number;
  estado: string;
  kilometraje: number | string;
  id_modelo: string;
  id_seguro: string;
  nombre_modelo?: string;
  nombre_marca?: string;
}

interface Errores {
  [key: string]: string;
}

interface Modelo {
  id_modelo: string;
  nombre_modelo: string;
  nombre_marca: string;
}

interface Seguro {
  id_seguro: string;
  nombre_compania: string;
}

const ViewVehiculos: React.FC = () => {
  const [vehiculos, setVehiculos] = useState<Vehiculo[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [paginaActual, setPaginaActual] = useState(1);
  const vehiculosPorPagina = 5;

  const [modalAbierto, setModalAbierto] = useState(false);
  const [modoEdicion, setModoEdicion] = useState(false);
  const [errores, setErrores] = useState<Errores>({});
  const [vehiculoActual, setVehiculoActual] = useState<Vehiculo>({
    placa: "",
    color: "",
    año: new Date().getFullYear(),
    precio_dia: "",
    estado: "Disponible",
    kilometraje: 0,
    id_modelo: "",
    id_seguro: "",
  });
  const [modelos, setModelos] = useState<Modelo[]>([]);
  const [seguros, setSeguros] = useState<Seguro[]>([]);

  const [, setAlerta] = useState({
    abierto: false,
    mensaje: "",
    titulo: "",
    tipo: "info",
  });

  const mostrarAlerta = (
    mensaje: string,
    tipo: "success" | "error" | "warning" | "info" = "info",
    titulo = "Aviso"
  ) => {
    setAlerta({ abierto: true, mensaje, tipo, titulo });
  };

  const estados = ["Disponible", "Alquilado", "Mantenimiento", "Fuera de servicio"];

  useEffect(() => { cargarVehiculos(); }, []);

  const cargarVehiculos = async () => {
    try {
      setLoading(true);
      const data = await (await fetch(API_URL)).json();
      if (Array.isArray(data)) setVehiculos(data);
    } catch { mostrarAlerta("Error al cargar vehículos", "error"); }
    finally { setLoading(false); }
  };

  const abrirModal = (vehiculo: Vehiculo | null = null) => {
    setErrores({});
    setModoEdicion(!!vehiculo);
    setVehiculoActual(
      vehiculo || {
        placa: "",
        color: "",
        año: new Date().getFullYear(),
        precio_dia: "",
        estado: "Disponible",
        kilometraje: 0,
        id_modelo: "",
        id_seguro: "",
      }
    );
    setModalAbierto(true);
  };

  const cerrarModal = () => setModalAbierto(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setVehiculoActual({ ...vehiculoActual, [e.target.name]: e.target.value });

  const cargarModelos = async () => {
    try {
      const data = await (await fetch("http://localhost/proyectos/car-project/api/modelos.php")).json();
      if (Array.isArray(data)) setModelos(data);
    } catch { mostrarAlerta("No se pudieron cargar los modelos", "error"); }
  };

  const cargarSeguros = async () => {
    try {
      const data = await (await fetch("http://localhost/proyectos/car-project/api/seguros.php")).json();
      if (Array.isArray(data)) setSeguros(data);
    } catch { mostrarAlerta("No se pudieron cargar los seguros", "error"); }
  };

  useEffect(() => {
    if (modalAbierto) {
      cargarModelos();
      cargarSeguros();
    }
  }, [modalAbierto]);

  const validarCampos = async () => {
    const nuevosErrores: Errores = {};
    const placaRegex = /^[A-Z]{3}\d{3}$/;

    if (!vehiculoActual.placa) nuevosErrores.placa = "La placa es obligatoria";
    else if (!placaRegex.test(vehiculoActual.placa.toUpperCase()))
      nuevosErrores.placa = "Formato inválido (Ej: ABC123)";

    if (!vehiculoActual.color) nuevosErrores.color = "El color es obligatorio";
    if (!vehiculoActual.id_modelo) nuevosErrores.id_modelo = "El modelo es obligatorio";
    if (!vehiculoActual.id_seguro) nuevosErrores.id_seguro = "El seguro es obligatorio";
    if (!vehiculoActual.precio_dia || Number(vehiculoActual.precio_dia) <= 0)
      nuevosErrores.precio_dia = "El precio por día debe ser mayor que 0";
    if (vehiculoActual.año < 1900 || vehiculoActual.año > 2030)
      nuevosErrores.año = "Año fuera de rango válido";
    if (!modoEdicion && vehiculos.some(v => v.placa === vehiculoActual.placa))
      nuevosErrores.placa = "La placa ya existe";

    setErrores(nuevosErrores);
    return Object.keys(nuevosErrores).length === 0;
  };

  const guardarVehiculo = async () => {
    if (!(await validarCampos())) return;

    try {
      const url = modoEdicion
        ? `${API_URL}?actualizar=${vehiculoActual.placa}`
        : `${API_URL}?insertar`;

      const data = await (
        await fetch(url, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            ...vehiculoActual,
            año: parseInt(String(vehiculoActual.año)),
            precio_dia: parseFloat(String(vehiculoActual.precio_dia)),
            kilometraje: parseInt(String(vehiculoActual.kilometraje)) || 0,
          }),
        })
      ).json();

      if (data.success === 1) {
        mostrarAlerta(modoEdicion ? "Vehículo actualizado correctamente" : "Vehículo creado correctamente", "success");
        cerrarModal();
        cargarVehiculos();
      } else mostrarAlerta(data.message || "Error al guardar", "error");
    } catch {
      mostrarAlerta("Error al guardar vehículo", "error");
    }
  };

  const [modalEliminar, setModalEliminar] = useState({ abierto: false, placa: "" });

  const abrirEliminarModal = (placa: string) => setModalEliminar({ abierto: true, placa });
  const cerrarEliminarModal = () => setModalEliminar({ abierto: false, placa: "" });

  const confirmarEliminar = async () => {
    try {
      const data = await (await fetch(`${API_URL}?borrar=${modalEliminar.placa}`)).json();
      if (data.success === 1) {
        mostrarAlerta("Vehículo eliminado correctamente", "success");
        cargarVehiculos();
      } else {
        mostrarAlerta(data.message || "Error al eliminar", "error");
      }
    } catch {
      mostrarAlerta("Error al eliminar vehículo", "error");
    } finally {
      cerrarEliminarModal();
    }
  };

  const getBadgeColor = (estado: string) =>
    ({
      Disponible: "bg-success text-white",
      Alquilado: "bg-warning text-dark",
      Mantenimiento: "bg-primary text-white",
      "Fuera de servicio": "bg-danger text-white",
    }[estado] || "bg-secondary text-white");

  const vehiculosFiltrados = vehiculos.filter(
    (v) =>
      v.placa?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      v.color?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      v.nombre_modelo?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const indexUltimoVehiculo = paginaActual * vehiculosPorPagina;
  const indexPrimerVehiculo = indexUltimoVehiculo - vehiculosPorPagina;
  const vehiculosPaginados = vehiculosFiltrados.slice(indexPrimerVehiculo, indexUltimoVehiculo);
  const totalPaginas = Math.ceil(vehiculosFiltrados.length / vehiculosPorPagina);

  return (
    <div className="container py-4" style={{ marginTop: "80px" }}>
      <div className="card mb-4 shadow-sm">
        <div className="card-body d-flex justify-content-between align-items-center">
          <div className="d-flex align-items-center gap-3">
            <div className="bg-danger text-white p-3 rounded">
              <i className="bi bi-car-front-fill"></i>
            </div>
            <div>
              <h1 className="h3 mb-0">Gestión de Vehículos</h1>
              <p className="text-muted mb-0">Administración de flota - Sistema de alquiler</p>
            </div>
          </div>
          <button className="btn btn-danger d-flex align-items-center gap-2" onClick={() => abrirModal()}>
            <i className="bi bi-plus-lg"></i> Nuevo Vehículo
          </button>
        </div>
        <div className="card-body pt-0 mt-2">
          <div className="input-group">
            <span className="input-group-text">
              <i className="bi bi-search"></i>
            </span>
            <input
              type="text"
              className="form-control"
              placeholder="Buscar por placa, color o modelo..."
              value={searchTerm}
              onChange={(e) => {
                setSearchTerm(e.target.value);
                setPaginaActual(1);
              }}
            />
          </div>
        </div>
      </div>

      <div className="card shadow-sm">
        {loading ? (
          <div className="p-5 text-center">
            <div className="spinner-border text-primary"></div>
            <p className="mt-3 text-muted">Cargando vehículos...</p>
          </div>
        ) : (
          <div className="table-responsive">
            <table className="table table-hover align-middle mb-0">
              <thead className="table-danger">
                <tr>
                  <th>Placa</th>
                  <th>Modelo/Marca</th>
                  <th>Color</th>
                  <th>Año</th>
                  <th>Precio/Día</th>
                  <th>Kilometraje</th>
                  <th>Estado</th>
                  <th className="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                {vehiculosPaginados.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="text-center text-muted py-4">
                      No se encontraron vehículos
                    </td>
                  </tr>
                ) : (
                  vehiculosPaginados.map((v) => (
                    <tr key={v.placa}>
                      <td className="fw-bold text-primary">{v.placa}</td>
                      <td>
                        <div>{v.nombre_modelo}</div>
                        <small className="text-muted">{v.nombre_marca}</small>
                      </td>
                      <td>{v.color}</td>
                      <td>{v.año}</td>
                      <td className="text-success fw-semibold">
                        ${parseFloat(String(v.precio_dia)).toLocaleString("es-CO")}
                      </td>
                      <td>{parseInt(String(v.kilometraje)).toLocaleString("es-CO")} km</td>
                      <td>
                        <span className={`badge ${getBadgeColor(v.estado)}`}>{v.estado}</span>
                      </td>
                      <td className="text-center">
                        <button className="btn btn-outline-primary btn-sm me-1" onClick={() => abrirModal(v)}>
                          <i className="bi bi-pencil-square"></i>
                        </button>
                        <button className="btn btn-outline-danger btn-sm" onClick={() => abrirEliminarModal(v.placa)}>
                          <i className="bi bi-trash"></i>
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>

            {totalPaginas > 1 && (
              <nav aria-label="Paginación de vehículos">
                <ul className="pagination justify-content-center mt-3">
                  <li className={`page-item ${paginaActual === 1 ? "disabled" : ""}`}>
                    <button className="page-link" onClick={() => setPaginaActual(paginaActual - 1)}>
                      Anterior
                    </button>
                  </li>
                  {[...Array(totalPaginas)].map((_, i) => (
                    <li key={i} className={`page-item ${paginaActual === i + 1 ? "active" : ""}`}>
                      <button className="page-link" onClick={() => setPaginaActual(i + 1)}>
                        {i + 1}
                      </button>
                    </li>
                  ))}
                  <li className={`page-item ${paginaActual === totalPaginas ? "disabled" : ""}`}>
                    <button className="page-link" onClick={() => setPaginaActual(paginaActual + 1)}>
                      Siguiente
                    </button>
                  </li>
                </ul>
              </nav>
            )}
          </div>
        )}
      </div>

      <VehiculoModal
        modalAbierto={modalAbierto}
        cerrarModal={cerrarModal}
        modoEdicion={modoEdicion}
        vehiculoActual={vehiculoActual}
        handleInputChange={handleInputChange}
        guardarVehiculo={guardarVehiculo}
        errores={errores}
        modelos={modelos}
        seguros={seguros}
        estados={estados}
      />

      <AlertModal
        abierto={modalEliminar.abierto}
        cerrar={cerrarEliminarModal}
        mensaje={`¿Eliminar el vehículo con placa ${modalEliminar.placa}?`}
        titulo="Confirmar Eliminación"
        tipo="warning"
        confirmar={confirmarEliminar}
      />
    </div>
  );
};

export default ViewVehiculos;
