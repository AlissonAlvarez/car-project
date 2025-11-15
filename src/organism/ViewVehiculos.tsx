import { useEffect, useState } from "react";
import VehiculoModal from "../components/modals/VehiculoModal";

const API = "http://localhost/proyectos/car-project/api/vehiculos.php";

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
  comision_afiliado?: number;
  nombre_modelo?: string;
  nombre_compania?: string;
}

const ViewVehiculos = () => {
  const [vehiculos, setVehiculos] = useState<Vehiculo[]>([]);
  const [modalAbierto, setModalAbierto] = useState(false);
  const [vehiculoEditar, setVehiculoEditar] = useState<Vehiculo | null>(null);
  const [errorPlaca, setErrorPlaca] = useState<string>("");

  // Paginación
  const [paginaActual, setPaginaActual] = useState(1);
  const ITEMS_POR_PAGINA = 9;
  const totalPaginas = Math.ceil(vehiculos.length / ITEMS_POR_PAGINA);
  const vehiculosPagina = vehiculos.slice(
    (paginaActual - 1) * ITEMS_POR_PAGINA,
    paginaActual * ITEMS_POR_PAGINA
  );

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

  // Agregar o actualizar vehículo (ahora con FormData)
  const guardarVehiculo = async (formData: FormData) => {
  try {
    const placa = formData.get("placa") as string;
    if (vehiculoEditar) {
      // Indicamos que es actualización
      formData.append("accion", "actualizar");

      const res = await fetch(API, {
        method: "POST", // <-- usar POST en vez de PUT
        body: formData,
      });
      const data = await res.json();
      if (data.error) {
        alert("Error al actualizar vehículo: " + data.error);
        return;
      }
    } else {
      const placaExistente = vehiculos.some(v => v.placa === placa);
      if (placaExistente) {
        setErrorPlaca("Placa ya registrada");
        return;
      }
      const res = await fetch(API, {
        method: "POST",
        body: formData,
      });
      const data = await res.json();
      if (data.error) {
        alert("Error al agregar vehículo: " + data.error);
        return;
      }
    }

    setModalAbierto(false);
    setVehiculoEditar(null);
    setPaginaActual(1);
    setErrorPlaca("");
    obtenerVehiculos();
  } catch (err) {
    console.error(err);
    alert("Error al guardar vehículo");
  }
};

  const eliminarVehiculo = async (placa: string) => {
    if (!window.confirm("¿Seguro que quieres eliminar este vehículo?")) return;

    try {
      const res = await fetch(`${API}?placa=${placa}`, { method: "DELETE" });
      const data = await res.json();
      if (data.error) {
        alert("Error: " + data.error);
        return;
      }
      if ((vehiculosPagina.length === 1) && paginaActual > 1) {
        setPaginaActual(paginaActual - 1);
      }
      obtenerVehiculos();
    } catch (err) {
      console.error(err);
      alert("Error al eliminar vehículo");
    }
  };

  return (
    <div className="container py-4" style={{ marginTop: "60px" }}>
      <h2>Vehículos Registrados</h2>

      <button
        className="btn btn-danger mb-3"
        onClick={() => {
          setVehiculoEditar(null);
          setErrorPlaca("");
          setModalAbierto(true);
        }}
      >
        Nuevo Vehículo
      </button>

      <table className="table table-hover align-middle shadow-sm">
        <thead>
          <tr>
            <th>Imagen</th>
            <th>Placa</th>
            <th>Estado</th>
            <th>Color</th>
            <th>Año</th>
            <th>Precio Día</th>
            <th>Kilometraje</th>
            <th>Modelo</th>
            <th>Seguro</th>
            <th>Comisión</th>
            <th>Acciones</th>
          </tr>
        </thead>

        <tbody>
          {vehiculosPagina.map((v) => (
            <tr key={v.placa}>
              <td>
                {v.imagen_principal ? (
                  <img
                    src={v.imagen_principal}
                    alt={v.nombre_modelo}
                    style={{ width: "80px", borderRadius: "6px" }}
                  />
                ) : (
                  <span>No hay imagen</span>
                )}
              </td>
              <td>{v.placa}</td>
              <td>{v.estado}</td>
              <td>{v.color}</td>
              <td>{v.año}</td>
              <td>${v.precio_dia}</td>
              <td>{v.kilometraje}</td>
              <td>{v.nombre_modelo}</td>
              <td>{v.nombre_compania}</td>
              <td>{v.comision_afiliado ?? 0}%</td>
              <td className="d-flex gap-2">
                <button
                  className="btn btn-outline-secondary btn-sm"
                  onClick={() => {
                    setVehiculoEditar(v);
                    setErrorPlaca("");
                    setModalAbierto(true);
                  }}
                  title="Editar"
                >
                  <i className="bi bi-pencil"></i>
                </button>

                <button
                  className="btn btn-outline-danger btn-sm"
                  onClick={() => eliminarVehiculo(v.placa)}
                  title="Eliminar"
                >
                  <i className="bi bi-trash"></i>
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Paginación */}
      <nav>
        <ul className="pagination justify-content-center">
          <li className={`page-item ${paginaActual === 1 ? "disabled" : ""}`}>
            <button className="page-link text-danger" onClick={() => setPaginaActual(paginaActual - 1)}>
              Anterior
            </button>
          </li>

          {Array.from({ length: totalPaginas }, (_, i) => i + 1).map((num) => (
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
            <button className="page-link text-danger" onClick={() => setPaginaActual(paginaActual + 1)}>
              Siguiente
            </button>
          </li>
        </ul>
      </nav>

      {modalAbierto && (
        <VehiculoModal
          abierto={modalAbierto}
          cerrar={() => {
            setModalAbierto(false);
            setVehiculoEditar(null);
            setErrorPlaca("");
          }}
          guardar={guardarVehiculo} // ahora recibe FormData
          vehiculoEditar={vehiculoEditar}
          errorPlaca={errorPlaca}
        />
      )}
    </div>
  );
};

export default ViewVehiculos;
