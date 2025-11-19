-- ============================================
-- BASE DE DATOS: alquiler_vehiculos
-- VERSIÓN AJUSTADA
-- ============================================
CREATE DATABASE IF NOT EXISTS alquiler_vehiculos;
USE alquiler_vehiculos;

-- ============================================
-- TABLAS INDEPENDIENTES
-- ============================================

-- Tabla: Roles
CREATE TABLE Roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(100)
) AUTO_INCREMENT = 1;

-- Tabla: Marca
CREATE TABLE Marca (
    id_marca VARCHAR(10) PRIMARY KEY,
    nombre_marca VARCHAR(50) NOT NULL,
    pais_origen VARCHAR(50) NULL,
    logo_url VARCHAR(255) NULL
);

-- Tabla: Seguro
CREATE TABLE Seguro (
    id_seguro VARCHAR(10) PRIMARY KEY,
    nombre_compania VARCHAR(50) NOT NULL,
    tipo_cobertura VARCHAR(50),
    costo_diario DECIMAL(10,2),
    telefono_contacto VARCHAR(20),
    descripcion TEXT
);

-- Tabla: Sucursal
CREATE TABLE Sucursal (
    id_sucursal VARCHAR(10) PRIMARY KEY,
    nombre_sucursal VARCHAR(50) NOT NULL,
    direccion VARCHAR(100),
    ciudad VARCHAR(50),
    telefono VARCHAR(20),
    email VARCHAR(80),
    horario VARCHAR(100)
);

-- Tabla: Extras
CREATE TABLE Extras (
    id_extra INT AUTO_INCREMENT PRIMARY KEY,
    nombre_extra VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    precio_dia DECIMAL(10,2),
    disponible BOOLEAN DEFAULT TRUE,
    icono_url VARCHAR(255)
) AUTO_INCREMENT = 1;

-- Tabla: Categorias (antes categorias_contexto)
CREATE TABLE Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion TEXT,
    imagen_banner VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE
) AUTO_INCREMENT = 1;

-- Tabla: Paquetes
CREATE TABLE Paquetes (
    id_paquete INT AUTO_INCREMENT PRIMARY KEY,
    nombre_paquete VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_paquete ENUM('Tiempo','Cliente','Combinado','Temporal') DEFAULT 'Tiempo',
    descuento_porcentaje DECIMAL(5,2),
    precio_fijo DECIMAL(10,2) NULL,
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    activo BOOLEAN DEFAULT TRUE
) AUTO_INCREMENT = 1;

-- ============================================
-- TABLAS CON DEPENDENCIAS
-- ============================================

-- Tabla: Modelo
CREATE TABLE Modelo (
    id_modelo VARCHAR(10) PRIMARY KEY,
    nombre_modelo VARCHAR(50) NOT NULL,
    tipo_vehiculo VARCHAR(30),
    capacidad INT,
    transmision ENUM('Manual','Automática') DEFAULT 'Manual',
    tipo_combustible VARCHAR(20),
    id_marca VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_marca) REFERENCES Marca(id_marca) ON DELETE RESTRICT
);

-- Tabla: Usuarios
CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(100),
    cedula VARCHAR(15) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Activo','Inactivo','Suspendido') DEFAULT 'Activo',
    id_rol INT NOT NULL,
    puntos_acumulados INT DEFAULT 0,
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol) ON DELETE RESTRICT
) AUTO_INCREMENT = 1;

-- Tabla: Empleados
CREATE TABLE Empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    cargo VARCHAR(50),
    salario DECIMAL(10,2),
    fecha_contratacion DATE NOT NULL,
    id_sucursal VARCHAR(10) NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal) ON DELETE SET NULL
) AUTO_INCREMENT = 1;

-- Tabla: Vehiculo
CREATE TABLE Vehiculo (
    placa VARCHAR(10) PRIMARY KEY,
    color VARCHAR(30),
    año YEAR,
    precio_dia DECIMAL(10,2),
    estado ENUM('Disponible','Alquilado','Mantenimiento','Fuera de servicio') DEFAULT 'Disponible',
    kilometraje INT,
    imagen_principal VARCHAR(255),
    descripcion TEXT,
    destacado BOOLEAN DEFAULT FALSE,
    calificacion_promedio DECIMAL(3,2) DEFAULT 0.00,
    numero_reseñas INT DEFAULT 0,
    id_modelo VARCHAR(10) NOT NULL,
    id_seguro VARCHAR(10) NOT NULL,
    es_afiliado BOOLEAN DEFAULT FALSE,
    id_propietario INT NULL,
    comision_afiliado DECIMAL(5,2) DEFAULT 15.00,
    FOREIGN KEY (id_modelo) REFERENCES Modelo(id_modelo) ON DELETE RESTRICT,
    FOREIGN KEY (id_seguro) REFERENCES Seguro(id_seguro) ON DELETE RESTRICT,
    FOREIGN KEY (id_propietario) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
);

-- Tabla: Imagenes_Vehiculo
CREATE TABLE Imagenes_Vehiculo (
    id_imagen INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    url_imagen VARCHAR(255) NOT NULL,
    orden INT DEFAULT 1,
    descripcion VARCHAR(200) NULL,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE
) AUTO_INCREMENT = 1;

-- Tabla: Vehiculo_Categoria
CREATE TABLE Vehiculo_Categoria (
    id_vehiculo_categoria INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    id_categoria INT NOT NULL,
    destacado_en_categoria BOOLEAN DEFAULT FALSE,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria) ON DELETE CASCADE,
    UNIQUE KEY unique_vehiculo_categoria (placa, id_categoria)
) AUTO_INCREMENT = 1;

-- Tabla: Paquete_Extras
CREATE TABLE Paquete_Extras (
    id_paquete_extra INT AUTO_INCREMENT PRIMARY KEY,
    id_paquete INT NOT NULL,
    id_extra INT NOT NULL,
    incluido BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_paquete) REFERENCES Paquetes(id_paquete) ON DELETE CASCADE,
    FOREIGN KEY (id_extra) REFERENCES Extras(id_extra) ON DELETE CASCADE,
    UNIQUE KEY unique_paquete_extra (id_paquete, id_extra)
) AUTO_INCREMENT = 1;

-- Tabla: Mantenimiento
CREATE TABLE Mantenimiento (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    tipo_mantenimiento ENUM('Preventivo','Correctivo','Emergencia') DEFAULT 'Preventivo',
    descripcion TEXT,
    fecha_mantenimiento DATE NOT NULL,
    kilometraje_actual INT,
    costo DECIMAL(10,2),
    proximo_mantenimiento_km INT,
    proximo_mantenimiento_fecha DATE,
    id_empleado INT NULL,
    estado ENUM('Programado','En Proceso','Completado','Cancelado') DEFAULT 'Programado',
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado) ON DELETE SET NULL
) AUTO_INCREMENT = 1;

-- Tabla: Reservas
CREATE TABLE Reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    hora_recogida TIME DEFAULT '09:00:00',
    hora_entrega TIME DEFAULT '09:00:00',
    dias_alquiler INT,
    subtotal DECIMAL(10,2),
    descuento DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(10,2),
    estado ENUM('Pendiente','Confirmada','Activa','Finalizada','Cancelada') DEFAULT 'Pendiente',
    metodo_recogida ENUM('Sucursal','Domicilio') DEFAULT 'Sucursal',
    direccion_entrega VARCHAR(200) NULL,
    observaciones TEXT,
    id_usuario INT NOT NULL,
    placa VARCHAR(10) NOT NULL,
    id_sucursal VARCHAR(10) NOT NULL,
    id_empleado_atiende INT NULL,
    id_paquete INT NULL,
    puntos_usados INT DEFAULT 0,
    puntos_ganados INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE RESTRICT,
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal) ON DELETE RESTRICT,
    FOREIGN KEY (id_empleado_atiende) REFERENCES Empleados(id_empleado) ON DELETE SET NULL,
    FOREIGN KEY (id_paquete) REFERENCES Paquetes(id_paquete) ON DELETE SET NULL
) AUTO_INCREMENT = 1;

-- Tabla: Reserva_Extras
CREATE TABLE Reserva_Extras (
    id_reserva_extra INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_extra INT NOT NULL,
    cantidad INT DEFAULT 1,
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva) ON DELETE CASCADE,
    FOREIGN KEY (id_extra) REFERENCES Extras(id_extra) ON DELETE RESTRICT
) AUTO_INCREMENT = 1;

-- Tabla: Pagos
CREATE TABLE Pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('Efectivo','Tarjeta Crédito','Tarjeta Débito','Transferencia','PayPal','Stripe') NOT NULL,
    estado_pago ENUM('Pendiente','Confirmado','Rechazado','Reembolsado') DEFAULT 'Pendiente',
    referencia_pago VARCHAR(100),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_empleado_procesa INT NULL,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva) ON DELETE RESTRICT,
    FOREIGN KEY (id_empleado_procesa) REFERENCES Empleados(id_empleado) ON DELETE SET NULL
) AUTO_INCREMENT = 1;

-- Tabla: Facturas
CREATE TABLE Facturas (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    numero_factura VARCHAR(20) UNIQUE,
    fecha_emision DATE NOT NULL,
    subtotal DECIMAL(10,2),
    iva DECIMAL(10,2),
    descuentos DECIMAL(10,2) DEFAULT 0.00,
    total_pagar DECIMAL(10,2),
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva) ON DELETE RESTRICT
) AUTO_INCREMENT = 1;

-- Tabla: Reseñas
CREATE TABLE Reseñas (
    id_reseña INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    placa VARCHAR(10) NOT NULL,
    id_reserva INT NOT NULL,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_reseña TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verificado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva) ON DELETE CASCADE,
    UNIQUE KEY unique_usuario_reserva (id_usuario, id_reserva)
) AUTO_INCREMENT = 1;

-- ============================================
-- INSERTS
-- ============================================

-- Tabla: Roles
INSERT INTO Roles (nombre_rol, descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Cliente', 'Usuario final que alquila vehículos'),
('Empleado', 'Personal de la empresa'),
('Propietario Afiliado', 'Dueño de vehículo afiliado al sistema');

-- Tabla: Marca
INSERT INTO Marca (id_marca, nombre_marca, pais_origen, logo_url) VALUES
('MRC001', 'Toyota', 'Japón', 'https://example.com/logos/toyota.png'),
('MRC002', 'Honda', 'Japón', 'https://example.com/logos/honda.png'),
('MRC003', 'Mazda', 'Japón', 'https://example.com/logos/mazda.png'),
('MRC004', 'Chevrolet', 'Estados Unidos', 'https://example.com/logos/chevrolet.png'),
('MRC005', 'Ford', 'Estados Unidos', 'https://example.com/logos/ford.png'),
('MRC006', 'Nissan', 'Japón', 'https://example.com/logos/nissan.png'),
('MRC007', 'Hyundai', 'Corea del Sur', 'https://example.com/logos/hyundai.png'),
('MRC008', 'Kia', 'Corea del Sur', 'https://example.com/logos/kia.png'),
('MRC009', 'Volkswagen', 'Alemania', 'https://example.com/logos/vw.png'),
('MRC010', 'BMW', 'Alemania', 'https://example.com/logos/bmw.png');

-- Tabla: Seguro
INSERT INTO Seguro (id_seguro, nombre_compania, tipo_cobertura, costo_diario, telefono_contacto, descripcion) VALUES
('SEG001', 'Seguros Bolivar', 'Todo Riesgo', 15000.00, '3001234567', 'Cobertura completa contra todo riesgo'),
('SEG002', 'Seguros del Estado', 'Responsabilidad Civil', 8000.00, '3009876543', 'Cobertura básica de responsabilidad civil'),
('SEG003', 'Seguros Sura', 'Todo Riesgo Plus', 20000.00, '3012345678', 'Cobertura premium con asistencia 24/7'),
('SEG004', 'Liberty Seguros', 'Básico', 5000.00, '3015555555', 'Cobertura básica económica'),
('SEG005', 'Allianz', 'Integral', 18000.00, '3017777777', 'Cobertura integral con deducible bajo');

-- Tabla: Sucursal
INSERT INTO Sucursal (id_sucursal, nombre_sucursal, direccion, ciudad, telefono, email, horario) VALUES
('SUC001', 'Sucursal Centro', 'Calle 72 # 10-34', 'Bogotá', '6011234567', 'centro@alquiler.com', 'Lun-Vie: 8:00-18:00, Sáb: 9:00-14:00'),
('SUC002', 'Sucursal Norte', 'Cra 15 # 140-20', 'Bogotá', '6017654321', 'norte@alquiler.com', 'Lun-Vie: 8:00-18:00, Sáb: 9:00-14:00'),
('SUC003', 'Sucursal Aeropuerto El Dorado', 'Terminal Aéreo Int.', 'Bogotá', '6019998877', 'aeropuerto@alquiler.com', 'Lun-Dom: 24 horas'),
('SUC004', 'Sucursal Medellín', 'Calle 50 # 45-23', 'Medellín', '6044445566', 'medellin@alquiler.com', 'Lun-Vie: 8:00-18:00, Sáb: 9:00-14:00'),
('SUC005', 'Sucursal Cali', 'Av 6N # 23-45', 'Cali', '6022223344', 'cali@alquiler.com', 'Lun-Vie: 8:00-18:00, Sáb: 9:00-14:00');

-- Tabla: Extras
INSERT INTO Extras (nombre_extra, descripcion, precio_dia, disponible, icono_url) VALUES
('GPS', 'Sistema de navegación GPS', 5000.00, TRUE, 'https://example.com/icons/gps.png'),
('Silla para bebé', 'Silla de seguridad para niños menores de 4 años', 8000.00, TRUE, 'https://example.com/icons/baby-seat.png'),
('Silla para niño', 'Silla elevada para niños de 4 a 12 años', 7000.00, TRUE, 'https://example.com/icons/child-seat.png'),
('Conductor adicional', 'Permite que otra persona conduzca el vehículo', 15000.00, TRUE, 'https://example.com/icons/driver.png'),
('WiFi portátil', 'Dispositivo móvil con Internet 4G', 10000.00, TRUE, 'https://example.com/icons/wifi.png'),
('Seguro adicional de neumáticos', 'Cobertura contra daños en llantas', 6000.00, TRUE, 'https://example.com/icons/tire.png'),
('Cadenas para nieve', 'Para conducción en zonas nevadas', 12000.00, TRUE, 'https://example.com/icons/chains.png'),
('Porta equipaje', 'Rack para transportar equipaje adicional', 8000.00, TRUE, 'https://example.com/icons/roof-rack.png'),
('Tanque lleno', 'Vehículo entregado con tanque completo', 0.00, TRUE, 'https://example.com/icons/fuel.png'),
('Asistencia en carretera 24/7', 'Servicio de grúa y asistencia mecánica', 5000.00, TRUE, 'https://example.com/icons/roadside.png');

-- Tabla: Categorias
INSERT INTO Categorias (nombre_categoria, descripcion, imagen_banner, activo) VALUES
('Económicos', 'Vehículos compactos y económicos para viajes urbanos', 'https://example.com/banners/economicos.jpg', TRUE),
('SUV', 'Vehículos deportivos utilitarios para toda la familia', 'https://example.com/banners/suv.jpg', TRUE),
('Lujo', 'Vehículos de alta gama para una experiencia premium', 'https://example.com/banners/lujo.jpg', TRUE),
('Familiares', 'Vans y vehículos espaciosos para grupos grandes', 'https://example.com/banners/familiares.jpg', TRUE),
('Deportivos', 'Vehículos de alto rendimiento', 'https://example.com/banners/deportivos.jpg', TRUE),
('Eléctricos', 'Vehículos ecológicos eléctricos e híbridos', 'https://example.com/banners/electricos.jpg', TRUE),
('Pickup', 'Camionetas para carga y aventura', 'https://example.com/banners/pickup.jpg', TRUE),
('Viajes largos', 'Ideales para carretera y viajes extensos', 'https://example.com/banners/viajes.jpg', TRUE);

-- Tabla: Paquetes
INSERT INTO Paquetes (nombre_paquete, descripcion, tipo_paquete, descuento_porcentaje, precio_fijo, fecha_inicio, fecha_fin, activo) VALUES
('Paquete Fin de Semana', '3 días (Viernes-Domingo) con descuento especial', 'Tiempo', 15.00, NULL, NULL, NULL, TRUE),
('Paquete Semanal', '7 días consecutivos con mejor tarifa', 'Tiempo', 20.00, NULL, NULL, NULL, TRUE),
('Paquete Mensual', '30 días con descuento corporativo', 'Tiempo', 35.00, NULL, NULL, NULL, TRUE),
('Paquete Todo Incluido', 'GPS + WiFi + Tanque lleno + Seguro premium', 'Combinado', 10.00, 45000.00, NULL, NULL, TRUE),
('Paquete Familiar', 'Incluye 2 sillas para niños + GPS', 'Combinado', 12.00, 25000.00, NULL, NULL, TRUE),
('Especial Temporada Alta', 'Descuento para reservas en diciembre', 'Temporal', 8.00, NULL, '2025-12-01', '2025-12-31', TRUE),
('Cliente Frecuente', 'Descuento para clientes con más de 5 reservas', 'Cliente', 25.00, NULL, NULL, NULL, TRUE);

-- Tabla: Modelo
INSERT INTO Modelo (id_modelo, nombre_modelo, tipo_vehiculo, capacidad, transmision, tipo_combustible, id_marca) VALUES
('MOD001', 'Corolla', 'Sedán', 5, 'Automática', 'Gasolina', 'MRC001'),
('MOD002', 'RAV4', 'SUV', 5, 'Automática', 'Gasolina', 'MRC001'),
('MOD003', 'Civic', 'Sedán', 5, 'Automática', 'Gasolina', 'MRC002'),
('MOD004', 'CR-V', 'SUV', 5, 'Automática', 'Gasolina', 'MRC002'),
('MOD005', 'CX-5', 'SUV', 5, 'Automática', 'Gasolina', 'MRC003'),
('MOD006', 'Spark', 'Compacto', 4, 'Manual', 'Gasolina', 'MRC004'),
('MOD007', 'Tracker', 'SUV', 5, 'Automática', 'Gasolina', 'MRC004'),
('MOD008', 'Escape', 'SUV', 5, 'Automática', 'Gasolina', 'MRC005'),
('MOD009', 'Versa', 'Sedán', 5, 'Manual', 'Gasolina', 'MRC006'),
('MOD010', 'Tucson', 'SUV', 5, 'Automática', 'Gasolina', 'MRC007'),
('MOD011', 'Sportage', 'SUV', 5, 'Automática', 'Gasolina', 'MRC008'),
('MOD012', 'Jetta', 'Sedán', 5, 'Automática', 'Gasolina', 'MRC009'),
('MOD013', 'X3', 'SUV', 5, 'Automática', 'Gasolina', 'MRC010'),
('MOD014', 'Hilux', 'Pickup', 5, 'Manual', 'Diesel', 'MRC001'),
('MOD015', 'Prius', 'Híbrido', 5, 'Automática', 'Híbrido', 'MRC001');

-- Tabla: Usuarios
INSERT INTO Usuarios (nombres, apellidos, email, contrasena, telefono, direccion, cedula, estado, id_rol, puntos_acumulados) VALUES
('Admin', 'Sistema', 'admin@alquiler.com', 'admin123', '6011111111', 'Calle 100 # 20-30', '1000000001', 'Activo', 1, 0),
('Carlos', 'Ramírez', 'carlos.ramirez@email.com', '$2y$10$hashedpassword2', '3101111111', 'Cra 7 # 45-67', '1000000002', 'Activo', 2, 1500),
('María', 'González', 'maria.gonzalez@email.com', '$2y$10$hashedpassword3', '3202222222', 'Calle 80 # 15-20', '1000000003', 'Activo', 2, 3200),
('Juan', 'Pérez', 'juan.perez@email.com', '$2y$10$hashedpassword4', '3153333333', 'Av 68 # 50-12', '1000000004', 'Activo', 2, 800),
('Ana', 'Martínez', 'ana.martinez@email.com', '$2y$10$hashedpassword5', '3124444444', 'Calle 127 # 45-89', '1000000005', 'Activo', 2, 0),
('Pedro', 'López', 'pedro.lopez@email.com', '$2y$10$hashedpassword6', '3105555555', 'Cra 30 # 67-23', '1000000006', 'Activo', 3, 0),
('Laura', 'Sánchez', 'laura.sanchez@email.com', '$2y$10$hashedpassword7', '3206666666', 'Calle 140 # 9-12', '1000000007', 'Activo', 3, 0),
('Roberto', 'García', 'roberto.garcia@email.com', '$2y$10$hashedpassword8', '3157777777', 'Av 19 # 104-56', '1000000008', 'Activo', 4, 2100),
('Diana', 'Torres', 'diana.torres@email.com', '$2y$10$hashedpassword9', '3128888888', 'Calle 72 # 10-45', '1000000009', 'Activo', 4, 0),
('Fernando', 'Ruiz', 'fernando.ruiz@email.com', '$2y$10$hashedpassword10', '3109999999', 'Cra 15 # 88-34', '1000000010', 'Activo', 2, 5600),
('Sofía', 'Vargas', 'sofia.vargas@email.com', '$2y$10$hashedpassword11', '3201111222', 'Calle 53 # 23-45', '1000000011', 'Activo', 2, 200),
('Andrés', 'Moreno', 'andres.moreno@email.com', '$2y$10$hashedpassword12', '3152223334', 'Av 68 # 123-45', '1000000012', 'Activo', 2, 0);

-- Tabla: Empleados
INSERT INTO Empleados (id_usuario, cargo, salario, fecha_contratacion, id_sucursal) VALUES
(6, 'Gerente de Sucursal', 3500000.00, '2023-01-15', 'SUC001'),
(7, 'Asesor Comercial', 2200000.00, '2023-06-20', 'SUC002');

-- Tabla: Vehiculo
INSERT INTO Vehiculo (placa, color, año, precio_dia, estado, kilometraje, imagen_principal, descripcion, destacado, calificacion_promedio, numero_reseñas, id_modelo, id_seguro, es_afiliado, id_propietario, comision_afiliado) VALUES
('ABC123', 'Blanco', 2023, 120000.00, 'Disponible', 15000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Toyota Corolla en excelente estado, ideal para ciudad', TRUE, 4.80, 25, 'MOD001', 'SEG001', FALSE, NULL, 0.00),
('DEF456', 'Negro', 2024, 180000.00, 'Disponible', 8000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'RAV4 espaciosa y cómoda para viajes familiares', TRUE, 4.90, 18, 'MOD002', 'SEG003', FALSE, NULL, 0.00),
('GHI789', 'Gris', 2023, 130000.00, 'Disponible', 22000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Honda Civic deportivo y eficiente', FALSE, 4.50, 12, 'MOD003', 'SEG001', FALSE, NULL, 0.00),
('JKL012', 'Azul', 2024, 170000.00, 'Disponible', 5000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Honda CR-V, perfecta para aventuras', TRUE, 4.70, 20, 'MOD004', 'SEG002', FALSE, NULL, 0.00),
('MNO345', 'Rojo', 2023, 160000.00, 'Alquilado', 18000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Mazda CX-5 con tecnología avanzada', FALSE, 4.60, 15, 'MOD005', 'SEG001', FALSE, NULL, 0.00),
('PQR678', 'Amarillo', 2022, 80000.00, 'Disponible', 35000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Chevrolet Spark económico para ciudad', TRUE, 4.30, 30, 'MOD006', 'SEG004', FALSE, NULL, 0.00),
('STU901', 'Blanco', 2024, 150000.00, 'Disponible', 10000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Chevrolet Tracker moderna SUV', FALSE, 4.75, 10, 'MOD007', 'SEG002', FALSE, NULL, 0.00),
('VWX234', 'Gris', 2023, 175000.00, 'Mantenimiento', 20000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Ford Escape confiable y espaciosa', FALSE, 4.55, 14, 'MOD008', 'SEG001', FALSE, NULL, 0.00),
('YZA567', 'Plata', 2022, 95000.00, 'Disponible', 40000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Nissan Versa eficiente en combustible', FALSE, 4.40, 22, 'MOD009', 'SEG004', FALSE, NULL, 0.00),
('BCD890', 'Negro', 2024, 190000.00, 'Disponible', 6000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Hyundai Tucson premium', TRUE, 4.85, 16, 'MOD010', 'SEG003', FALSE, NULL, 0.00),
('EFG123', 'Blanco', 2023, 165000.00, 'Disponible', 12000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Kia Sportage con gran capacidad', FALSE, 4.65, 19, 'MOD011', 'SEG002', FALSE, NULL, 0.00),
('HIJ456', 'Azul', 2024, 140000.00, 'Disponible', 7000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'VW Jetta elegante y confortable', FALSE, 4.70, 13, 'MOD012', 'SEG001', FALSE, NULL, 0.00),
('KLM789', 'Negro', 2024, 350000.00, 'Disponible', 3000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'BMW X3 de lujo', TRUE, 5.00, 8, 'MOD013', 'SEG005', FALSE, NULL, 0.00),
('NOP012', 'Blanco', 2022, 200000.00, 'Disponible', 45000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Toyota Hilux robusta para trabajo', FALSE, 4.80, 11, 'MOD014', 'SEG002', TRUE, 8, 15.00),
('QRS345', 'Azul', 2024, 220000.00, 'Disponible', 2000, 'https://www.deruedas.com.ar/images/autos/748/748386_1_im.jpg', 'Toyota Prius híbrido ecológico', TRUE, 4.95, 7, 'MOD015', 'SEG003', TRUE, 9, 15.00);

-- Tabla: Imagenes_Vehiculo
INSERT INTO Imagenes_Vehiculo (placa, url_imagen, orden, descripcion) VALUES
('ABC123', 'https://example.com/vehiculos/abc123_1.jpg', 1, 'Vista frontal'),
('ABC123', 'https://example.com/vehiculos/abc123_2.jpg', 2, 'Interior'),
('ABC123', 'https://example.com/vehiculos/abc123_3.jpg', 3, 'Vista lateral'),
('DEF456', 'https://example.com/vehiculos/def456_1.jpg', 1, 'Vista frontal'),
('DEF456', 'https://example.com/vehiculos/def456_2.jpg', 2, 'Maletero'),
('GHI789', 'https://example.com/vehiculos/ghi789_1.jpg', 1, 'Vista completa'),
('JKL012', 'https://example.com/vehiculos/jkl012_1.jpg', 1, 'Exterior'),
('JKL012', 'https://example.com/vehiculos/jkl012_2.jpg', 2, 'Panel de control'),
('KLM789', 'https://example.com/vehiculos/klm789_1.jpg', 1, 'Vista premium'),
('KLM789', 'https://example.com/vehiculos/klm789_2.jpg', 2, 'Interior de lujo');

-- Tabla: Vehiculo_Categoria
INSERT INTO Vehiculo_Categoria (placa, id_categoria, destacado_en_categoria) VALUES
('ABC123', 1, TRUE),
('PQR678', 1, TRUE),
('YZA567', 1, FALSE),
('DEF456', 2, TRUE),
('JKL012', 2, FALSE),
('MNO345', 2, FALSE),
('STU901', 2, FALSE),
('VWX234', 2, FALSE),
('BCD890', 2, TRUE),
('EFG123', 2, FALSE),
('KLM789', 3, TRUE),
('DEF456', 4, FALSE),
('JKL012', 4, TRUE),
('MNO345', 4, FALSE),
('HIJ456', 5, FALSE),
('QRS345', 6, TRUE),
('NOP012', 7, TRUE),
('ABC123', 8, FALSE),
('DEF456', 8, TRUE),
('JKL012', 8, FALSE);

-- Tabla: Paquete_Extras
INSERT INTO Paquete_Extras (id_paquete, id_extra, incluido) VALUES
(4, 1, TRUE),
(4, 5, TRUE),
(4, 9, TRUE),
(5, 2, TRUE),
(5, 3, TRUE),
(5, 1, TRUE);

-- Tabla: Mantenimiento
INSERT INTO Mantenimiento (placa, tipo_mantenimiento, descripcion, fecha_mantenimiento, kilometraje_actual, costo, proximo_mantenimiento_km, proximo_mantenimiento_fecha, id_empleado, estado) VALUES
('ABC123', 'Preventivo', 'Cambio de aceite y filtros', '2025-09-15', 15000, 250000.00, 25000, '2025-12-15', 1, 'Completado'),
('DEF456', 'Preventivo', 'Revisión general de 10,000 km', '2025-10-20', 8000, 350000.00, 18000, '2026-01-20', 1, 'Completado'),
('VWX234', 'Correctivo', 'Reparación de frenos', '2025-11-08', 20000, 480000.00, 30000, '2026-02-08', 1, 'En Proceso'),
('MNO345', 'Preventivo', 'Cambio de llantas', '2025-08-25', 18000, 800000.00, 28000, '2026-01-25', 1, 'Completado'),
('PQR678', 'Correctivo', 'Reparación de sistema eléctrico', '2025-07-10', 35000, 320000.00, 45000, '2025-12-10', 1, 'Completado');

-- Tabla: Reservas
INSERT INTO Reservas (fecha_inicio, fecha_fin, hora_recogida, hora_entrega, dias_alquiler, subtotal, descuento, total, estado, metodo_recogida, direccion_entrega, observaciones, id_usuario, placa, id_sucursal, id_empleado_atiende, id_paquete, puntos_usados, puntos_ganados, fecha_creacion) VALUES
('2025-10-15', '2025-10-22', '09:00:00', '09:00:00', 7, 840000.00, 168000.00, 672000.00, 'Finalizada', 'Sucursal', NULL, 'Cliente preferencial', 2, 'ABC123', 'SUC001', 1, 2, 0, 672, '2025-10-10 14:30:00'),
('2025-10-20', '2025-10-23', '10:00:00', '10:00:00', 3, 360000.00, 54000.00, 306000.00, 'Finalizada', 'Sucursal', NULL, NULL, 3, 'PQR678', 'SUC002', 2, 1, 0, 306, '2025-10-18 11:20:00'),
('2025-11-01', '2025-11-08', '08:30:00', '18:00:00', 7, 1260000.00, 252000.00, 1008000.00, 'Finalizada', 'Domicilio', 'Cra 15 # 140-20', 'Entregar en recepción', 4, 'DEF456', 'SUC002', 2, 2, 0, 1008, '2025-10-28 16:45:00'),
('2025-11-05', '2025-11-10', '09:00:00', '09:00:00', 5, 850000.00, 0.00, 850000.00, 'Finalizada', 'Sucursal', NULL, NULL, 5, 'JKL012', 'SUC001', 1, NULL, 0, 850, '2025-11-02 10:15:00'),
('2025-11-12', '2025-11-15', '11:00:00', '11:00:00', 3, 480000.00, 72000.00, 408000.00, 'Confirmada', 'Sucursal', NULL, NULL, 10, 'MNO345', 'SUC003', NULL, 1, 0, 0, '2025-11-10 09:30:00'),
('2025-11-15', '2025-11-17', '14:00:00', '14:00:00', 2, 240000.00, 0.00, 240000.00, 'Confirmada', 'Sucursal', NULL, 'Primera reserva', 11, 'PQR678', 'SUC001', NULL, NULL, 0, 0, '2025-11-11 13:45:00'),
('2025-11-18', '2025-11-25', '09:00:00', '09:00:00', 7, 1330000.00, 266000.00, 1064000.00, 'Pendiente', 'Domicilio', 'Av 68 # 50-12', 'Llamar antes de entregar', 4, 'BCD890', 'SUC002', NULL, 2, 0, 0, '2025-11-12 10:00:00'),
('2025-11-20', '2025-12-20', '10:00:00', '10:00:00', 30, 4200000.00, 1470000.00, 2730000.00, 'Pendiente', 'Sucursal', NULL, 'Alquiler corporativo', 10, 'HIJ456', 'SUC001', NULL, 3, 0, 0, '2025-11-12 11:30:00');

-- Tabla: Reserva_Extras
INSERT INTO Reserva_Extras (id_reserva, id_extra, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 1, 5000.00, 35000.00),
(1, 9, 1, 0.00, 0.00),
(2, 2, 1, 8000.00, 24000.00),
(3, 1, 1, 5000.00, 35000.00),
(3, 5, 1, 10000.00, 70000.00),
(3, 9, 1, 0.00, 0.00),
(4, 4, 1, 15000.00, 75000.00),
(5, 1, 1, 5000.00, 15000.00),
(7, 1, 1, 5000.00, 35000.00),
(7, 5, 1, 10000.00, 70000.00);

-- Tabla: Pagos
INSERT INTO Pagos (id_reserva, monto, metodo_pago, estado_pago, referencia_pago, fecha_pago, id_empleado_procesa) VALUES
(1, 672000.00, 'Tarjeta Crédito', 'Confirmado', 'TXN001234567890', '2025-10-10 14:35:00', 1),
(2, 306000.00, 'Transferencia', 'Confirmado', 'TXN001234567891', '2025-10-18 11:25:00', 2),
(3, 1008000.00, 'Tarjeta Débito', 'Confirmado', 'TXN001234567892', '2025-10-28 16:50:00', 2),
(4, 850000.00, 'Efectivo', 'Confirmado', 'EFE-2025-001', '2025-11-05 09:10:00', 1),
(5, 408000.00, 'PayPal', 'Confirmado', 'PAYPAL-2025-001', '2025-11-10 09:35:00', NULL),
(6, 240000.00, 'Tarjeta Crédito', 'Pendiente', 'TXN001234567893', '2025-11-11 13:50:00', NULL);

-- Tabla: Facturas
INSERT INTO Facturas (id_reserva, numero_factura, fecha_emision, subtotal, iva, descuentos, total_pagar) VALUES
(1, 'FAC-2025-0001', '2025-10-10', 707000.00, 127260.00, 168000.00, 672000.00),
(2, 'FAC-2025-0002', '2025-10-18', 330000.00, 59400.00, 54000.00, 306000.00),
(3, 'FAC-2025-0003', '2025-10-28', 1113000.00, 200340.00, 252000.00, 1008000.00),
(4, 'FAC-2025-0004', '2025-11-05', 925000.00, 166500.00, 0.00, 850000.00),
(5, 'FAC-2025-0005', '2025-11-10', 423000.00, 76140.00, 72000.00, 408000.00),
(6, 'FAC-2025-0006', '2025-11-11', 240000.00, 43200.00, 0.00, 240000.00);

-- Tabla: Reseñas
INSERT INTO Reseñas (id_usuario, placa, id_reserva, calificacion, comentario, fecha_reseña, verificado) VALUES
(2, 'ABC123', 1, 5, 'Excelente vehículo, muy cómodo y en perfecto estado. El proceso de alquiler fue muy sencillo.', '2025-10-23 10:30:00', TRUE),
(3, 'PQR678', 2, 4, 'Buen carro económico, cumplió con lo esperado. Solo le faltaba un poco más de potencia.', '2025-10-24 15:20:00', TRUE),
(4, 'DEF456', 3, 5, 'Increíble SUV, perfecta para viaje familiar. Muy espaciosa y confortable.', '2025-11-09 09:15:00', TRUE),
(5, 'JKL012', 4, 5, 'Excelente experiencia, el vehículo estaba impecable y el servicio fue de primera.', '2025-11-11 14:45:00', TRUE)