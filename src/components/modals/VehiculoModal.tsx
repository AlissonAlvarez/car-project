import React, { useEffect, useState } from "react";
import ReactDOM from "react-dom";
// import "../../styles/styles.css"

interface VehiculoModalProps {
  modalAbierto: boolean;
  cerrarModal: () => void;
  modoEdicion: boolean;
  vehiculoActual: {
    placa: string;
    color: string;
    año: number;
    precio_dia: string | number;
    estado: string;
    kilometraje: number | string;
    id_modelo: string;
    id_seguro: string;
  };
  handleInputChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => void;
  guardarVehiculo: () => void;
  errores: { [key: string]: string };
  modelos: Array<{ id_modelo: string; nombre_modelo: string; nombre_marca: string }>;
  seguros: Array<{ id_seguro: string; nombre_compania: string }>;
  estados: string[];
}

const VehiculoModal: React.FC<VehiculoModalProps> = ({
  modalAbierto,
  cerrarModal,
  modoEdicion,
  vehiculoActual,
  handleInputChange,
  guardarVehiculo,
  errores,
  modelos,
  seguros,
  estados,
}) => {
  const [show, setShow] = useState(false);
  const [renderModal, setRenderModal] = useState(modalAbierto);

  useEffect(() => {
    if (modalAbierto) {
      setRenderModal(true);
      setTimeout(() => setShow(true), 10);
    } else {
      setShow(false);
      setTimeout(() => setRenderModal(false), 300);
    }
  }, [modalAbierto]);

  if (!renderModal) return null;

  return ReactDOM.createPortal(
    <>
      <div
        className={`modal-backdrop fade ${show ? "show" : ""}`}
        onClick={cerrarModal}
        style={{ opacity: show ? 0.5 : 0, transition: "opacity 0.3s" }}
      ></div>

      <div className="modal d-block" tabIndex={-1} style={{ pointerEvents: "auto" }}>
        <div
          className={`modal-dialog modal-lg modal-dialog-scrollable ${show ? "fade-in" : "fade-out"}`}
          style={{ transition: "transform 0.3s ease, opacity 0.3s ease" }}
        >
          <div className="modal-content">
            <div className="modal-header bg-danger text-white">
              <h5 className="modal-title">{modoEdicion ? "Editar Vehículo" : "Nuevo Vehículo"}</h5>
              <button type="button" className="btn-close btn-close-white" onClick={cerrarModal}></button>
            </div>
            <div className="modal-body">
              <form>
                <div className="mb-3">
                  <label className="form-label">Placa *</label>
                  <input
                    name="placa"
                    placeholder="Ej: ABC123"
                    value={vehiculoActual.placa}
                    onChange={handleInputChange}
                    disabled={modoEdicion}
                    className={`form-control ${errores.placa ? "is-invalid" : ""}`}
                  />
                  {errores.placa && <div className="invalid-feedback">{errores.placa}</div>}
                </div>

                <div className="row">
                  <div className="col mb-3">
                    <label className="form-label">Color *</label>
                    <input
                      name="color"
                      placeholder="Ej: Rojo"
                      value={vehiculoActual.color}
                      onChange={handleInputChange}
                      className={`form-control ${errores.color ? "is-invalid" : ""}`}
                    />
                    {errores.color && <div className="invalid-feedback">{errores.color}</div>}
                  </div>
                  <div className="col mb-3">
                    <label className="form-label">Año *</label>
                    <input
                      type="number"
                      name="año"
                      value={vehiculoActual.año}
                      onChange={handleInputChange}
                      className={`form-control ${errores.año ? "is-invalid" : ""}`}
                    />
                    {errores.año && <div className="invalid-feedback">{errores.año}</div>}
                  </div>
                </div>

                <div className="row">
                  <div className="col mb-3">
                    <label className="form-label">Precio por día *</label>
                    <input
                      type="number"
                      name="precio_dia"
                      value={vehiculoActual.precio_dia}
                      onChange={handleInputChange}
                      className={`form-control ${errores.precio_dia ? "is-invalid" : ""}`}
                    />
                    {errores.precio_dia && <div className="invalid-feedback">{errores.precio_dia}</div>}
                  </div>
                  <div className="col mb-3">
                    <label className="form-label">Kilometraje</label>
                    <input
                      type="number"
                      name="kilometraje"
                      value={vehiculoActual.kilometraje}
                      onChange={handleInputChange}
                      className="form-control"
                    />
                  </div>
                </div>

                <div className="mb-3">
                  <label className="form-label">Estado *</label>
                  <select
                    name="estado"
                    value={vehiculoActual.estado}
                    onChange={handleInputChange}
                    className="form-select"
                  >
                    {estados.map((est) => (
                      <option key={est}>{est}</option>
                    ))}
                  </select>
                </div>

                <div className="row">
                  <div className="col mb-3">
                    <label className="form-label">Modelo *</label>
                    <select
                      name="id_modelo"
                      value={vehiculoActual.id_modelo}
                      onChange={handleInputChange}
                      className={`form-select ${errores.id_modelo ? "is-invalid" : ""}`}
                    >
                      <option value="">Seleccione un modelo...</option>
                      {modelos.map((m) => (
                        <option key={m.id_modelo} value={m.id_modelo}>
                          {m.nombre_modelo} — {m.nombre_marca}
                        </option>
                      ))}
                    </select>
                    {errores.id_modelo && <div className="invalid-feedback">{errores.id_modelo}</div>}
                  </div>
                  <div className="col mb-3">
                    <label className="form-label">Seguro *</label>
                    <select
                      name="id_seguro"
                      value={vehiculoActual.id_seguro}
                      onChange={handleInputChange}
                      className={`form-select ${errores.id_seguro ? "is-invalid" : ""}`}
                    >
                      <option value="">Seleccione un seguro...</option>
                      {seguros.map((s) => (
                        <option key={s.id_seguro} value={s.id_seguro}>
                          {s.nombre_compania}
                        </option>
                      ))}
                    </select>
                    {errores.id_seguro && <div className="invalid-feedback">{errores.id_seguro}</div>}
                  </div>
                </div>
              </form>
            </div>

            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={cerrarModal}>
                Cancelar
              </button>
              <button className="btn btn-danger" onClick={guardarVehiculo}>
                Guardar
              </button>
            </div>
          </div>
        </div>
      </div>
    </>,
    document.body
  );
};

export default VehiculoModal;
