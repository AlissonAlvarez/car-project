import React, { useState, useEffect } from "react";

interface Reserva {
    id_reserva?: number;
    fecha_inicio: string;
    fecha_fin: string;
    observaciones: string;
    placa: string;
    id_usuario: number | string;
    id_sucursal: number | string;
    estado: string;
}

interface Usuario {
    id_usuario: number | string;
    nombres: string;
}

interface Vehiculo {
    placa: string;
}

interface Sucursal {
    id_sucursal: number | string;
    nombre_sucursal: string;
}

interface Props {
    abierto: boolean;
    cerrar: () => void;
    guardar: (data: FormData) => void;
    reservaEditar: Reserva | null;
    usuarioLogueado: { id_usuario: number; rol: string };
}

const ReservaModal: React.FC<Props> = ({ abierto, cerrar, guardar, reservaEditar, usuarioLogueado }) => {
    const [form, setForm] = useState<Reserva>({
        fecha_inicio: "",
        fecha_fin: "",
        observaciones: "",
        placa: "",
        id_usuario: usuarioLogueado.id_usuario, // forzar usuario logueado
        id_sucursal: "",
        estado: "Pendiente",
    });

    const [usuarios, setUsuarios] = useState<Usuario[]>([]);
    const [vehiculos, setVehiculos] = useState<Vehiculo[]>([]);
    const [sucursales, setSucursales] = useState<Sucursal[]>([]);

    useEffect(() => {
        if (reservaEditar) setForm(reservaEditar);
        else setForm({
            fecha_inicio: "",
            fecha_fin: "",
            observaciones: "",
            placa: "",
            id_usuario: usuarioLogueado.id_usuario, // forzar usuario logueado
            id_sucursal: "",
            estado: "Pendiente",
        });
    }, [reservaEditar, usuarioLogueado]);

    useEffect(() => {
        fetch("http://localhost/proyectos/car-project/api/usuarios.php")
            .then(res => res.json())
            .then((data: Usuario[]) => setUsuarios(data));
        fetch("http://localhost/proyectos/car-project/api/vehiculos.php")
            .then(res => res.json())
            .then((data: Vehiculo[]) => setVehiculos(data));
        fetch("http://localhost/proyectos/car-project/api/sucursal.php")
            .then(res => res.json())
            .then((data: Sucursal[]) => setSucursales(data));
    }, []);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;

        // Si es cliente, no dejar cambiar el id_usuario
        if (name === "id_usuario" && usuarioLogueado.rol !== "Administrador") return;

        setForm({ ...form, [name]: value });
    };

    const handleGuardar = () => {
        const hoy = new Date();
        hoy.setHours(0, 0, 0, 0);
        const fechaSeleccionada = new Date(form.fecha_inicio);

        if (fechaSeleccionada < hoy) {
            alert("Escoge una fecha presente o futura.");
            return;
        }

        const formData = new FormData();

        if (form.id_reserva) {
            formData.append("accion", "actualizar");
            formData.append("id_reserva", String(form.id_reserva));
        }

        formData.append("fecha_inicio", form.fecha_inicio);
        formData.append("fecha_fin", form.fecha_fin);
        formData.append("observaciones", form.observaciones);
        formData.append("placa", form.placa);
        formData.append("id_usuario", String(form.id_usuario));
        formData.append("id_sucursal", String(form.id_sucursal));

        // Solo admin puede cambiar el estado
        formData.append("estado", usuarioLogueado.rol === "Administrador" ? form.estado : "Pendiente");

        guardar(formData);
    };

    if (!abierto) return null;

    return (
        <>
            <div className="modal-backdrop fade show"></div>
            <div className="modal fade show d-block">
                <div className="modal-dialog modal-lg modal-dialog-centered">
                    <div className="modal-content">
                        <div className="modal-header">
                            <h5 className="modal-title">
                                {reservaEditar ? "Editar Reserva" : "Agregar Reserva"}
                            </h5>
                            <button className="btn-close" onClick={cerrar}></button>
                        </div>

                        <div className="modal-body">
                            <div className="row g-3">

                                <div className="col-md-6">
                                    <label>Fecha Inicio</label>
                                    <input type="date" className="form-control" name="fecha_inicio" value={form.fecha_inicio} onChange={handleChange}/>
                                </div>

                                <div className="col-md-6">
                                    <label>Fecha Fin</label>
                                    <input type="date" className="form-control" name="fecha_fin" value={form.fecha_fin} onChange={handleChange}/>
                                </div>

                                <div className="col-md-6">
                                    <label>Vehículo (placa)</label>
                                    <select className="form-select" name="placa" value={form.placa} onChange={handleChange}>
                                        <option value="">Seleccione</option>
                                        {vehiculos.map(v => <option key={v.placa} value={v.placa}>{v.placa}</option>)}
                                    </select>
                                </div>

                                <div className="col-md-6">
                                    <label>Usuario</label>
                                    <select 
                                        className="form-select" 
                                        name="id_usuario" 
                                        value={form.id_usuario} 
                                        onChange={handleChange}
                                        disabled={usuarioLogueado.rol !== "Administrador"} // <-- clientes no pueden cambiar
                                    >
                                        <option value="">Seleccione</option>
                                        {usuarios.map(u => <option key={u.id_usuario} value={u.id_usuario}>{u.nombres}</option>)}
                                    </select>
                                </div>

                                <div className="col-md-6">
                                    <label>Sucursal</label>
                                    <select className="form-select" name="id_sucursal" value={form.id_sucursal} onChange={handleChange}>
                                        <option value="">Seleccione</option>
                                        {sucursales.map(s => <option key={s.id_sucursal} value={s.id_sucursal}>{s.nombre_sucursal}</option>)}
                                    </select>
                                </div>

                                <div className="col-md-6">
                                    <label>Estado</label>
                                    <select 
                                        className="form-select" 
                                        name="estado" 
                                        value={form.estado} 
                                        onChange={handleChange}
                                        disabled={usuarioLogueado.rol !== "Administrador"} // clientes no pueden cambiar
                                    >
                                        <option value="Pendiente">Pendiente</option>
                                        <option value="Confirmada">Confirmada</option>
                                        <option value="Cancelada">Cancelada</option>
                                    </select>
                                </div>

                                <div className="col-12">
                                    <label>Observaciones</label>
                                    <textarea className="form-control" name="observaciones" value={form.observaciones} onChange={handleChange}></textarea>
                                </div>

                            </div>
                        </div>

                        <div className="p-3 d-flex gap-2">
                            <button className="btn btn-secondary w-100" onClick={cerrar}>Cancelar</button>
                            <button className="btn btn-danger w-100" onClick={handleGuardar}>{reservaEditar ? "Actualizar" : "Agregar"}</button>
                        </div>

                    </div>
                </div>
            </div>
        </>
    );
};

export default ReservaModal;
