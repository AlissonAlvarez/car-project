-- ============================================
-- BASE DE DATOS: alquiler_vehiculos
-- VERSIÓN COMPLETA - TODAS LAS TABLAS RELACIONADAS
-- ============================================
CREATE DATABASE IF NOT EXISTS alquiler_vehiculos;
USE alquiler_vehiculos;

/*-+-----------------------------+
   |    ESTRUCTURA DE TABLAS     |
   |  ORDEN DE DEPENDENCIAS      |
   +-----------------------------+*/

-- ============================================
-- NIVEL 1: TABLAS INDEPENDIENTES (Sin FK)
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

-- Tabla: Categorias_Contexto
CREATE TABLE Categorias_Contexto (
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

-- Tabla: Promociones
CREATE TABLE Promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_promocion VARCHAR(100) NOT NULL,
    descripcion TEXT,
    codigo_promocional VARCHAR(20) UNIQUE,
    descuento_porcentaje DECIMAL(5,2),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    usos_maximos INT DEFAULT NULL,
    usos_actuales INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE
) AUTO_INCREMENT = 1;

-- Tabla: Configuracion_Sistema
CREATE TABLE Configuracion_Sistema (
    id_config INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(50) UNIQUE NOT NULL,
    valor TEXT,
    descripcion VARCHAR(200),
    tipo_dato ENUM('texto','numero','booleano','json') DEFAULT 'texto'
) AUTO_INCREMENT = 1;

-- Tabla: Blog_Articulos (Sin relaciones, independiente)
CREATE TABLE Blog_Articulos (
    id_articulo INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE,
    contenido TEXT,
    imagen_destacada VARCHAR(255),
    autor VARCHAR(100),
    id_autor INT NULL, -- Relación opcional con Usuarios
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    categoria VARCHAR(50),
    visitas INT DEFAULT 0,
    publicado BOOLEAN DEFAULT TRUE
) AUTO_INCREMENT = 1;

-- Tabla: Mensajes_Contacto (Sin relaciones FK requeridas)
CREATE TABLE Mensajes_Contacto (
    id_mensaje INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(80) NOT NULL,
    telefono VARCHAR(20),
    asunto VARCHAR(150),
    mensaje TEXT NOT NULL,
    id_usuario INT NULL, -- Opcional: si el usuario está logueado
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    respondido BOOLEAN DEFAULT FALSE,
    id_empleado_responde INT NULL -- Quién respondió
) AUTO_INCREMENT = 1;


-- ============================================
-- NIVEL 2: TABLAS CON 1 DEPENDENCIA
-- ============================================

-- Tabla: Modelo (depende de Marca)
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

-- Tabla: Usuarios (depende de Roles)
CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(100),
    cedula VARCHAR(15) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Activo','Inactivo','Suspendido') DEFAULT 'Activo',
    id_rol INT NOT NULL,
    puntos_acumulados INT DEFAULT 0,
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol) ON DELETE RESTRICT
) AUTO_INCREMENT = 1;


-- ============================================
-- NIVEL 3: TABLAS CON 2+ DEPENDENCIAS
-- ============================================

-- Tabla: Empleados (depende de Usuarios y Sucursal)
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

-- Tabla: Vehiculo (depende de Modelo, Seguro, Usuarios)
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

-- Tabla: Solicitudes_Afiliacion (depende de Usuarios)
CREATE TABLE Solicitudes_Afiliacion (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    placa VARCHAR(10) NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    año YEAR,
    color VARCHAR(30),
    precio_sugerido DECIMAL(10,2),
    documentos_url TEXT,
    estado_solicitud ENUM('Pendiente','En Revisión','Aprobada','Rechazada') DEFAULT 'Pendiente',
    comentario_admin TEXT,
    id_empleado_revisor INT NULL,
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta TIMESTAMP NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_empleado_revisor) REFERENCES Empleados(id_empleado) ON DELETE SET NULL
) AUTO_INCREMENT = 1;

-- Tabla: Cupones_Usuario (depende de Usuarios y Promociones)
CREATE TABLE Cupones_Usuario (
    id_cupon_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_promocion INT NOT NULL,
    usado BOOLEAN DEFAULT FALSE,
    fecha_uso TIMESTAMP NULL,
    id_reserva_usado INT NULL, -- Relación con reserva donde se usó
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_promocion) REFERENCES Promociones(id_promocion) ON DELETE CASCADE
) AUTO_INCREMENT = 1;

-- Tabla: Notificaciones (depende de Usuarios)
CREATE TABLE Notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo_notificacion ENUM('Reserva','Pago','Mantenimiento','Promocion','Sistema') DEFAULT 'Sistema',
    titulo VARCHAR(100),
    mensaje TEXT,
    leido BOOLEAN DEFAULT FALSE,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_relacionado INT NULL, -- ID genérico para relacionar con reserva, pago, etc.
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
) AUTO_INCREMENT = 1;


-- ============================================
-- NIVEL 4: TABLAS INTERMEDIAS Y RELACIONALES
-- ============================================

-- Tabla: Imagenes_Vehiculo (depende de Vehiculo)
CREATE TABLE Imagenes_Vehiculo (
    id_imagen INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    url_imagen VARCHAR(255) NOT NULL,
    orden INT DEFAULT 1,
    descripcion VARCHAR(200) NULL,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE
) AUTO_INCREMENT = 1;

-- Tabla: Vehiculo_Categoria (relación M:M entre Vehiculo y Categorias_Contexto)
CREATE TABLE Vehiculo_Categoria (
    id_vehiculo_categoria INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    id_categoria INT NOT NULL,
    destacado_en_categoria BOOLEAN DEFAULT FALSE,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categorias_Contexto(id_categoria) ON DELETE CASCADE,
    UNIQUE KEY unique_vehiculo_categoria (placa, id_categoria)
) AUTO_INCREMENT = 1;

-- Tabla: Paquete_Extras (relación M:M entre Paquetes y Extras)
CREATE TABLE Paquete_Extras (
    id_paquete_extra INT AUTO_INCREMENT PRIMARY KEY,
    id_paquete INT NOT NULL,
    id_extra INT NOT NULL,
    incluido BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_paquete) REFERENCES Paquetes(id_paquete) ON DELETE CASCADE,
    FOREIGN KEY (id_extra) REFERENCES Extras(id_extra) ON DELETE CASCADE,
    UNIQUE KEY unique_paquete_extra (id_paquete, id_extra)
) AUTO_INCREMENT = 1;

-- Tabla: Mantenimiento (depende de Vehiculo y Empleados)
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

-- Tabla: Reservas (depende de Usuarios, Vehiculo, Sucursal, Paquetes, Promociones)
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
    id_promocion INT NULL,
    puntos_usados INT DEFAULT 0,
    puntos_ganados INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE RESTRICT,
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal) ON DELETE RESTRICT,
    FOREIGN KEY (id_empleado_atiende) REFERENCES Empleados(id_empleado) ON DELETE SET NULL,
    FOREIGN KEY (id_paquete) REFERENCES Paquetes(id_paquete) ON DELETE SET NULL,
    FOREIGN KEY (id_promocion) REFERENCES Promociones(id_promocion) ON DELETE SET NULL
) AUTO_INCREMENT = 1;


-- ============================================
-- NIVEL 5: TABLAS QUE DEPENDEN DE RESERVAS
-- ============================================

-- Tabla: Reserva_Extras (depende de Reservas y Extras)
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

-- Tabla: Pagos (depende de Reservas)
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

-- Tabla: Facturas (depende de Reservas)
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

-- Tabla: Reseñas (depende de Usuarios, Vehiculo y Reservas)
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

-- Tabla: Pagos_Afiliados (depende de Usuarios y Reservas)
CREATE TABLE Pagos_Afiliados (
    id_pago_afiliado INT AUTO_INCREMENT PRIMARY KEY,
    id_propietario INT NOT NULL,
    id_reserva INT NOT NULL,
    monto_reserva DECIMAL(10,2),
    comision_porcentaje DECIMAL(5,2),
    monto_comision DECIMAL(10,2),
    monto_propietario DECIMAL(10,2),
    estado_pago ENUM('Pendiente','Procesado','Completado') DEFAULT 'Pendiente',
    fecha_pago TIMESTAMP NULL,
    referencia_transaccion VARCHAR(100) NULL,
    FOREIGN KEY (id_propietario) REFERENCES Usuarios(id_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva) ON DELETE RESTRICT
) AUTO_INCREMENT = 1;

-- Tabla: Historial_Puntos (depende de Usuarios y Reservas)
CREATE TABLE Historial_Puntos (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    puntos INT NOT NULL,
    tipo_movimiento ENUM('Ganados','Usados','Expirados','Ajuste') DEFAULT 'Ganados',
    descripcion VARCHAR(200),
    id_reserva INT NULL,
    id_empleado_autoriza INT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva) ON DELETE SET NULL,
    FOREIGN KEY (id_empleado_autoriza) REFERENCES Empleados(id_empleado) ON DELETE SET NULL
) AUTO_INCREMENT = 1;


-- ============================================
-- TABLAS DE AUDITORÍA
-- ============================================

-- Tabla: Auditoria_Vehiculo
CREATE TABLE Auditoria_Vehiculo (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    campo_modificado VARCHAR(50),
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario VARCHAR(100),
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_operacion VARCHAR(20),
    FOREIGN KEY (placa) REFERENCES Vehiculo(placa) ON DELETE CASCADE
) AUTO_INCREMENT = 1;


-- ============================================
-- AGREGAR FOREIGN KEYS OPCIONALES
-- ============================================

-- Blog_Articulos -> Usuarios (autor)
ALTER TABLE Blog_Articulos 
ADD CONSTRAINT fk_blog_autor 
FOREIGN KEY (id_autor) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL;

-- Mensajes_Contacto -> Usuarios (usuario logueado)
ALTER TABLE Mensajes_Contacto 
ADD CONSTRAINT fk_mensaje_usuario 
FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL;

-- Mensajes_Contacto -> Empleados (quien responde)
ALTER TABLE Mensajes_Contacto 
ADD CONSTRAINT fk_mensaje_empleado_responde 
FOREIGN KEY (id_empleado_responde) REFERENCES Empleados(id_empleado) ON DELETE SET NULL;

-- Cupones_Usuario -> Reservas (donde se usó)
ALTER TABLE Cupones_Usuario 
ADD CONSTRAINT fk_cupon_reserva 
FOREIGN KEY (id_reserva_usado) REFERENCES Reservas(id_reserva) ON DELETE SET NULL;


/*-+-----------------------------+
   |      ÍNDICES OPTIMIZACIÓN   |
   +-----------------------------+*/

CREATE INDEX idx_reservas_fechas ON Reservas(fecha_inicio, fecha_fin);
CREATE INDEX idx_reservas_estado ON Reservas(estado);
CREATE INDEX idx_reservas_usuario ON Reservas(id_usuario);
CREATE INDEX idx_vehiculo_estado ON Vehiculo(estado);
CREATE INDEX idx_vehiculo_destacado ON Vehiculo(destacado);
CREATE INDEX idx_usuarios_email ON Usuarios(email);
CREATE INDEX idx_usuarios_rol ON Usuarios(id_rol);
CREATE INDEX idx_pagos_estado ON Pagos(estado_pago);
CREATE INDEX idx_reseñas_placa ON Reseñas(placa);
CREATE INDEX idx_reseñas_verificado ON Reseñas(verificado);
CREATE INDEX idx_notificaciones_usuario_leido ON Notificaciones(id_usuario, leido);
CREATE INDEX idx_mantenimiento_fecha ON Mantenimiento(fecha_mantenimiento);
CREATE INDEX idx_vehiculo_categoria ON Vehiculo_Categoria(id_categoria);
CREATE INDEX idx_blog_publicado ON Blog_Articulos(publicado, fecha_publicacion);
CREATE INDEX idx_mensajes_leido ON Mensajes_Contacto(leido, respondido);



/*-+-----------------------------+
   |           INSERTS           |
   +-----------------------------+*/

-- ============================================
-- INSERTS PARA BASE DE DATOS: alquiler_vehiculos
-- ============================================
USE alquiler_vehiculos;

-- ============================================
-- NIVEL 1: TABLAS INDEPENDIENTES
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

-- Tabla: Categorias_Contexto
INSERT INTO Categorias_Contexto (nombre_categoria, descripcion, imagen_banner, activo) VALUES
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

-- Tabla: Promociones
INSERT INTO Promociones (nombre_promocion, descripcion, codigo_promocional, descuento_porcentaje, fecha_inicio, fecha_fin, usos_maximos, usos_actuales, activo) VALUES
('Bienvenida 2025', 'Descuento de bienvenida para nuevos clientes', 'BIENVENIDA2025', 20.00, '2025-01-01', '2025-12-31', 500, 45, TRUE),
('Black Friday', 'Descuento especial Black Friday', 'BLACKFRIDAY', 30.00, '2025-11-25', '2025-11-30', 200, 12, TRUE),
('Verano 2025', 'Promoción de temporada de verano', 'VERANO2025', 15.00, '2025-06-01', '2025-08-31', NULL, 0, TRUE),
('Referido', 'Descuento por referir a un amigo', 'AMIGO10', 10.00, '2025-01-01', '2025-12-31', NULL, 23, TRUE),
('Cumpleaños', 'Regalo de cumpleaños', 'CUMPLE15', 15.00, '2025-01-01', '2025-12-31', NULL, 8, TRUE);

-- Tabla: Configuracion_Sistema
INSERT INTO Configuracion_Sistema (clave, valor, descripcion, tipo_dato) VALUES
('puntos_por_peso', '10', 'Puntos acumulados por cada $10,000 gastados', 'numero'),
('valor_punto', '100', 'Valor en pesos de cada punto de fidelidad', 'numero'),
('dias_maximos_reserva', '90', 'Cantidad máxima de días para una reserva', 'numero'),
('dias_minimos_reserva', '1', 'Cantidad mínima de días para una reserva', 'numero'),
('hora_cierre_sucursal', '18:00', 'Hora de cierre de sucursales', 'texto'),
('penalizacion_cancelacion', '20', 'Porcentaje de penalización por cancelación tardía', 'numero'),
('dias_anticipacion_minima', '1', 'Días mínimos de anticipación para reservar', 'numero'),
('email_soporte', 'soporte@alquiler.com', 'Email de contacto de soporte', 'texto'),
('telefono_soporte', '6011234567', 'Teléfono de soporte', 'texto'),
('iva_porcentaje', '19', 'Porcentaje de IVA aplicado', 'numero');

-- Tabla: Blog_Articulos
INSERT INTO Blog_Articulos (titulo, slug, contenido, imagen_destacada, autor, fecha_publicacion, categoria, visitas, publicado) VALUES
('Consejos para conducir en carretera', 'consejos-conducir-carretera', 'Contenido del artículo sobre consejos de conducción...', 'https://example.com/blog/carretera.jpg', 'Juan Pérez', '2025-01-15 10:00:00', 'Consejos', 234, TRUE),
('Los mejores destinos para viajar en carro', 'mejores-destinos-viajar', 'Descubre los lugares más hermosos de Colombia...', 'https://example.com/blog/destinos.jpg', 'María González', '2025-02-10 14:30:00', 'Viajes', 567, TRUE),
('Mantenimiento básico de tu vehículo', 'mantenimiento-basico-vehiculo', 'Aprende a cuidar tu vehículo de alquiler...', 'https://example.com/blog/mantenimiento.jpg', 'Carlos Rodríguez', '2025-03-05 09:00:00', 'Mantenimiento', 189, TRUE),
('Ventajas de alquilar un carro eléctrico', 'ventajas-carro-electrico', 'Los beneficios de elegir vehículos eléctricos...', 'https://example.com/blog/electrico.jpg', 'Ana Martínez', '2025-03-20 11:15:00', 'Sostenibilidad', 423, TRUE),
('Cómo ahorrar en tu próximo alquiler', 'ahorrar-proximo-alquiler', 'Tips para obtener las mejores tarifas...', 'https://example.com/blog/ahorrar.jpg', 'Juan Pérez', '2025-04-01 16:00:00', 'Consejos', 890, TRUE);

-- Tabla: Mensajes_Contacto
INSERT INTO Mensajes_Contacto (nombre, email, telefono, asunto, mensaje, fecha_envio, leido, respondido) VALUES
('Pedro López', 'pedro.lopez@email.com', '3101234567', 'Consulta sobre reserva', '¿Puedo modificar una reserva ya confirmada?', '2025-11-01 10:30:00', TRUE, TRUE),
('Laura Sánchez', 'laura.sanchez@email.com', '3209876543', 'Problema con pago', 'Mi pago no se procesó correctamente', '2025-11-05 14:20:00', TRUE, TRUE),
('Roberto García', 'roberto.garcia@email.com', '3157778888', 'Información general', 'Quisiera saber los requisitos para alquilar', '2025-11-08 09:15:00', TRUE, FALSE),
('Diana Torres', 'diana.torres@email.com', '3126665555', 'Afiliación de vehículo', '¿Cómo puedo afiliar mi vehículo?', '2025-11-10 16:45:00', FALSE, FALSE);

-- ============================================
-- NIVEL 2: TABLAS CON 1 DEPENDENCIA
-- ============================================

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
INSERT INTO Usuarios (nombres, apellidos, email, contraseña, telefono, direccion, cedula, estado, id_rol, puntos_acumulados) VALUES
('Admin', 'Sistema', 'admin@alquiler.com', '$2y$10$hashedpassword1', '6011111111', 'Calle 100 # 20-30', '1000000001', 'Activo', 1, 0),
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

-- ============================================
-- NIVEL 3: TABLAS CON 2+ DEPENDENCIAS
-- ============================================

-- Tabla: Empleados
INSERT INTO Empleados (id_usuario, cargo, salario, fecha_contratacion, id_sucursal) VALUES
(6, 'Gerente de Sucursal', 3500000.00, '2023-01-15', 'SUC001'),
(7, 'Asesor Comercial', 2200000.00, '2023-06-20', 'SUC002');

-- Tabla: Vehiculo
INSERT INTO Vehiculo (placa, color, año, precio_dia, estado, kilometraje, imagen_principal, descripcion, destacado, calificacion_promedio, numero_reseñas, id_modelo, id_seguro, es_afiliado, id_propietario, comision_afiliado) VALUES
('ABC123', 'Blanco', 2023, 120000.00, 'Disponible', 15000, 'https://example.com/vehiculos/abc123.jpg', 'Toyota Corolla en excelente estado, ideal para ciudad', TRUE, 4.80, 25, 'MOD001', 'SEG001', FALSE, NULL, 0.00),
('DEF456', 'Negro', 2024, 180000.00, 'Disponible', 8000, 'https://example.com/vehiculos/def456.jpg', 'RAV4 espaciosa y cómoda para viajes familiares', TRUE, 4.90, 18, 'MOD002', 'SEG003', FALSE, NULL, 0.00),
('GHI789', 'Gris', 2023, 130000.00, 'Disponible', 22000, 'https://example.com/vehiculos/ghi789.jpg', 'Honda Civic deportivo y eficiente', FALSE, 4.50, 12, 'MOD003', 'SEG001', FALSE, NULL, 0.00),
('JKL012', 'Azul', 2024, 170000.00, 'Disponible', 5000, 'https://example.com/vehiculos/jkl012.jpg', 'Honda CR-V, perfecta para aventuras', TRUE, 4.70, 20, 'MOD004', 'SEG002', FALSE, NULL, 0.00),
('MNO345', 'Rojo', 2023, 160000.00, 'Alquilado', 18000, 'https://example.com/vehiculos/mno345.jpg', 'Mazda CX-5 con tecnología avanzada', FALSE, 4.60, 15, 'MOD005', 'SEG001', FALSE, NULL, 0.00),
('PQR678', 'Amarillo', 2022, 80000.00, 'Disponible', 35000, 'https://example.com/vehiculos/pqr678.jpg', 'Chevrolet Spark económico para ciudad', TRUE, 4.30, 30, 'MOD006', 'SEG004', FALSE, NULL, 0.00),
('STU901', 'Blanco', 2024, 150000.00, 'Disponible', 10000, 'https://example.com/vehiculos/stu901.jpg', 'Chevrolet Tracker moderna SUV', FALSE, 4.75, 10, 'MOD007', 'SEG002', FALSE, NULL, 0.00),
('VWX234', 'Gris', 2023, 175000.00, 'Mantenimiento', 20000, 'https://example.com/vehiculos/vwx234.jpg', 'Ford Escape confiable y espaciosa', FALSE, 4.55, 14, 'MOD008', 'SEG001', FALSE, NULL, 0.00),
('YZA567', 'Plata', 2022, 95000.00, 'Disponible', 40000, 'https://example.com/vehiculos/yza567.jpg', 'Nissan Versa eficiente en combustible', FALSE, 4.40, 22, 'MOD009', 'SEG004', FALSE, NULL, 0.00),
('BCD890', 'Negro', 2024, 190000.00, 'Disponible', 6000, 'https://example.com/vehiculos/bcd890.jpg', 'Hyundai Tucson premium', TRUE, 4.85, 16, 'MOD010', 'SEG003', FALSE, NULL, 0.00),
('EFG123', 'Blanco', 2023, 165000.00, 'Disponible', 12000, 'https://example.com/vehiculos/efg123.jpg', 'Kia Sportage con gran capacidad', FALSE, 4.65, 19, 'MOD011', 'SEG002', FALSE, NULL, 0.00),
('HIJ456', 'Azul', 2024, 140000.00, 'Disponible', 7000, 'https://example.com/vehiculos/hij456.jpg', 'VW Jetta elegante y confortable', FALSE, 4.70, 13, 'MOD012', 'SEG001', FALSE, NULL, 0.00),
('KLM789', 'Negro', 2024, 350000.00, 'Disponible', 3000, 'https://example.com/vehiculos/klm789.jpg', 'BMW X3 de lujo', TRUE, 5.00, 8, 'MOD013', 'SEG005', FALSE, NULL, 0.00),
('NOP012', 'Blanco', 2022, 200000.00, 'Disponible', 45000, 'https://example.com/vehiculos/nop012.jpg', 'Toyota Hilux robusta para trabajo', FALSE, 4.80, 11, 'MOD014', 'SEG002', TRUE, 8, 15.00),
('QRS345', 'Azul', 2024, 220000.00, 'Disponible', 2000, 'https://example.com/vehiculos/qrs345.jpg', 'Toyota Prius híbrido ecológico', TRUE, 4.95, 7, 'MOD015', 'SEG003', TRUE, 9, 15.00);

-- Tabla: Solicitudes_Afiliacion
INSERT INTO Solicitudes_Afiliacion (id_usuario, placa, marca, modelo, año, color, precio_sugerido, documentos_url, estado_solicitud, comentario_admin, id_empleado_revisor, fecha_solicitud, fecha_respuesta) VALUES
(8, 'NOP012', 'Toyota', 'Hilux', 2022, 'Blanco', 200000.00, 'https://example.com/docs/solicitud1.pdf', 'Aprobada', 'Vehículo aprobado, excelente estado', 1, '2025-09-15 10:00:00', '2025-09-20 14:30:00'),
(9, 'QRS345', 'Toyota', 'Prius', 2024, 'Azul', 220000.00, 'https://example.com/docs/solicitud2.pdf', 'Aprobada', 'Aprobado, documentación completa', 1, '2025-10-05 11:20:00', '2025-10-08 16:00:00'),
(8, 'TUV678', 'Mazda', '3', 2021, 'Rojo', 110000.00, 'https://example.com/docs/solicitud3.pdf', 'En Revisión', NULL, 1, '2025-11-10 09:45:00', NULL),
(10, 'WXY901', 'Chevrolet', 'Onix', 2023, 'Gris', 100000.00, 'https://example.com/docs/solicitud4.pdf', 'Pendiente', NULL, NULL, '2025-11-11 15:30:00', NULL);

-- Tabla: Cupones_Usuario (sin id_reserva_usado, se actualiza después)
INSERT INTO Cupones_Usuario (id_usuario, id_promocion, usado, fecha_uso, id_reserva_usado) VALUES
(2, 1, FALSE, NULL, NULL),
(3, 4, FALSE, NULL, NULL),
(4, 1, FALSE, NULL, NULL),
(5, 5, FALSE, NULL, NULL),
(10, 2, FALSE, NULL, NULL),
(11, 1, FALSE, NULL, NULL);

-- Tabla: Notificaciones
INSERT INTO Notificaciones (id_usuario, tipo_notificacion, titulo, mensaje, leido, fecha_envio, id_relacionado) VALUES
(2, 'Reserva', 'Reserva Confirmada', 'Tu reserva #1 ha sido confirmada exitosamente', TRUE, '2025-10-15 10:35:00', 1),
(2, 'Pago', 'Pago Recibido', 'Hemos recibido tu pago por $840,000', TRUE, '2025-10-15 10:40:00', 1),
(3, 'Reserva', 'Reserva Confirmada', 'Tu reserva #2 ha sido confirmada', TRUE, '2025-10-20 14:25:00', 2),
(4, 'Promocion', 'Nueva Promoción', 'Black Friday: 30% de descuento con código BLACKFRIDAY', FALSE, '2025-11-01 08:00:00', NULL),
(5, 'Sistema', 'Bienvenido', 'Gracias por registrarte en nuestro sistema', TRUE, '2025-11-05 12:00:00', NULL),
(10, 'Reserva', 'Reserva Próxima', 'Tu reserva comienza mañana. ¡Prepárate para tu viaje!', FALSE, '2025-11-11 18:00:00', 5),
(11, 'Promocion', 'Cumpleaños Feliz', 'Tienes 15% de descuento por tu cumpleaños', FALSE, '2025-11-10 00:00:00', NULL);

-- ============================================
-- NIVEL 4: TABLAS INTERMEDIAS Y RELACIONALES
-- ============================================

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
INSERT INTO Reservas (fecha_inicio, fecha_fin, hora_recogida, hora_entrega, dias_alquiler, subtotal, descuento, total, estado, metodo_recogida, direccion_entrega, observaciones, id_usuario, placa, id_sucursal, id_empleado_atiende, id_paquete, id_promocion, puntos_usados, puntos_ganados, fecha_creacion) VALUES
('2025-10-15', '2025-10-22', '09:00:00', '09:00:00', 7, 840000.00, 168000.00, 672000.00, 'Finalizada', 'Sucursal', NULL, 'Cliente preferencial', 2, 'ABC123', 'SUC001', 1, 2, 1, 0, 672, '2025-10-10 14:30:00'),
('2025-10-20', '2025-10-23', '10:00:00', '10:00:00', 3, 360000.00, 54000.00, 306000.00, 'Finalizada', 'Sucursal', NULL, NULL, 3, 'PQR678', 'SUC002', 2, 1, NULL, 0, 306, '2025-10-18 11:20:00'),
('2025-11-01', '2025-11-08', '08:30:00', '18:00:00', 7, 1260000.00, 252000.00, 1008000.00, 'Finalizada', 'Domicilio', 'Cra 15 # 140-20', 'Entregar en recepción', 4, 'DEF456', 'SUC002', 2, 2, NULL, 0, 1008, '2025-10-28 16:45:00'),
('2025-11-05', '2025-11-10', '09:00:00', '09:00:00', 5, 850000.00, 0.00, 850000.00, 'Finalizada', 'Sucursal', NULL, NULL, 5, 'JKL012', 'SUC001', 1, NULL, NULL, 0, 850, '2025-11-02 10:15:00'),
('2025-11-12', '2025-11-15', '11:00:00', '11:00:00', 3, 480000.00, 72000.00, 408000.00, 'Confirmada', 'Sucursal', NULL, NULL, 10, 'MNO345', 'SUC003', NULL, 1, NULL, 0, 0, '2025-11-10 09:30:00'),
('2025-11-15', '2025-11-17', '14:00:00', '14:00:00', 2, 240000.00, 0.00, 240000.00, 'Confirmada', 'Sucursal', NULL, 'Primera reserva', 11, 'PQR678', 'SUC001', NULL, NULL, NULL, 0, 0, '2025-11-11 13:45:00'),
('2025-11-18', '2025-11-25', '09:00:00', '09:00:00', 7, 1330000.00, 266000.00, 1064000.00, 'Pendiente', 'Domicilio', 'Av 68 # 50-12', 'Llamar antes de entregar', 4, 'BCD890', 'SUC002', NULL, 2, NULL, 0, 0, '2025-11-12 10:00:00'),
('2025-11-20', '2025-12-20', '10:00:00', '10:00:00', 30, 4200000.00, 1470000.00, 2730000.00, 'Pendiente', 'Sucursal', NULL, 'Alquiler corporativo', 10, 'HIJ456', 'SUC001', NULL, 3, NULL, 0, 0, '2025-11-12 11:30:00');

-- ============================================
-- NIVEL 5: TABLAS QUE DEPENDEN DE RESERVAS
-- ============================================

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
(5, 'JKL012', 4, 5, 'Excelente experiencia, el vehículo estaba impecable y el servicio fue de primera.', '2025-11-11 14:45:00', TRUE);

-- Tabla: Pagos_Afiliados
INSERT INTO Pagos_Afiliados (id_propietario, id_reserva, monto_reserva, comision_porcentaje, monto_comision, monto_propietario, estado_pago, fecha_pago, referencia_transaccion) VALUES
(8, 1, 672000.00, 15.00, 100800.00, 571200.00, 'Completado', '2025-10-25 10:00:00', 'PAG-AFIL-001'),
(9, 2, 306000.00, 15.00, 45900.00, 260100.00, 'Completado', '2025-10-26 11:30:00', 'PAG-AFIL-002');

-- Tabla: Historial_Puntos
INSERT INTO Historial_Puntos (id_usuario, puntos, tipo_movimiento, descripcion, id_reserva, id_empleado_autoriza, fecha_movimiento) VALUES
(2, 672, 'Ganados', 'Puntos por reserva #1', 1, NULL, '2025-10-22 10:00:00'),
(3, 306, 'Ganados', 'Puntos por reserva #2', 2, NULL, '2025-10-23 11:00:00'),
(4, 1008, 'Ganados', 'Puntos por reserva #3', 3, NULL, '2025-11-08 12:00:00'),
(5, 850, 'Ganados', 'Puntos por reserva #4', 4, NULL, '2025-11-10 13:00:00'),
(10, 500, 'Ganados', 'Bonificación por registro', NULL, 1, '2025-09-20 09:00:00'),
(2, -500, 'Usados', 'Puntos usados en descuento especial', NULL, 1, '2025-10-30 14:30:00'),
(10, 200, 'Ganados', 'Bonificación por referido', NULL, NULL, '2025-10-15 16:00:00');

-- ============================================
-- TABLAS DE AUDITORÍA
-- ============================================

-- Tabla: Auditoria_Vehiculo
INSERT INTO Auditoria_Vehiculo (placa, campo_modificado, valor_anterior, valor_nuevo, usuario, fecha_modificacion, tipo_operacion) VALUES
('ABC123', 'estado', 'Disponible', 'Alquilado', 'admin@alquiler.com', '2025-10-15 09:00:00', 'UPDATE'),
('ABC123', 'kilometraje', '10000', '15000', 'admin@alquiler.com', '2025-10-22 09:30:00', 'UPDATE'),
('ABC123', 'estado', 'Alquilado', 'Disponible', 'admin@alquiler.com', '2025-10-22 09:35:00', 'UPDATE'),
('VWX234', 'estado', 'Disponible', 'Mantenimiento', 'pedro.lopez@email.com', '2025-11-08 08:00:00', 'UPDATE'),
('DEF456', 'precio_dia', '170000.00', '180000.00', 'admin@alquiler.com', '2025-11-01 10:00:00', 'UPDATE');

-- ============================================
-- INSERTS ADICIONALES PARA COMPLETAR RELACIONES
-- ============================================

-- Actualizar Blog_Articulos con id_autor
UPDATE Blog_Articulos SET id_autor = 1 WHERE id_articulo IN (1, 5);
UPDATE Blog_Articulos SET id_autor = 2 WHERE id_articulo = 2;
UPDATE Blog_Articulos SET id_autor = 6 WHERE id_articulo = 3;
UPDATE Blog_Articulos SET id_autor = 7 WHERE id_articulo = 4;

-- Actualizar Mensajes_Contacto con relaciones
UPDATE Mensajes_Contacto SET id_usuario = 2 WHERE id_mensaje = 1;
UPDATE Mensajes_Contacto SET id_usuario = 3 WHERE id_mensaje = 2;
UPDATE Mensajes_Contacto SET id_empleado_responde = 1 WHERE id_mensaje IN (1, 2);

-- Actualizar Cupones_Usuario con reserva donde se usó
UPDATE Cupones_Usuario SET id_reserva_usado = 1 WHERE id_cupon_usuario = 1;
UPDATE Cupones_Usuario SET id_reserva_usado = 2 WHERE id_cupon_usuario = 3;

-- ============================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- ============================================

-- Contar registros por tabla
SELECT 'Roles' AS Tabla, COUNT(*) AS Total FROM Roles
UNION ALL SELECT 'Marca', COUNT(*) FROM Marca
UNION ALL SELECT 'Seguro', COUNT(*) FROM Seguro
UNION ALL SELECT 'Sucursal', COUNT(*) FROM Sucursal
UNION ALL SELECT 'Extras', COUNT(*) FROM Extras
UNION ALL SELECT 'Categorias_Contexto', COUNT(*) FROM Categorias_Contexto
UNION ALL SELECT 'Paquetes', COUNT(*) FROM Paquetes
UNION ALL SELECT 'Promociones', COUNT(*) FROM Promociones
UNION ALL SELECT 'Configuracion_Sistema', COUNT(*) FROM Configuracion_Sistema
UNION ALL SELECT 'Blog_Articulos', COUNT(*) FROM Blog_Articulos
UNION ALL SELECT 'Mensajes_Contacto', COUNT(*) FROM Mensajes_Contacto
UNION ALL SELECT 'Modelo', COUNT(*) FROM Modelo
UNION ALL SELECT 'Usuarios', COUNT(*) FROM Usuarios
UNION ALL SELECT 'Empleados', COUNT(*) FROM Empleados
UNION ALL SELECT 'Vehiculo', COUNT(*) FROM Vehiculo
UNION ALL SELECT 'Solicitudes_Afiliacion', COUNT(*) FROM Solicitudes_Afiliacion
UNION ALL SELECT 'Cupones_Usuario', COUNT(*) FROM Cupones_Usuario
UNION ALL SELECT 'Notificaciones', COUNT(*) FROM Notificaciones
UNION ALL SELECT 'Imagenes_Vehiculo', COUNT(*) FROM Imagenes_Vehiculo
UNION ALL SELECT 'Vehiculo_Categoria', COUNT(*) FROM Vehiculo_Categoria
UNION ALL SELECT 'Paquete_Extras', COUNT(*) FROM Paquete_Extras
UNION ALL SELECT 'Mantenimiento', COUNT(*) FROM Mantenimiento
UNION ALL SELECT 'Reservas', COUNT(*) FROM Reservas
UNION ALL SELECT 'Reserva_Extras', COUNT(*) FROM Reserva_Extras
UNION ALL SELECT 'Pagos', COUNT(*) FROM Pagos
UNION ALL SELECT 'Facturas', COUNT(*) FROM Facturas
UNION ALL SELECT 'Reseñas', COUNT(*) FROM Reseñas
UNION ALL SELECT 'Pagos_Afiliados', COUNT(*) FROM Pagos_Afiliados
UNION ALL SELECT 'Historial_Puntos', COUNT(*) FROM Historial_Puntos
UNION ALL SELECT 'Auditoria_Vehiculo', COUNT(*) FROM Auditoria_Vehiculo;

-- ============================================
-- FIN DE INSERTS
-- ============================================


/*-+-----------------------------+
   |          CONSULTAS          |
   +-----------------------------+*/

-- Ver todas las tablas
SELECT * FROM Roles;
SELECT * FROM Usuarios;
SELECT * FROM Empleados;
SELECT * FROM Marca;
SELECT * FROM Modelo;
SELECT * FROM Seguro;
SELECT * FROM Vehiculo;
SELECT * FROM Imagenes_Vehiculo;
SELECT * FROM Sucursal;
SELECT * FROM Extras;
SELECT * FROM Categorias_Contexto;
SELECT * FROM Paquetes;
SELECT * FROM Promociones;
SELECT * FROM Reservas;
SELECT * FROM Reserva_Extras;
SELECT * FROM Pagos;
SELECT * FROM Facturas;
SELECT * FROM Mantenimiento;
SELECT * FROM Reseñas;
SELECT * FROM Notificaciones;
SELECT * FROM Solicitudes_Afiliacion;
SELECT * FROM Pagos_Afiliados;
SELECT * FROM Cupones_Usuario;
SELECT * FROM Historial_Puntos;
SELECT * FROM Blog_Articulos;
SELECT * FROM Mensajes_Contacto;
SELECT * FROM Configuracion_Sistema;

-- ============================================
-- CONSULTAS AVANZADAS
-- ============================================

-- 1. Vehículos disponibles con toda su información
SELECT v.placa, v.color, v.año, v.precio_dia, v.estado, v.calificacion_promedio,
       m.nombre_modelo, m.tipo_vehiculo, m.capacidad, m.transmision,
       ma.nombre_marca, ma.pais_origen,
       s.nombre_compania AS seguro, s.tipo_cobertura
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
INNER JOIN Seguro s ON v.id_seguro = s.id_seguro
WHERE v.estado = 'Disponible'
ORDER BY v.destacado DESC, v.precio_dia ASC;

-- 2. Top 5 clientes con más reservas
SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.puntos_acumulados,
       COUNT(r.id_reserva) AS total_reservas,
       SUM(r.total) AS gasto_total
FROM Usuarios u
INNER JOIN Reservas r ON u.id_usuario = r.id_usuario
WHERE u.id_rol = 3
GROUP BY u.id_usuario, u.nombres, u.apellidos, u.email, u.puntos_acumulados
ORDER BY total_reservas DESC
LIMIT 5;

-- 3. Ingresos por mes del año actual
SELECT 
    MONTH(r.fecha_inicio) AS mes,
    MONTHNAME(r.fecha_inicio) AS nombre_mes,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.total) AS ingresos_totales
FROM Reservas r
WHERE YEAR(r.fecha_inicio) = YEAR(CURDATE())
    AND r.estado IN ('Confirmada', 'Activa', 'Finalizada')
GROUP BY MONTH(r.fecha_inicio), MONTHNAME(r.fecha_inicio)
ORDER BY mes;

-- 4. Vehículos con mejor calificación
SELECT v.placa, m.nombre_modelo, ma.nombre_marca, v.calificacion_promedio,
       v.numero_reseñas, v.precio_dia
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
WHERE v.numero_reseñas > 0
ORDER BY v.calificacion_promedio DESC, v.numero_reseñas DESC
LIMIT 10;

-- 5. Reservas activas con información completa
SELECT r.id_reserva, r.fecha_inicio, r.fecha_fin, r.dias_alquiler, r.total,
       u.nombres AS cliente_nombre, u.apellidos AS cliente_apellido, u.telefono,
       v.placa, m.nombre_modelo, ma.nombre_marca,
       su.nombre_sucursal, su.ciudad
FROM Reservas r
INNER JOIN Usuarios u ON r.id_usuario = u.id_usuario
INNER JOIN Vehiculo v ON r.placa = v.placa
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
INNER JOIN Sucursal su ON r.id_sucursal = su.id_sucursal
WHERE r.estado = 'Activa'
ORDER BY r.fecha_inicio;

-- 6. Extras más populares
SELECT e.nombre_extra, e.precio_dia,
       COUNT(re.id_reserva_extra) AS veces_solicitado,
       SUM(re.subtotal) AS ingreso_total
FROM Extras e
LEFT JOIN Reserva_Extras re ON e.id_extra = re.id_extra
GROUP BY e.id_extra, e.nombre_extra, e.precio_dia
ORDER BY veces_solicitado DESC;

-- 7. Vehículos que necesitan mantenimiento (más de 50,000 km o sin mantenimiento reciente)
SELECT v.placa, m.nombre_modelo, ma.nombre_marca, v.kilometraje, v.estado,
       MAX(mt.fecha_mantenimiento) AS ultimo_mantenimiento,
       DATEDIFF(CURDATE(), MAX(mt.fecha_mantenimiento)) AS dias_sin_mantenimiento
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
LEFT JOIN Mantenimiento mt ON v.placa = mt.placa
WHERE v.kilometraje > 50000
GROUP BY v.placa, m.nombre_modelo, ma.nombre_marca, v.kilometraje, v.estado
HAVING dias_sin_mantenimiento > 90 OR dias_sin_mantenimiento IS NULL
ORDER BY v.kilometraje DESC;

-- 8. Historial completo de un cliente (ID = 2)
SELECT r.id_reserva, r.fecha_inicio, r.fecha_fin, r.dias_alquiler, r.total, r.estado,
       v.placa, m.nombre_modelo, ma.nombre_marca,
       p.metodo_pago, p.estado_pago,
       r.puntos_ganados
FROM Reservas r
INNER JOIN Vehiculo v ON r.placa = v.placa
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
LEFT JOIN Pagos p ON r.id_reserva = p.id_reserva
WHERE r.id_usuario = 2
ORDER BY r.fecha_inicio DESC;

-- 9. Promociones activas vigentes
SELECT id_promocion, nombre_promocion, descripcion, codigo_promocional,
       descuento_porcentaje, fecha_inicio, fecha_fin,
       usos_maximos, usos_actuales,
       (usos_maximos - usos_actuales) AS usos_disponibles
FROM Promociones
WHERE activo = TRUE
    AND fecha_inicio <= CURDATE()
    AND fecha_fin >= CURDATE()
ORDER BY descuento_porcentaje DESC;

-- 10. Rendimiento por sucursal
SELECT s.nombre_sucursal, s.ciudad,
       COUNT(r.id_reserva) AS total_reservas,
       SUM(r.total) AS ingresos_totales,
       AVG(r.total) AS ticket_promedio,
       COUNT(DISTINCT r.id_usuario) AS clientes_unicos
FROM Sucursal s
LEFT JOIN Reservas r ON s.id_sucursal = r.id_sucursal
WHERE r.estado IN ('Confirmada', 'Activa', 'Finalizada')
GROUP BY s.id_sucursal, s.nombre_sucursal, s.ciudad
ORDER BY ingresos_totales DESC;

-- 11. Vehículos afiliados y su rendimiento
SELECT v.placa, m.nombre_modelo, ma.nombre_marca,
       u.nombres AS propietario_nombre, u.apellidos AS propietario_apellido,
       v.precio_dia, v.comision_afiliado,
       COUNT(r.id_reserva) AS total_alquileres,
       SUM(r.total) AS ingresos_generados,
       SUM(pa.monto_comision) AS comisiones_totales,
       SUM(pa.monto_propietario) AS pago_propietario
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
INNER JOIN Usuarios u ON v.id_propietario = u.id_usuario
LEFT JOIN Reservas r ON v.placa = r.placa
LEFT JOIN Pagos_Afiliados pa ON r.id_reserva = pa.id_reserva
WHERE v.es_afiliado = TRUE
GROUP BY v.placa, m.nombre_modelo, ma.nombre_marca, u.nombres, u.apellidos,
         v.precio_dia, v.comision_afiliado
ORDER BY ingresos_generados DESC;

-- 12. Usuarios con más puntos acumulados
SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.puntos_acumulados,
       COUNT(r.id_reserva) AS total_reservas,
       SUM(hp.puntos) AS total_puntos_ganados
FROM Usuarios u
LEFT JOIN Reservas r ON u.id_usuario = r.id_usuario
LEFT JOIN Historial_Puntos hp ON u.id_usuario = hp.id_usuario AND hp.tipo_movimiento = 'Ganados'
WHERE u.id_rol = 3
GROUP BY u.id_usuario, u.nombres, u.apellidos, u.email, u.puntos_acumulados
ORDER BY u.puntos_acumulados DESC
LIMIT 10;


-- ============================================
-- PROCEDIMIENTO CORREGIDO: Crear nueva reserva
-- ============================================
DROP PROCEDURE IF EXISTS P_CrearReserva;

DELIMITER //
CREATE PROCEDURE P_CrearReserva(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_id_usuario INT,
    IN p_placa VARCHAR(10),
    IN p_id_sucursal VARCHAR(10),
    IN p_codigo_promocion VARCHAR(20)
)
BEGIN
    DECLARE v_dias INT;
    DECLARE v_precio_dia DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_id_promocion INT;
    DECLARE v_descuento_porcentaje DECIMAL(5,2);
    DECLARE v_puntos_ganados INT;
    DECLARE v_id_reserva INT;
    
    -- Calcular días de alquiler
    SET v_dias = DATEDIFF(p_fecha_fin, p_fecha_inicio);
    
    -- Obtener precio por día del vehículo
    SELECT precio_dia INTO v_precio_dia FROM Vehiculo WHERE placa = p_placa;
    
    -- Calcular subtotal
    SET v_subtotal = v_dias * v_precio_dia;
    
    -- Verificar si hay código promocional
    SET v_descuento = 0;
    SET v_id_promocion = NULL;
    
    IF p_codigo_promocion IS NOT NULL THEN
        SELECT id_promocion, descuento_porcentaje 
        INTO v_id_promocion, v_descuento_porcentaje
        FROM Promociones
        WHERE codigo_promocional = p_codigo_promocion
            AND activo = TRUE
            AND fecha_inicio <= CURDATE()
            AND fecha_fin >= CURDATE()
            AND (usos_maximos IS NULL OR usos_actuales < usos_maximos)
        LIMIT 1;
        
        IF v_id_promocion IS NOT NULL THEN
            SET v_descuento = v_subtotal * (v_descuento_porcentaje / 100);
            UPDATE Promociones SET usos_actuales = usos_actuales + 1 WHERE id_promocion = v_id_promocion;
        END IF;
    END IF;
    
    -- Calcular total
    SET v_total = v_subtotal - v_descuento;
    
    -- Calcular puntos ganados (0.1 punto por cada peso)
    SET v_puntos_ganados = FLOOR(v_total * 0.1);
    
    -- Insertar reserva
    INSERT INTO Reservas (fecha_inicio, fecha_fin, dias_alquiler, subtotal, descuento, total, 
                          estado, id_usuario, placa, id_sucursal, id_promocion, puntos_ganados)
    VALUES (p_fecha_inicio, p_fecha_fin, v_dias, v_subtotal, v_descuento, v_total,
            'Pendiente', p_id_usuario, p_placa, p_id_sucursal, v_id_promocion, v_puntos_ganados);
    
    -- Obtener ID de la reserva creada
    SET v_id_reserva = LAST_INSERT_ID();
    
    -- Actualizar estado del vehículo
    UPDATE Vehiculo SET estado = 'Alquilado' WHERE placa = p_placa;
    
    -- Crear notificación (CORREGIDO)
    INSERT INTO Notificaciones (id_usuario, tipo_notificacion, titulo, mensaje)
    VALUES (p_id_usuario, 'Reserva', 'Reserva Creada', 
            CONCAT('Su reserva #', v_id_reserva, ' ha sido creada. Total: $', FORMAT(v_total, 0)));
    
    SELECT v_id_reserva AS id_reserva, v_total AS total, v_puntos_ganados AS puntos;
END//
DELIMITER ;

-- ============================================
-- PROCEDIMIENTO CORREGIDO: Finalizar reserva
-- ============================================
DROP PROCEDURE IF EXISTS P_FinalizarReserva;

DELIMITER //
CREATE PROCEDURE P_FinalizarReserva(
    IN p_id_reserva INT
)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_placa VARCHAR(10);
    DECLARE v_puntos_ganados INT;
    DECLARE v_es_afiliado BOOLEAN;
    DECLARE v_id_propietario INT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_comision DECIMAL(5,2);
    
    -- Obtener datos de la reserva
    SELECT id_usuario, placa, puntos_ganados, total
    INTO v_id_usuario, v_placa, v_puntos_ganados, v_total
    FROM Reservas
    WHERE id_reserva = p_id_reserva;
    
    -- Actualizar estado de la reserva
    UPDATE Reservas SET estado = 'Finalizada' WHERE id_reserva = p_id_reserva;
    
    -- Actualizar estado del vehículo
    UPDATE Vehiculo SET estado = 'Disponible' WHERE placa = v_placa;
    
    -- Actualizar puntos del usuario
    UPDATE Usuarios 
    SET puntos_acumulados = puntos_acumulados + v_puntos_ganados
    WHERE id_usuario = v_id_usuario;
    
    -- Registrar en historial de puntos
    INSERT INTO Historial_Puntos (id_usuario, puntos, tipo_movimiento, descripcion, id_reserva)
    VALUES (v_id_usuario, v_puntos_ganados, 'Ganados', 
            CONCAT('Puntos por reserva #', p_id_reserva), p_id_reserva);
    
    -- Si es vehículo afiliado, calcular pago
    SELECT es_afiliado, id_propietario, comision_afiliado
    INTO v_es_afiliado, v_id_propietario, v_comision
    FROM Vehiculo
    WHERE placa = v_placa;
    
    IF v_es_afiliado = TRUE THEN
        INSERT INTO Pagos_Afiliados (id_propietario, id_reserva, monto_reserva, comision_porcentaje,
                                      monto_comision, monto_propietario, estado_pago)
        VALUES (v_id_propietario, p_id_reserva, v_total, v_comision,
                v_total * (v_comision / 100), v_total * (1 - v_comision / 100), 'Pendiente');
    END IF;
    
    -- Crear notificación
    INSERT INTO Notificaciones (id_usuario, tipo_notificacion, titulo, mensaje)
    VALUES (v_id_usuario, 'Reserva', 'Reserva Finalizada', 
            CONCAT('Su reserva #', p_id_reserva, ' ha finalizado. Ganó ', v_puntos_ganados, ' puntos.'));
END//
DELIMITER ;

-- Ejemplos de uso:
-- CALL P_CrearReserva('2025-12-01', '2025-12-05', 2, 'ABC123', 'SU01', 'NUEVO2025');
-- CALL P_FinalizarReserva(1);


-- ============================================
-- PROCEDIMIENTO: Registrar nuevo vehículo
-- ============================================
DELIMITER //
CREATE PROCEDURE P_RegistrarVehiculo(
    IN p_placa VARCHAR(10),
    IN p_color VARCHAR(30),
    IN p_año YEAR,
    IN p_precio_dia DECIMAL(10,2),
    IN p_kilometraje INT,
    IN p_id_modelo VARCHAR(10),
    IN p_id_seguro VARCHAR(10),
    IN p_descripcion TEXT,
    IN p_imagen_principal VARCHAR(255)
)
BEGIN
    INSERT INTO Vehiculo (placa, color, año, precio_dia, estado, kilometraje, 
                          id_modelo, id_seguro, descripcion, imagen_principal,
                          es_afiliado, destacado)
    VALUES (p_placa, p_color, p_año, p_precio_dia, 'Disponible', p_kilometraje,
            p_id_modelo, p_id_seguro, p_descripcion, p_imagen_principal,
            FALSE, FALSE);
    
    SELECT 'Vehículo registrado exitosamente' AS mensaje, p_placa AS placa;
END//
DELIMITER ;


-- ============================================
-- PROCEDIMIENTO: Agregar extra a reserva
-- ============================================
DELIMITER //
CREATE PROCEDURE P_AgregarExtraReserva(
    IN p_id_reserva INT,
    IN p_id_extra INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_dias INT;
    
    -- Obtener precio del extra
    SELECT precio_dia INTO v_precio_unitario FROM Extras WHERE id_extra = p_id_extra;
    
    -- Obtener días de la reserva
    SELECT dias_alquiler INTO v_dias FROM Reservas WHERE id_reserva = p_id_reserva;
    
    -- Calcular subtotal (precio por día * cantidad * días de alquiler)
    SET v_subtotal = v_precio_unitario * p_cantidad * v_dias;
    
    -- Insertar extra
    INSERT INTO Reserva_Extras (id_reserva, id_extra, cantidad, precio_unitario, subtotal)
    VALUES (p_id_reserva, p_id_extra, p_cantidad, v_precio_unitario, v_subtotal);
    
    -- Actualizar total de la reserva
    UPDATE Reservas 
    SET total = total + v_subtotal
    WHERE id_reserva = p_id_reserva;
    
    SELECT 'Extra agregado exitosamente' AS mensaje, v_subtotal AS costo_adicional;
END//
DELIMITER ;


-- ============================================
-- PROCEDIMIENTO: Procesar solicitud de afiliación
-- ============================================
DELIMITER //
CREATE PROCEDURE P_ProcesarAfiliacion(
    IN p_id_solicitud INT,
    IN p_aprobado BOOLEAN,
    IN p_comentario TEXT
)
BEGIN
    DECLARE v_placa VARCHAR(10);
    DECLARE v_id_usuario INT;
    DECLARE v_color VARCHAR(30);
    DECLARE v_año YEAR;
    DECLARE v_precio_dia DECIMAL(10,2);
    DECLARE v_id_modelo VARCHAR(10);
    
    IF p_aprobado = TRUE THEN
        -- Obtener datos de la solicitud
        SELECT placa, id_usuario, color, año, precio_sugerido
        INTO v_placa, v_id_usuario, v_color, v_año, v_precio_dia
        FROM Solicitudes_Afiliacion
        WHERE id_solicitud = p_id_solicitud;
        
        -- Buscar o crear modelo (simplificado, asume que ya existe)
        -- En producción, esto sería más complejo
        
        -- Actualizar estado de la solicitud
        UPDATE Solicitudes_Afiliacion
        SET estado_solicitud = 'Aprobada',
            comentario_admin = p_comentario,
            fecha_respuesta = NOW()
        WHERE id_solicitud = p_id_solicitud;
        
        -- Actualizar rol del usuario
        UPDATE Usuarios SET id_rol = 4 WHERE id_usuario = v_id_usuario;
        
        -- Crear notificación
        INSERT INTO Notificaciones (id_usuario, tipo_notificacion, titulo, mensaje)
        VALUES (v_id_usuario, 'Sistema', 'Afiliación Aprobada', 
                CONCAT('Su solicitud de afiliación para el vehículo ', v_placa, ' ha sido aprobada.'));
        
        SELECT 'Afiliación aprobada exitosamente' AS mensaje;
    ELSE
        -- Rechazar solicitud
        UPDATE Solicitudes_Afiliacion
        SET estado_solicitud = 'Rechazada',
            comentario_admin = p_comentario,
            fecha_respuesta = NOW()
        WHERE id_solicitud = p_id_solicitud;
        
        SELECT 'Solicitud rechazada' AS mensaje;
    END IF;
END//
DELIMITER ;


/*-+-----------------------------+
   |         FUNCIONES           |
   +-----------------------------+*/

-- ============================================
-- FUNCIÓN: Calcular ingreso total del sistema
-- ============================================
DELIMITER //
CREATE FUNCTION F_IngresoTotal()
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE ingreso DECIMAL(10,2);
    SELECT IFNULL(SUM(total), 0) INTO ingreso 
    FROM Reservas 
    WHERE estado IN ('Finalizada', 'Activa', 'Confirmada');
    RETURN ingreso;
END//
DELIMITER ;

SELECT F_IngresoTotal() AS ingreso_total_sistema;


-- ============================================
-- FUNCIÓN: Contar vehículos disponibles
-- ============================================
DELIMITER //
CREATE FUNCTION F_VehiculosDisponibles()
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(*) INTO cantidad FROM Vehiculo WHERE estado = 'Disponible';
    RETURN cantidad;
END//
DELIMITER ;

SELECT F_VehiculosDisponibles() AS vehiculos_disponibles;


-- ============================================
-- FUNCIÓN: Calcular puntos de un usuario
-- ============================================
DELIMITER //
CREATE FUNCTION F_PuntosUsuario(p_id_usuario INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE puntos INT;
    SELECT puntos_acumulados INTO puntos FROM Usuarios WHERE id_usuario = p_id_usuario;
    RETURN IFNULL(puntos, 0);
END//
DELIMITER ;

SELECT F_PuntosUsuario(2) AS puntos_cliente;


-- ============================================
-- FUNCIÓN: Calcular días hasta próximo mantenimiento
-- ============================================
DELIMITER //
CREATE FUNCTION F_DiasProximoMantenimiento(p_placa VARCHAR(10))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE dias INT;
    SELECT DATEDIFF(proximo_mantenimiento_fecha, CURDATE()) INTO dias
    FROM Mantenimiento
    WHERE placa = p_placa
    ORDER BY fecha_mantenimiento DESC
    LIMIT 1;
    RETURN IFNULL(dias, 999);
END//
DELIMITER ;

SELECT F_DiasProximoMantenimiento('ABC123') AS dias_para_mantenimiento;


-- ============================================
-- FUNCIÓN: Calcular precio con descuento
-- ============================================
DELIMITER //
CREATE FUNCTION F_CalcularPrecioConDescuento(
    p_precio_base DECIMAL(10,2),
    p_descuento_porcentaje DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_precio_base * (1 - p_descuento_porcentaje / 100);
END//
DELIMITER ;

SELECT F_CalcularPrecioConDescuento(180000, 15) AS precio_con_descuento;


-- ============================================
-- FUNCIÓN: Verificar disponibilidad de vehículo
-- ============================================
DELIMITER //
CREATE FUNCTION F_VehiculoDisponible(
    p_placa VARCHAR(10),
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE disponible BOOLEAN;
    DECLARE reservas_conflicto INT;
    
    -- Verificar si hay reservas en el rango de fechas
    SELECT COUNT(*) INTO reservas_conflicto
    FROM Reservas
    WHERE placa = p_placa
        AND estado IN ('Confirmada', 'Activa')
        AND (
            (fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin)
            OR (fecha_fin BETWEEN p_fecha_inicio AND p_fecha_fin)
            OR (p_fecha_inicio BETWEEN fecha_inicio AND fecha_fin)
        );
    
    IF reservas_conflicto > 0 THEN
        SET disponible = FALSE;
    ELSE
        SET disponible = TRUE;
    END IF;
    
    RETURN disponible;
END//
DELIMITER ;

SELECT F_VehiculoDisponible('ABC123', '2025-12-01', '2025-12-05') AS esta_disponible;


/*-+-----------------------------+
   |        DISPARADORES         |
   +-----------------------------+*/


-- ============================================
-- TRIGGER: Auditar actualizaciones de vehículos
-- ============================================
DELIMITER //
CREATE TRIGGER T_AuditarVehiculo
AFTER UPDATE ON Vehiculo
FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado THEN
        INSERT INTO Auditoria_Vehiculo (placa, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.placa, 'estado', OLD.estado, NEW.estado, CURRENT_USER(), 'UPDATE');
    END IF;
    
    IF OLD.precio_dia != NEW.precio_dia THEN
        INSERT INTO Auditoria_Vehiculo (placa, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.placa, 'precio_dia', OLD.precio_dia, NEW.precio_dia, CURRENT_USER(), 'UPDATE');
    END IF;
    
    IF OLD.kilometraje != NEW.kilometraje THEN
        INSERT INTO Auditoria_Vehiculo (placa, campo_modificado, valor_anterior, valor_nuevo, usuario, tipo_operacion)
        VALUES (NEW.placa, 'kilometraje', OLD.kilometraje, NEW.kilometraje, CURRENT_USER(), 'UPDATE');
    END IF;
END//
DELIMITER ;


-- ============================================
-- TRIGGER: Actualizar calificación promedio al insertar reseña
-- ============================================
DELIMITER //
CREATE TRIGGER T_ActualizarCalificacion
AFTER INSERT ON Reseñas
FOR EACH ROW
BEGIN
    DECLARE promedio DECIMAL(3,2);
    DECLARE total_reseñas INT;
    
    SELECT AVG(calificacion), COUNT(*)
    INTO promedio, total_reseñas
    FROM Reseñas
    WHERE placa = NEW.placa;
    
    UPDATE Vehiculo
    SET calificacion_promedio = promedio,
        numero_reseñas = total_reseñas
    WHERE placa = NEW.placa;
END//
DELIMITER ;


-- ============================================
-- TRIGGER: Generar factura automáticamente al confirmar pago
-- ============================================
DELIMITER //
CREATE TRIGGER T_GenerarFactura
AFTER UPDATE ON Pagos
FOR EACH ROW
BEGIN
    DECLARE v_existe_factura INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(10,2);
    DECLARE v_iva DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_numero_factura VARCHAR(20);
    DECLARE v_iva_porcentaje DECIMAL(5,2);
    
    IF NEW.estado_pago = 'Confirmado' AND OLD.estado_pago != 'Confirmado' THEN
        -- Verificar si ya existe factura
        SELECT COUNT(*) INTO v_existe_factura
        FROM Facturas
        WHERE id_reserva = NEW.id_reserva;
        
        IF v_existe_factura = 0 THEN
            -- Obtener datos de la reserva
            SELECT subtotal, descuento, total
            INTO v_subtotal, v_descuento, v_total
            FROM Reservas
            WHERE id_reserva = NEW.id_reserva;
            
            -- Obtener porcentaje de IVA
            SELECT CAST(valor AS DECIMAL(5,2)) INTO v_iva_porcentaje
            FROM Configuracion_Sistema
            WHERE clave = 'iva_porcentaje';
            
            -- Calcular IVA
            SET v_iva = v_subtotal * (v_iva_porcentaje / 100);
            
            -- Generar número de factura
            SET v_numero_factura = CONCAT('FAC-', YEAR(CURDATE()), '-', LPAD(NEW.id_reserva, 6, '0'));
            
            -- Insertar factura
            INSERT INTO Facturas (id_reserva, numero_factura, fecha_emision, subtotal, iva, descuentos, total_pagar)
            VALUES (NEW.id_reserva, v_numero_factura, CURDATE(), v_subtotal, v_iva, v_descuento, v_total + v_iva);
        END IF;
    END IF;
END//
DELIMITER ;


-- ============================================
-- TRIGGER: Actualizar kilometraje al finalizar reserva
-- ============================================
DELIMITER //
CREATE TRIGGER T_ActualizarKilometraje
AFTER UPDATE ON Reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Finalizada' AND OLD.estado != 'Finalizada' THEN
        -- Incrementar kilometraje estimado (500 km por semana aproximadamente)
        UPDATE Vehiculo
        SET kilometraje = kilometraje + (NEW.dias_alquiler * 70)
        WHERE placa = NEW.placa;
    END IF;
END//
DELIMITER ;


-- ============================================
-- TRIGGER: Alerta de mantenimiento
-- ============================================
DELIMITER //
CREATE TRIGGER T_AlertaMantenimiento
AFTER UPDATE ON Vehiculo
FOR EACH ROW
BEGIN
    DECLARE v_km_preventivo INT;
    
    IF NEW.kilometraje != OLD.kilometraje THEN
        -- Obtener configuración
        SELECT CAST(valor AS UNSIGNED) INTO v_km_preventivo
        FROM Configuracion_Sistema
        WHERE clave = 'mantenimiento_km_preventivo';
        
        -- Si el kilometraje supera el límite, crear notificación
        IF MOD(NEW.kilometraje, v_km_preventivo) < MOD(OLD.kilometraje, v_km_preventivo) THEN
            INSERT INTO Notificaciones (id_usuario, tipo_notificacion, titulo, mensaje)
            SELECT 1, 'Mantenimiento', 'Alerta de Mantenimiento',
                   CONCAT('El vehículo ', NEW.placa, ' requiere mantenimiento. Kilometraje: ', NEW.kilometraje)
            FROM Usuarios WHERE id_rol = 1 LIMIT 1;
        END IF;
    END IF;
END//
DELIMITER ;


-- ============================================
-- TRIGGER: Notificar usuario al crear reserva
-- ============================================
DELIMITER //
CREATE TRIGGER T_NotificarReserva
AFTER INSERT ON Reservas
FOR EACH ROW
BEGIN
    INSERT INTO Notificaciones (id_usuario, tipo_notificacion, titulo, mensaje)
    VALUES (NEW.id_usuario, 'Reserva', 'Nueva Reserva Creada',
            CONCAT('Su reserva #', NEW.id_reserva, ' ha sido creada exitosamente. Total: $', FORMAT(NEW.total, 0)));
END//
DELIMITER ;

/*-+-----------------------------+
   |    CONSULTAS DE REPORTES    |
   +-----------------------------+*/

-- ============================================
-- REPORTE: Ingresos mensuales del año actual
-- ============================================
SELECT 
    MONTH(r.fecha_inicio) AS mes,
    MONTHNAME(r.fecha_inicio) AS nombre_mes,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.dias_alquiler) AS dias_alquilados,
    SUM(r.subtotal) AS subtotal,
    SUM(r.descuento) AS descuentos,
    SUM(r.total) AS ingresos_netos
FROM Reservas r
WHERE YEAR(r.fecha_inicio) = YEAR(CURDATE())
    AND r.estado IN ('Confirmada', 'Activa', 'Finalizada')
GROUP BY MONTH(r.fecha_inicio), MONTHNAME(r.fecha_inicio)
ORDER BY mes;


-- ============================================
-- REPORTE: Vehículos con bajo rendimiento
-- ============================================
SELECT 
    v.placa,
    m.nombre_modelo,
    ma.nombre_marca,
    v.estado,
    v.precio_dia,
    COUNT(r.id_reserva) AS total_reservas_ultimos_6_meses,
    DATEDIFF(CURDATE(), MAX(r.fecha_fin)) AS dias_sin_alquilar
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
LEFT JOIN Reservas r ON v.placa = r.placa 
    AND r.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    AND r.estado IN ('Confirmada', 'Activa', 'Finalizada')
GROUP BY v.placa, m.nombre_modelo, ma.nombre_marca, v.estado, v.precio_dia
HAVING total_reservas_ultimos_6_meses < 3 OR dias_sin_alquilar > 60
ORDER BY total_reservas_ultimos_6_meses ASC;


-- ============================================
-- REPORTE: Extras más solicitados
-- ============================================
SELECT 
    e.nombre_extra,
    e.precio_dia,
    COUNT(re.id_reserva_extra) AS veces_solicitado,
    SUM(re.cantidad) AS cantidad_total,
    SUM(re.subtotal) AS ingresos_generados,
    AVG(re.subtotal) AS ingreso_promedio
FROM Extras e
LEFT JOIN Reserva_Extras re ON e.id_extra = re.id_extra
GROUP BY e.id_extra, e.nombre_extra, e.precio_dia
ORDER BY veces_solicitado DESC;


-- ============================================
-- REPORTE: Eficiencia de promociones
-- ============================================
SELECT 
    p.nombre_promocion,
    p.codigo_promocional,
    p.descuento_porcentaje,
    p.usos_actuales,
    p.usos_maximos,
    COUNT(r.id_reserva) AS reservas_realizadas,
    SUM(r.descuento) AS descuento_total_otorgado,
    SUM(r.total) AS ingresos_generados,
    SUM(r.total) / p.usos_actuales AS ticket_promedio
FROM Promociones p
LEFT JOIN Reservas r ON p.id_promocion = r.id_promocion
WHERE p.activo = TRUE
GROUP BY p.id_promocion, p.nombre_promocion, p.codigo_promocional, 
         p.descuento_porcentaje, p.usos_actuales, p.usos_maximos
ORDER BY ingresos_generados DESC;


-- ============================================
-- REPORTE: Análisis de temporada alta/baja
-- ============================================
SELECT 
    MONTH(fecha_inicio) AS mes,
    MONTHNAME(fecha_inicio) AS nombre_mes,
    COUNT(*) AS cantidad_reservas,
    SUM(total) AS ingresos,
    AVG(dias_alquiler) AS promedio_dias,
    CASE 
        WHEN COUNT(*) > (SELECT AVG(cant) FROM (
            SELECT COUNT(*) AS cant FROM Reservas 
            WHERE estado IN ('Confirmada', 'Activa', 'Finalizada')
            GROUP BY MONTH(fecha_inicio)
        ) AS subconsulta) THEN 'Alta'
        ELSE 'Baja'
    END AS temporada
FROM Reservas
WHERE estado IN ('Confirmada', 'Activa', 'Finalizada')
GROUP BY MONTH(fecha_inicio), MONTHNAME(fecha_inicio)
ORDER BY cantidad_reservas DESC;


-- ============================================
-- REPORTE: Mantenimientos y costos por vehículo
-- ============================================
SELECT 
    v.placa,
    m.nombre_modelo,
    ma.nombre_marca,
    v.kilometraje,
    COUNT(mt.id_mantenimiento) AS total_mantenimientos,
    SUM(mt.costo) AS costo_total_mantenimiento,
    MAX(mt.fecha_mantenimiento) AS ultimo_mantenimiento,
    MIN(mt.proximo_mantenimiento_fecha) AS proximo_mantenimiento
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
LEFT JOIN Mantenimiento mt ON v.placa = mt.placa
GROUP BY v.placa, m.nombre_modelo, ma.nombre_marca, v.kilometraje
ORDER BY costo_total_mantenimiento DESC;

-- ============================================
-- CONSULTAS ÚTILES
-- ============================================

-- 1. Ver vehículos por categoría
SELECT 
    c.nombre_categoria,
    v.placa,
    m.nombre_modelo,
    ma.nombre_marca,
    v.precio_dia,
    v.estado,
    vc.destacado_en_categoria
FROM Categorias_Contexto c
INNER JOIN Vehiculo_Categoria vc ON c.id_categoria = vc.id_categoria
INNER JOIN Vehiculo v ON vc.placa = v.placa
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
WHERE c.activo = TRUE
ORDER BY c.nombre_categoria, vc.destacado_en_categoria DESC;


-- 2. Ver vehículos de una categoría específica (ej: Bodas)
SELECT 
    v.placa,
    m.nombre_modelo,
    ma.nombre_marca,
    v.color,
    v.año,
    v.precio_dia,
    v.imagen_principal,
    v.calificacion_promedio,
    vc.destacado_en_categoria
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
INNER JOIN Marca ma ON m.id_marca = ma.id_marca
INNER JOIN Vehiculo_Categoria vc ON v.placa = vc.placa
INNER JOIN Categorias_Contexto c ON vc.id_categoria = c.id_categoria
WHERE c.nombre_categoria = 'Bodas y Eventos'
    AND v.estado = 'Disponible'
ORDER BY vc.destacado_en_categoria DESC, v.precio_dia DESC;


-- 3. Ver todas las categorías de un vehículo
SELECT 
    v.placa,
    m.nombre_modelo,
    GROUP_CONCAT(c.nombre_categoria SEPARATOR ', ') AS categorias
FROM Vehiculo v
INNER JOIN Modelo m ON v.id_modelo = m.id_modelo
LEFT JOIN Vehiculo_Categoria vc ON v.placa = vc.placa
LEFT JOIN Categorias_Contexto c ON vc.id_categoria = c.id_categoria
GROUP BY v.placa, m.nombre_modelo;


-- 4. Estadísticas por categoría
SELECT 
    c.nombre_categoria,
    COUNT(DISTINCT vc.placa) AS total_vehiculos,
    COUNT(DISTINCT r.id_reserva) AS total_reservas,
    IFNULL(SUM(r.total), 0) AS ingresos_totales
FROM Categorias_Contexto c
LEFT JOIN Vehiculo_Categoria vc ON c.id_categoria = vc.id_categoria
LEFT JOIN Reservas r ON vc.placa = r.placa AND r.estado IN ('Confirmada', 'Activa', 'Finalizada')
GROUP BY c.id_categoria, c.nombre_categoria
ORDER BY total_reservas DESC;

-- ============================================
-- PROCEDIMIENTO: Asignar vehículo a categoría
-- ============================================

DELIMITER //
CREATE PROCEDURE P_AsignarVehiculoCategoria(
    IN p_placa VARCHAR(10),
    IN p_id_categoria INT,
    IN p_destacado BOOLEAN
)
BEGIN
    -- Verificar si ya existe la asignación
    IF EXISTS (SELECT 1 FROM Vehiculo_Categoria WHERE placa = p_placa AND id_categoria = p_id_categoria) THEN
        -- Actualizar si ya existe
        UPDATE Vehiculo_Categoria 
        SET destacado_en_categoria = p_destacado
        WHERE placa = p_placa AND id_categoria = p_id_categoria;
        
        SELECT 'Asignación actualizada' AS mensaje;
    ELSE
        -- Insertar nueva asignación
        INSERT INTO Vehiculo_Categoria (placa, id_categoria, destacado_en_categoria)
        VALUES (p_placa, p_id_categoria, p_destacado);
        
        SELECT 'Vehículo asignado a categoría exitosamente' AS mensaje;
    END IF;
END//
DELIMITER ;

-- Ejemplo de uso:
-- CALL P_AsignarVehiculoCategoria('ABC123', 1, TRUE);


-- ============================================
-- PROCEDIMIENTO: Quitar vehículo de categoría
-- ============================================

DELIMITER //
CREATE PROCEDURE P_QuitarVehiculoCategoria(
    IN p_placa VARCHAR(10),
    IN p_id_categoria INT
)
BEGIN
    DELETE FROM Vehiculo_Categoria 
    WHERE placa = p_placa AND id_categoria = p_id_categoria;
    
    SELECT 'Vehículo removido de la categoría' AS mensaje;
END//
DELIMITER ;

-- Ejemplo de uso:
-- CALL P_QuitarVehiculoCategoria('ABC123', 1);


-- ============================================
-- FUNCIÓN: Contar vehículos en categoría
-- ============================================

DELIMITER //
CREATE FUNCTION F_ContarVehiculosCategoria(p_id_categoria INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(*) INTO cantidad 
    FROM Vehiculo_Categoria vc
    INNER JOIN Vehiculo v ON vc.placa = v.placa
    WHERE vc.id_categoria = p_id_categoria 
        AND v.estado = 'Disponible';
    RETURN cantidad;
END//
DELIMITER ;


-- FIN DEL SCRIPT