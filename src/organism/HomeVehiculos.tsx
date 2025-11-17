import { useEffect, useState } from "react";
import "../styles/styles.css";
import LoginRegister from "../components/modals/LoginRegister";

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

  // Para abrir Login o Reserva dentro de LoginRegister
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [modoReserva, setModoReserva] = useState(false);

  const [usuario, setUsuario] = useState<Usuario | null>(null);

  // NUEVO: para almacenar vehículos ya reservados
  const [vehiculosReservados, setVehiculosReservados] = useState<string[]>([]);

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

  useEffect(() => {
    const stored = localStorage.getItem("usuario");
    if (stored) setUsuario(JSON.parse(stored));
  }, []);

  const abrirModalReserva = (vehiculo: Vehiculo) => {
    if (!usuario) { 
      setModoReserva(false);
      setShowAuthModal(true);
      return;
    }

    setVehiculoSeleccionado(vehiculo);
    setModoReserva(true);
    setShowAuthModal(true);
  };

  // NUEVO: callback para marcar vehículo como reservado
  const marcarVehiculoReservado = (placa: string) => {
    setVehiculosReservados((prev) => [...prev, placa]);
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
                  style={{ height: "200px", objectFit: "cover", borderRadius: "0" }}
                />
              ) : (
                <div className="sin-img">Sin imagen</div>
              )}

              <div className="card-body text-center">
                <h5 className="fw-bold">{v.nombre_modelo}</h5>
                <p className="text-muted mb-2">{v.descripcion}</p>

                <ul className="list-unstyled text-start" style={{ fontSize: "0.85rem" }}>
                  <li><strong>Placa:</strong> {v.placa}</li>
                  <li><strong>Estado:</strong> {v.estado}</li>
                  <li><strong>Color:</strong> {v.color}</li>
                  <li><strong>Año:</strong> {v.año}</li>
                  <li><strong>Kilometraje:</strong> {v.kilometraje} km</li>
                  <li><strong>Precio/día:</strong> <span className="fw-bold text-danger">${v.precio_dia}</span></li>
                </ul>
              </div>

              <div className="card-footer bg-white border-0 p-2">
                <button
                  className={`btn w-100 fw-bold ${vehiculosReservados.includes(v.placa) ? 'btn-secondary' : 'btn-danger'}`}
                  onClick={() => !vehiculosReservados.includes(v.placa) && abrirModalReserva(v)}
                  disabled={vehiculosReservados.includes(v.placa)}
                >
                  {vehiculosReservados.includes(v.placa) ? 'Reservado' : 'Reservar'}
                </button>
              </div>

            </div>
          </div>
        ))}
      </div>

      {showAuthModal && (
        <LoginRegister
          onClose={() => setShowAuthModal(false)}
          modoReserva={modoReserva}
          vehiculo={vehiculoSeleccionado}
          onReservaExitosa={marcarVehiculoReservado} // PASAMOS EL CALLBACK
        />
      )}
    </section>
  );
};

export default HomeVehiculos;
