import React, { useState, useEffect } from "react";
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

interface Vehiculo {
  placa: string;
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
  guardar: (data: Vehiculo) => void;
  vehiculoEditar: Vehiculo | null;
  errorPlaca?: string; // <-- agregado
}

const VehiculoModal: React.FC<Props> = ({ abierto, cerrar, guardar, vehiculoEditar, errorPlaca }) => {
  const [form, setForm] = useState<Vehiculo>({
    placa: "",
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

  useEffect(() => {
    if (vehiculoEditar) {
      setForm({
        ...vehiculoEditar,
        año: Number(vehiculoEditar.año),
        precio_dia: Number(vehiculoEditar.precio_dia),
        kilometraje: Number(vehiculoEditar.kilometraje),
        comision_afiliado: Number(vehiculoEditar.comision_afiliado || 15)
      });
    } else {
      setForm({
        placa: "",
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
                  <div className="col-md-6">
                    <input
                      type="text"
                      className={`form-control ${errorPlaca ? "is-invalid" : ""}`} // <-- agregado
                      name="placa"
                      placeholder="Placa"
                      value={form.placa}
                      onChange={handleChange}
                      disabled={!!vehiculoEditar}
                      required
                    />
                    {errorPlaca && <div className="invalid-feedback">{errorPlaca}</div>} {/* <-- agregado */}
                  </div>

                  <div className="col-md-6">
                    <input type="text" className="form-control" name="color" placeholder="Color" value={form.color} onChange={handleChange} required />
                  </div>
                  <div className="col-md-6">
                    <input type="number" className="form-control" name="año" placeholder="Año" value={form.año} onChange={handleChange} required />
                  </div>
                  <div className="col-md-6">
                    <input type="number" className="form-control" name="precio_dia" placeholder="Precio por día" value={form.precio_dia} onChange={handleChange} required />
                  </div>
                  <div className="col-md-6">
                    <input type="number" className="form-control" name="kilometraje" placeholder="Kilometraje" value={form.kilometraje} onChange={handleChange} required />
                  </div>
                  <div className="col-md-6">
                    <input type="number" className="form-control" name="comision_afiliado" placeholder="Comisión Afiliado %" value={form.comision_afiliado} onChange={handleChange} required />
                  </div>
                  <div className="col-md-6">
                    <select className="form-select" name="id_modelo" value={form.id_modelo} onChange={handleChange} required>
                      <option value="">Seleccione Modelo</option>
                      {modelos.map(m => (
                        <option key={m.id_modelo} value={m.id_modelo}>{m.nombre_modelo}</option>
                      ))}
                    </select>
                  </div>
                  <div className="col-md-6">
                    <select className="form-select" name="id_seguro" value={form.id_seguro} onChange={handleChange} required>
                      <option value="">Seleccione Seguro</option>
                      {seguros.map(s => (
                        <option key={s.id_seguro} value={s.id_seguro}>{s.nombre_compania}</option>
                      ))}
                    </select>
                  </div>
                  <div className="col-12">
                    <textarea className="form-control" name="descripcion" placeholder="Descripción" value={form.descripcion} onChange={handleChange} required></textarea>
                  </div>
                  <div className="col-12">
                    <input type="text" className="form-control" name="imagen_principal" placeholder="URL Imagen" value={form.imagen_principal} onChange={handleChange} required />
                  </div>
                </div>
              </form>
            </div>

            <div className="d-flex gap-2 p-3 w-100">
              <button type="button" className="btn btn-secondary w-100" onClick={cerrar}>Cancelar</button>
              <button type="button" className="btn btn-danger w-100" onClick={() => guardar(form)}>{vehiculoEditar ? "Actualizar" : "Agregar"}</button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default VehiculoModal;
