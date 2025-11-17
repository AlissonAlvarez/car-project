import React, { useState, useEffect } from "react";
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

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
}

interface Props {
  abierto: boolean;
  cerrar: () => void;
  guardar: (data: FormData) => void;
  vehiculoEditar: Vehiculo | null;
  errorPlaca?: string;
}

const VehiculoModal: React.FC<Props> = ({ abierto, cerrar, guardar, vehiculoEditar, errorPlaca }) => {
  const [form, setForm] = useState<Vehiculo>({
    placa: "",
    estado: "Disponible",
    color: "",
    año: 2024,
    precio_dia: 0,
    kilometraje: 0,
    id_modelo: "",
    id_seguro: "",
    descripcion: "",
    imagen_principal: "",
    comision_afiliado: 15,
  });

  const [modelos, setModelos] = useState<{id_modelo: string, nombre_modelo: string}[]>([]);
  const [seguros, setSeguros] = useState<{id_seguro: string, nombre_compania: string}[]>([]);
  const [archivoImagen, setArchivoImagen] = useState<File | null>(null); // <-- nuevo estado para la imagen

  useEffect(() => {
    if (vehiculoEditar) {
      setForm({
        ...vehiculoEditar,
        año: Number(vehiculoEditar.año),
        precio_dia: Number(vehiculoEditar.precio_dia),
        kilometraje: Number(vehiculoEditar.kilometraje),
        comision_afiliado: Number(vehiculoEditar.comision_afiliado || 15),
        estado: vehiculoEditar.estado || "Disponible",
      });
    } else {
      setForm({
        placa: "",
        estado: "Disponible",
        color: "",
        año: 2024,
        precio_dia: 0,
        kilometraje: 0,
        id_modelo: "",
        id_seguro: "",
        descripcion: "",
        imagen_principal: "",
        comision_afiliado: 15,
      });
      setArchivoImagen(null);
    }
  }, [vehiculoEditar]);

  useEffect(() => {
    fetch("http://localhost/proyectos/car-project/api/modelos.php")
      .then(res => res.json())
      .then(data => setModelos(data));

    fetch("http://localhost/proyectos/car-project/api/seguros.php")
      .then(res => res.json())
      .then(data => setSeguros(data));
  }, []);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;

    setForm({
      ...form,
      [name]: ["precio_dia","kilometraje","año","comision_afiliado"].includes(name)
        ? Number(value)
        : value,
    });
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      setArchivoImagen(e.target.files[0]);
    }
  };

  const handleGuardar = () => {
    const formData = new FormData();
    Object.entries(form).forEach(([key, value]) => {
      // <-- reemplazo de "any" por string
      formData.append(key, value !== undefined && value !== null ? String(value) : "");
    });

    if (archivoImagen) {
      formData.append("imagen_principal", archivoImagen);
    } else if (vehiculoEditar?.imagen_principal) {
      formData.append("imagen_antigua", vehiculoEditar.imagen_principal); // <-- agregado
    }

    if (vehiculoEditar) formData.append("accion", "actualizar"); // <-- agregado
    guardar(formData);
  };

  if (!abierto) return null;

  return (
    <>
      <div className="modal-backdrop fade show"></div>
      <div className="modal fade show d-block" tabIndex={-1} role="dialog">
        <div className="modal-dialog modal-lg modal-dialog-centered">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">{vehiculoEditar ? "Editar Vehículo" : "Agregar Vehículo"}</h5>
              <button type="button" className="btn-close" aria-label="Cerrar" onClick={cerrar}></button>
            </div>

            <div className="modal-body">
              <form>
                <div className="row g-3">

                  {/* Placa */}
                  <div className="col-md-6">
                    <label htmlFor="placa" className="form-label">Placa</label>
                    <input
                      id="placa"
                      type="text"
                      className={`form-control ${errorPlaca ? "is-invalid" : ""}`}
                      name="placa"
                      placeholder="Ingrese la placa"
                      value={form.placa}
                      onChange={handleChange}
                      disabled={!!vehiculoEditar}
                      required
                    />
                    {errorPlaca && <div className="invalid-feedback">{errorPlaca}</div>}
                  </div>

                  {/* Estado */}
                  <div className="col-md-6">
                    <label htmlFor="estado" className="form-label">Estado</label>
                    <select
                      id="estado"
                      className="form-select"
                      name="estado"
                      value={form.estado}
                      onChange={handleChange}
                      required
                    >
                      <option value="Disponible">Disponible</option>
                      <option value="Alquilado">Alquilado</option>
                      <option value="Mantenimiento">Mantenimiento</option>
                      <option value="Fuera de servicio">Fuera de servicio</option>
                    </select>
                  </div>

                  {/* Color */}
                  <div className="col-md-6">
                    <label htmlFor="color" className="form-label">Color</label>
                    <input
                      id="color"
                      type="text"
                      className="form-control"
                      name="color"
                      placeholder="Ingrese el color"
                      value={form.color}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  {/* Año */}
                  <div className="col-md-6">
                    <label htmlFor="año" className="form-label">Año</label>
                    <input
                      id="año"
                      type="number"
                      className="form-control"
                      name="año"
                      placeholder="Ingrese el año"
                      value={form.año}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  {/* Precio Día */}
                  <div className="col-md-6">
                    <label htmlFor="precio_dia" className="form-label">Precio por Día</label>
                    <input
                      id="precio_dia"
                      type="number"
                      className="form-control"
                      name="precio_dia"
                      placeholder="Ingrese el precio por día"
                      value={form.precio_dia}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  {/* Kilometraje */}
                  <div className="col-md-6">
                    <label htmlFor="kilometraje" className="form-label">Kilometraje</label>
                    <input
                      id="kilometraje"
                      type="number"
                      className="form-control"
                      name="kilometraje"
                      placeholder="Ingrese el kilometraje"
                      value={form.kilometraje}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  {/* Comisión Afiliado */}
                  <div className="col-md-6">
                    <label htmlFor="comision_afiliado" className="form-label">Comisión Afiliado (%)</label>
                    <input
                      id="comision_afiliado"
                      type="number"
                      className="form-control"
                      name="comision_afiliado"
                      placeholder="Ingrese comisión"
                      value={form.comision_afiliado}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  {/* Modelo */}
                  <div className="col-md-6">
                    <label htmlFor="id_modelo" className="form-label">Modelo</label>
                    <select
                      id="id_modelo"
                      className="form-select"
                      name="id_modelo"
                      value={form.id_modelo}
                      onChange={handleChange}
                      required
                    >
                      <option value="">Seleccione Modelo</option>
                      {modelos.map(m => (
                        <option key={m.id_modelo} value={m.id_modelo}>{m.nombre_modelo}</option>
                      ))}
                    </select>
                  </div>

                  {/* Seguro */}
                  <div className="col-md-6">
                    <label htmlFor="id_seguro" className="form-label">Seguro</label>
                    <select
                      id="id_seguro"
                      className="form-select"
                      name="id_seguro"
                      value={form.id_seguro}
                      onChange={handleChange}
                      required
                    >
                      <option value="">Seleccione Seguro</option>
                      {seguros.map(s => (
                        <option key={s.id_seguro} value={s.id_seguro}>{s.nombre_compania}</option>
                      ))}
                    </select>
                  </div>

                  {/* Descripción */}
                  <div className="col-12">
                    <label htmlFor="descripcion" className="form-label">Descripción</label>
                    <textarea
                      id="descripcion"
                      className="form-control"
                      name="descripcion"
                      placeholder="Ingrese descripción"
                      value={form.descripcion}
                      onChange={handleChange}
                      required
                    ></textarea>
                  </div>

                  {/* Imagen */}
                  <div className="col-12">
                    <label htmlFor="imagen_principal" className="form-label">Imagen del Vehículo</label>
                    <input
                      id="imagen_principal"
                      type="file"
                      className="form-control"
                      onChange={handleFileChange}
                    />
                  </div>

                </div>
              </form>
            </div>

            <div className="d-flex gap-2 p-3 w-100">
              <button type="button" className="btn btn-secondary w-100" onClick={cerrar}>Cancelar</button>
              <button type="button" className="btn btn-danger w-100" onClick={handleGuardar}>
                {vehiculoEditar ? "Actualizar" : "Agregar"}
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default VehiculoModal;
