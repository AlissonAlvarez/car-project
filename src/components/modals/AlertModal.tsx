import React, { useEffect, useState } from "react";
import ReactDOM from "react-dom";
import "../../styles/styles.css"

interface AlertModalProps {
  abierto: boolean;
  cerrar: () => void;
  confirmar?: () => void;
  mensaje: string;
  titulo?: string;
  tipo?: "success" | "error" | "warning" | "info";
}

const AlertModal: React.FC<AlertModalProps> = ({
  abierto,
  cerrar,
  confirmar,
  mensaje,
  titulo = "Confirmación",
  tipo = "warning",
}) => {
  const [show, setShow] = useState(false);
  const [renderModal, setRenderModal] = useState(abierto);

  useEffect(() => {
    if (abierto) {
      setRenderModal(true);
      setTimeout(() => setShow(true), 10);
    } else {
      setShow(false);
      setTimeout(() => setRenderModal(false), 300);
    }
  }, [abierto]);

  if (!renderModal) return null;

  const tipoColor: Record<string, string> = {
    success: "bg-success text-white",
    error: "bg-danger text-white",
    warning: "bg-warning text-dark",
    info: "bg-info text-white",
  };

  return ReactDOM.createPortal(
    <>
      <div
        className={`modal-backdrop fade ${show ? "show" : ""}`}
         style={{ opacity: show ? 0.5 : 0, transition: "opacity 0.3s" }}
      ></div>

      <div className="modal d-block" tabIndex={-1} style={{ pointerEvents: "auto" }}>
        <div
          className={`modal-dialog modal-dialog-centered ${show ? "fade-in" : "fade-out"}`}
          style={{
            transition: "transform 0.3s ease, opacity 0.3s ease",
            opacity: show ? 1 : 0,
          }}
        >
          <div className="modal-content">
            <div className={`modal-header ${tipoColor[tipo]}`}>
              <h5 className="modal-title">{titulo}</h5>
              <button type="button" className="btn-close" onClick={cerrar}></button>
            </div>
            <div className="modal-body">
              <p>{mensaje}</p>
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={cerrar}>
                {confirmar ? "Cancelar" : "Cerrar"}
              </button>
              {confirmar && (
                <button className="btn btn-danger" onClick={confirmar}>
                  Eliminar
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </>,
    document.body
  );
};

export default AlertModal;
