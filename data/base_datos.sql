-- BASE DE DATOS VISIÓN 360 - PLATAFORMA DE MARKETING DIGITAL
-- CREATE DATABASE vision360;
USE vision360;

/*-+-----------------------------+
   |         CREAR TABLAS        |
   +-----------------------------+*/

-- Tabla CLIENTES (Empresas que usan la plataforma)
CREATE TABLE CLIENTES (
    cli_id INT NOT NULL AUTO_INCREMENT,
    cli_nombre_empresa VARCHAR(100) NOT NULL,
    cli_razon_social VARCHAR(150) NOT NULL,
    cli_nit VARCHAR(20) NULL,
    cli_industria ENUM('Tecnología','Retail','Alimentos','Salud','Automotriz','Finanzas','Educación','Entretenimiento','Otro') NOT NULL,
    cli_email_contacto VARCHAR(100) NOT NULL,
    cli_telefono VARCHAR(20) NOT NULL,
    cli_direccion VARCHAR(255) NOT NULL,
    cli_ciudad VARCHAR(50) NOT NULL,
    cli_pais VARCHAR(50) NOT NULL,
    cli_sitio_web VARCHAR(100) NULL,
    cli_fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cli_tipo_plan ENUM('Básico','Profesional','Empresarial','Enterprise') NOT NULL DEFAULT 'Básico',
    cli_estado ENUM('Activo','Suspendido','Inactivo','Prueba') NOT NULL DEFAULT 'Prueba',
    PRIMARY KEY (cli_id),
    UNIQUE KEY (cli_email_contacto),
    INDEX idx_estado (cli_estado),
    INDEX idx_plan (cli_tipo_plan)
) AUTO_INCREMENT=1;

-- Tabla USUARIOS (Usuarios de cada cliente con acceso a la plataforma)
CREATE TABLE USUARIOS (
    usu_id INT NOT NULL AUTO_INCREMENT,
    usu_cli_id INT NOT NULL,
    usu_nombre VARCHAR(50) NOT NULL,
    usu_apellido VARCHAR(50) NOT NULL,
    usu_email VARCHAR(100) NOT NULL,
    usu_password_hash VARCHAR(255) NOT NULL,
    usu_rol ENUM('Administrador','Gerente Marketing','Analista','Visualizador') NOT NULL DEFAULT 'Visualizador',
    usu_telefono VARCHAR(20) NULL,
    usu_fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usu_ultimo_acceso DATETIME NULL,
    usu_estado ENUM('Activo','Inactivo','Bloqueado') NOT NULL DEFAULT 'Activo',
    PRIMARY KEY (usu_id),
    UNIQUE KEY (usu_email),
    CONSTRAINT fk_usu_cli_id FOREIGN KEY (usu_cli_id) REFERENCES CLIENTES(cli_id) ON DELETE CASCADE,
    INDEX idx_cliente (usu_cli_id),
    INDEX idx_email (usu_email)
) AUTO_INCREMENT=1;

-- Tabla PLATAFORMAS_PUBLICITARIAS (Canales de publicidad disponibles)
CREATE TABLE PLATAFORMAS_PUBLICITARIAS (
    pla_id INT NOT NULL AUTO_INCREMENT,
    pla_nombre VARCHAR(50) NOT NULL,
    pla_descripcion TEXT NOT NULL,
    pla_tipo ENUM('Social Media','Search Engine','Display','Video','Email','Native') NOT NULL,
    pla_icono_url VARCHAR(255) NULL,
    pla_api_disponible BOOLEAN NOT NULL DEFAULT TRUE,
    pla_estado ENUM('Activa','Mantenimiento','Descontinuada') NOT NULL DEFAULT 'Activa',
    PRIMARY KEY (pla_id),
    UNIQUE KEY (pla_nombre)
) AUTO_INCREMENT=1;

-- Tabla CUENTAS_PUBLICITARIAS (Cuentas de clientes en cada plataforma)
CREATE TABLE CUENTAS_PUBLICITARIAS (
    cue_id INT NOT NULL AUTO_INCREMENT,
    cue_cli_id INT NOT NULL,
    cue_pla_id INT NOT NULL,
    cue_nombre VARCHAR(100) NOT NULL,
    cue_id_externo VARCHAR(100) NOT NULL COMMENT 'ID de la cuenta en la plataforma externa',
    cue_access_token TEXT NULL COMMENT 'Token de acceso API (encriptado)',
    cue_fecha_vinculacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cue_fecha_ultima_sincronizacion DATETIME NULL,
    cue_estado ENUM('Activa','Desconectada','Error','Pausada') NOT NULL DEFAULT 'Activa',
    PRIMARY KEY (cue_id),
    CONSTRAINT fk_cue_cli_id FOREIGN KEY (cue_cli_id) REFERENCES CLIENTES(cli_id) ON DELETE CASCADE,
    CONSTRAINT fk_cue_pla_id FOREIGN KEY (cue_pla_id) REFERENCES PLATAFORMAS_PUBLICITARIAS(pla_id),
    INDEX idx_cliente (cue_cli_id),
    INDEX idx_plataforma (cue_pla_id)
) AUTO_INCREMENT=1;

-- Tabla CAMPANAS (Campañas publicitarias)
CREATE TABLE CAMPANAS (
    cam_id INT NOT NULL AUTO_INCREMENT,
    cam_cue_id INT NOT NULL,
    cam_nombre VARCHAR(150) NOT NULL,
    cam_objetivo ENUM('Reconocimiento','Consideración','Conversión','Tráfico','Engagement','Instalaciones','Ventas') NOT NULL,
    cam_descripcion TEXT NULL,
    cam_id_externo VARCHAR(100) NULL COMMENT 'ID en la plataforma externa',
    cam_fecha_inicio DATE NOT NULL,
    cam_fecha_fin DATE NULL,
    cam_presupuesto_total DECIMAL(12,2) NOT NULL,
    cam_presupuesto_diario DECIMAL(10,2) NULL,
    cam_moneda VARCHAR(3) NOT NULL DEFAULT 'COP',
    cam_estado ENUM('Borrador','Activa','Pausada','Completada','Cancelada') NOT NULL DEFAULT 'Borrador',
    cam_fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cam_fecha_modificacion DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (cam_id),
    CONSTRAINT fk_cam_cue_id FOREIGN KEY (cam_cue_id) REFERENCES CUENTAS_PUBLICITARIAS(cue_id) ON DELETE CASCADE,
    INDEX idx_cuenta (cam_cue_id),
    INDEX idx_estado (cam_estado),
    INDEX idx_fechas (cam_fecha_inicio, cam_fecha_fin)
) AUTO_INCREMENT=1;

-- Tabla SEGMENTOS_AUDIENCIA (Definición de audiencias objetivo)
CREATE TABLE SEGMENTOS_AUDIENCIA (
    seg_id INT NOT NULL AUTO_INCREMENT,
    seg_cli_id INT NOT NULL,
    seg_nombre VARCHAR(100) NOT NULL,
    seg_descripcion TEXT NULL,
    seg_edad_min INT NULL,
    seg_edad_max INT NULL,
    seg_genero ENUM('Todos','Masculino','Femenino','Otro') NOT NULL DEFAULT 'Todos',
    seg_ubicaciones JSON NULL COMMENT 'Array de países/ciudades',
    seg_intereses JSON NULL COMMENT 'Array de intereses',
    seg_idiomas JSON NULL COMMENT 'Array de idiomas',
    seg_comportamientos JSON NULL COMMENT 'Comportamientos específicos',
    seg_tamano_estimado INT NULL COMMENT 'Número estimado de personas',
    seg_fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (seg_id),
    CONSTRAINT fk_seg_cli_id FOREIGN KEY (seg_cli_id) REFERENCES CLIENTES(cli_id) ON DELETE CASCADE,
    INDEX idx_cliente (seg_cli_id)
) AUTO_INCREMENT=1;

-- Tabla CAMPANAS_SEGMENTOS (Relación muchos a muchos)
CREATE TABLE CAMPANAS_SEGMENTOS (
    cs_id INT NOT NULL AUTO_INCREMENT,
    cs_cam_id INT NOT NULL,
    cs_seg_id INT NOT NULL,
    cs_fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cs_id),
    CONSTRAINT fk_cs_cam_id FOREIGN KEY (cs_cam_id) REFERENCES CAMPANAS(cam_id) ON DELETE CASCADE,
    CONSTRAINT fk_cs_seg_id FOREIGN KEY (cs_seg_id) REFERENCES SEGMENTOS_AUDIENCIA(seg_id) ON DELETE CASCADE,
    UNIQUE KEY unique_campana_segmento (cs_cam_id, cs_seg_id)
) AUTO_INCREMENT=1;

-- Tabla ANUNCIOS (Ads individuales dentro de campañas)
CREATE TABLE ANUNCIOS (
    anu_id INT NOT NULL AUTO_INCREMENT,
    anu_cam_id INT NOT NULL,
    anu_nombre VARCHAR(150) NOT NULL,
    anu_tipo ENUM('Imagen','Video','Carrusel','Historia','Colección','Texto','Shopping') NOT NULL,
    anu_titulo VARCHAR(255) NULL,
    anu_descripcion TEXT NULL,
    anu_url_destino VARCHAR(500) NULL,
    anu_llamada_accion VARCHAR(50) NULL COMMENT 'CTA: Comprar, Registrarse, etc.',
    anu_id_externo VARCHAR(100) NULL,
    anu_estado ENUM('Activo','Pausado','Revisión','Rechazado','Completado') NOT NULL DEFAULT 'Activo',
    anu_fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (anu_id),
    CONSTRAINT fk_anu_cam_id FOREIGN KEY (anu_cam_id) REFERENCES CAMPANAS(cam_id) ON DELETE CASCADE,
    INDEX idx_campana (anu_cam_id),
    INDEX idx_estado (anu_estado)
) AUTO_INCREMENT=1;

-- Tabla RECURSOS_CREATIVOS (Imágenes, videos, etc.)
CREATE TABLE RECURSOS_CREATIVOS (
    rec_id INT NOT NULL AUTO_INCREMENT,
    rec_anu_id INT NOT NULL,
    rec_tipo ENUM('Imagen','Video','Audio','Documento') NOT NULL,
    rec_nombre_archivo VARCHAR(255) NOT NULL,
    rec_url VARCHAR(500) NOT NULL,
    rec_tamano_kb INT NULL,
    rec_dimensiones VARCHAR(20) NULL COMMENT 'Ej: 1200x628',
    rec_duracion_segundos INT NULL COMMENT 'Para videos',
    rec_fecha_subida DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rec_id),
    CONSTRAINT fk_rec_anu_id FOREIGN KEY (rec_anu_id) REFERENCES ANUNCIOS(anu_id) ON DELETE CASCADE,
    INDEX idx_anuncio (rec_anu_id)
) AUTO_INCREMENT=1;

-- Tabla METRICAS_DIARIAS (KPIs y métricas en tiempo real)
CREATE TABLE METRICAS_DIARIAS (
    met_id BIGINT NOT NULL AUTO_INCREMENT,
    met_cam_id INT NOT NULL,
    met_anu_id INT NULL COMMENT 'NULL si es métrica de campaña general',
    met_fecha DATE NOT NULL,
    met_hora TIME NULL COMMENT 'Para métricas horarias',
    -- Métricas de alcance
    met_impresiones INT NOT NULL DEFAULT 0,
    met_alcance INT NOT NULL DEFAULT 0,
    met_frecuencia DECIMAL(5,2) NULL COMMENT 'Promedio de veces que se vio',
    -- Métricas de interacción
    met_clicks INT NOT NULL DEFAULT 0,
    met_ctr DECIMAL(5,2) NULL COMMENT 'Click Through Rate %',
    met_engagement INT NOT NULL DEFAULT 0 COMMENT 'Likes, shares, comments',
    met_shares INT NOT NULL DEFAULT 0,
    met_comentarios INT NOT NULL DEFAULT 0,
    met_guardados INT NOT NULL DEFAULT 0,
    -- Métricas de conversión
    met_conversiones INT NOT NULL DEFAULT 0,
    met_tasa_conversion DECIMAL(5,2) NULL COMMENT 'Conversion Rate %',
    met_valor_conversiones DECIMAL(12,2) NULL,
    -- Métricas de costo
    met_gasto DECIMAL(12,2) NOT NULL DEFAULT 0,
    met_cpc DECIMAL(10,2) NULL COMMENT 'Costo Por Click',
    met_cpm DECIMAL(10,2) NULL COMMENT 'Costo Por Mil Impresiones',
    met_cpa DECIMAL(10,2) NULL COMMENT 'Costo Por Adquisición',
    met_roas DECIMAL(10,2) NULL COMMENT 'Return On Ad Spend',
    -- Métricas de video (si aplica)
    met_reproducciones_video INT NULL,
    met_porcentaje_visualizacion DECIMAL(5,2) NULL,
    -- Timestamp
    met_fecha_sincronizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (met_id),
    CONSTRAINT fk_met_cam_id FOREIGN KEY (met_cam_id) REFERENCES CAMPANAS(cam_id) ON DELETE CASCADE,
    CONSTRAINT fk_met_anu_id FOREIGN KEY (met_anu_id) REFERENCES ANUNCIOS(anu_id) ON DELETE CASCADE,
    INDEX idx_campana_fecha (met_cam_id, met_fecha),
    INDEX idx_anuncio_fecha (met_anu_id, met_fecha),
    INDEX idx_fecha (met_fecha)
) AUTO_INCREMENT=1;

-- Tabla CONVERSIONES (Registro detallado de conversiones)
CREATE TABLE CONVERSIONES (
    con_id BIGINT NOT NULL AUTO_INCREMENT,
    con_cam_id INT NOT NULL,
    con_anu_id INT NULL,
    con_fecha_hora DATETIME NOT NULL,
    con_tipo ENUM('Compra','Registro','Lead','Descarga','Suscripción','Otro') NOT NULL,
    con_valor DECIMAL(12,2) NULL,
    con_id_transaccion VARCHAR(100) NULL,
    con_origen_trafico VARCHAR(100) NULL COMMENT 'UTM o referrer',
    con_dispositivo ENUM('Desktop','Mobile','Tablet') NULL,
    con_ubicacion_geografica VARCHAR(100) NULL,
    PRIMARY KEY (con_id),
    CONSTRAINT fk_con_cam_id FOREIGN KEY (con_cam_id) REFERENCES CAMPANAS(cam_id) ON DELETE CASCADE,
    CONSTRAINT fk_con_anu_id FOREIGN KEY (con_anu_id) REFERENCES ANUNCIOS(anu_id) ON DELETE SET NULL,
    INDEX idx_campana (con_cam_id),
    INDEX idx_fecha (con_fecha_hora),
    INDEX idx_tipo (con_tipo)
) AUTO_INCREMENT=1;

-- Tabla INTEGRACIONES_CRM (Conexión con sistemas CRM y ventas)
CREATE TABLE INTEGRACIONES_CRM (
    int_id INT NOT NULL AUTO_INCREMENT,
    int_cli_id INT NOT NULL,
    int_sistema VARCHAR(50) NOT NULL COMMENT 'Salesforce, HubSpot, Zoho, etc.',
    int_api_key TEXT NULL COMMENT 'Credenciales encriptadas',
    int_webhook_url VARCHAR(500) NULL,
    int_fecha_vinculacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    int_sincronizacion_activa BOOLEAN NOT NULL DEFAULT TRUE,
    int_ultima_sincronizacion DATETIME NULL,
    int_estado ENUM('Activa','Pausada','Error') NOT NULL DEFAULT 'Activa',
    PRIMARY KEY (int_id),
    CONSTRAINT fk_int_cli_id FOREIGN KEY (int_cli_id) REFERENCES CLIENTES(cli_id) ON DELETE CASCADE,
    INDEX idx_cliente (int_cli_id)
) AUTO_INCREMENT=1;

-- Tabla REPORTES_PERSONALIZADOS (Plantillas de reportes configurables)
CREATE TABLE REPORTES_PERSONALIZADOS (
    rep_id INT NOT NULL AUTO_INCREMENT,
    rep_cli_id INT NOT NULL,
    rep_nombre VARCHAR(100) NOT NULL,
    rep_descripcion TEXT NULL,
    rep_tipo ENUM('Diario','Semanal','Mensual','Personalizado') NOT NULL,
    rep_metricas_incluidas JSON NOT NULL COMMENT 'Array de métricas a incluir',
    rep_filtros JSON NULL COMMENT 'Filtros aplicados',
    rep_formato ENUM('PDF','Excel','CSV','Web') NOT NULL DEFAULT 'PDF',
    rep_envio_automatico BOOLEAN NOT NULL DEFAULT FALSE,
    rep_destinatarios_email JSON NULL COMMENT 'Emails para envío automático',
    rep_fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rep_estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo',
    PRIMARY KEY (rep_id),
    CONSTRAINT fk_rep_cli_id FOREIGN KEY (rep_cli_id) REFERENCES CLIENTES(cli_id) ON DELETE CASCADE,
    INDEX idx_cliente (rep_cli_id)
) AUTO_INCREMENT=1;

-- Tabla ALERTAS (Sistema de notificaciones automáticas)
CREATE TABLE ALERTAS (
    ale_id INT NOT NULL AUTO_INCREMENT,
    ale_cli_id INT NOT NULL,
    ale_nombre VARCHAR(100) NOT NULL,
    ale_tipo ENUM('Presupuesto','Rendimiento','Conversión','Pausa_Campaña','Error_API') NOT NULL,
    ale_condicion JSON NOT NULL COMMENT 'Condiciones que disparan la alerta',
    ale_destinatarios JSON NOT NULL COMMENT 'Usuarios a notificar',
    ale_metodo ENUM('Email','SMS','Push','In-App') NOT NULL DEFAULT 'Email',
    ale_activa BOOLEAN NOT NULL DEFAULT TRUE,
    ale_fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ale_id),
    CONSTRAINT fk_ale_cli_id FOREIGN KEY (ale_cli_id) REFERENCES CLIENTES(cli_id) ON DELETE CASCADE,
    INDEX idx_cliente (ale_cli_id)
) AUTO_INCREMENT=1;

-- Tabla HISTORIAL_ALERTAS (Registro de alertas disparadas)
CREATE TABLE HISTORIAL_ALERTAS (
    hal_id BIGINT NOT NULL AUTO_INCREMENT,
    hal_ale_id INT NOT NULL,
    hal_fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hal_mensaje TEXT NOT NULL,
    hal_datos_adicionales JSON NULL,
    hal_leida BOOLEAN NOT NULL DEFAULT FALSE,
    hal_fecha_lectura DATETIME NULL,
    PRIMARY KEY (hal_id),
    CONSTRAINT fk_hal_ale_id FOREIGN KEY (hal_ale_id) REFERENCES ALERTAS(ale_id) ON DELETE CASCADE,
    INDEX idx_alerta (hal_ale_id),
    INDEX idx_fecha (hal_fecha_hora)
) AUTO_INCREMENT=1;

-- Tabla AUDITORIA (Log de acciones en el sistema)
CREATE TABLE AUDITORIA (
    aud_id BIGINT NOT NULL AUTO_INCREMENT,
    aud_usu_id INT NOT NULL,
    aud_accion VARCHAR(50) NOT NULL COMMENT 'CREATE, UPDATE, DELETE, LOGIN',
    aud_entidad VARCHAR(50) NOT NULL COMMENT 'Tabla afectada',
    aud_entidad_id INT NOT NULL,
    aud_valores_anteriores JSON NULL,
    aud_valores_nuevos JSON NULL,
    aud_ip VARCHAR(45) NULL,
    aud_fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (aud_id),
    CONSTRAINT fk_aud_usu_id FOREIGN KEY (aud_usu_id) REFERENCES USUARIOS(usu_id) ON DELETE CASCADE,
    INDEX idx_usuario (aud_usu_id),
    INDEX idx_fecha (aud_fecha_hora),
    INDEX idx_entidad (aud_entidad, aud_entidad_id)
) AUTO_INCREMENT=1;

/*-+-----------------------------+
   |      INSERTAR DATOS         |
   +-----------------------------+*/

-- CLIENTES
INSERT INTO CLIENTES (cli_nombre_empresa, cli_razon_social, cli_nit, cli_industria, cli_email_contacto, cli_telefono, cli_direccion, cli_ciudad, cli_pais, cli_sitio_web, cli_tipo_plan, cli_estado)
VALUES 
('Tech Solutions', 'Tech Solutions S.A.S.', '900123456-1', 'Tecnología', 'contacto@techsolutions.com', '3101234567', 'Calle 50 #25-30', 'Bogotá', 'Colombia', 'www.techsolutions.com', 'Empresarial', 'Activo'),
('Fashion Retail', 'Fashion Retail LTDA', '900234567-2', 'Retail', 'marketing@fashionretail.com', '3209876543', 'Carrera 15 #80-45', 'Medellín', 'Colombia', 'www.fashionretail.com', 'Profesional', 'Activo'),
('Food Express', 'Food Express Colombia S.A.S.', '900345678-3', 'Alimentos', 'digital@foodexpress.com', '3156789012', 'Avenida 68 #100-20', 'Cali', 'Colombia', 'www.foodexpress.com', 'Básico', 'Prueba'),
('Healthy Life', 'Healthy Life Wellness', '900456789-4', 'Salud', 'info@healthylife.com', '3187654321', 'Calle 100 #15-30', 'Barranquilla', 'Colombia', 'www.healthylife.com', 'Empresarial', 'Activo');

-- USUARIOS
INSERT INTO USUARIOS (usu_cli_id, usu_nombre, usu_apellido, usu_email, usu_password_hash, usu_rol, usu_telefono)
VALUES 
(1, 'Carlos', 'Mendoza', 'carlos.mendoza@techsolutions.com', '$2y$10$abcdefghijklmnopqrstuvwxyz', 'Administrador', '3101234567'),
(1, 'Ana', 'García', 'ana.garcia@techsolutions.com', '$2y$10$abcdefghijklmnopqrstuvwxyz', 'Gerente Marketing', '3102345678'),
(2, 'María', 'González', 'maria.gonzalez@fashionretail.com', '$2y$10$abcdefghijklmnopqrstuvwxyz', 'Administrador', '3209876543'),
(2, 'Luis', 'Rodríguez', 'luis.rodriguez@fashionretail.com', '$2y$10$abcdefghijklmnopqrstuvwxyz', 'Analista', '3201234567'),
(4, 'Ana', 'Torres', 'ana.torres@healthylife.com', '$2y$10$abcdefghijklmnopqrstuvwxyz', 'Administrador', '3187654321');

-- PLATAFORMAS_PUBLICITARIAS
INSERT INTO PLATAFORMAS_PUBLICITARIAS (pla_nombre, pla_descripcion, pla_tipo, pla_api_disponible)
VALUES 
('Google Ads', 'Plataforma de publicidad de Google para búsquedas y display', 'Search Engine', TRUE),
('Facebook Ads', 'Publicidad en Facebook e Instagram', 'Social Media', TRUE),
('TikTok Ads', 'Plataforma publicitaria de TikTok', 'Social Media', TRUE),
('LinkedIn Ads', 'Publicidad profesional en LinkedIn', 'Social Media', TRUE),
('Twitter Ads', 'Campañas publicitarias en Twitter/X', 'Social Media', TRUE),
('YouTube Ads', 'Publicidad en video en YouTube', 'Video', TRUE),
('Microsoft Advertising', 'Publicidad en Bing y red de partners', 'Search Engine', TRUE),
('Pinterest Ads', 'Publicidad visual en Pinterest', 'Social Media', TRUE);

-- CUENTAS_PUBLICITARIAS
INSERT INTO CUENTAS_PUBLICITARIAS (cue_cli_id, cue_pla_id, cue_nombre, cue_id_externo, cue_fecha_ultima_sincronizacion, cue_estado)
VALUES 
(1, 1, 'Tech Solutions - Google Ads Principal', 'GA-123-456-789', NOW(), 'Activa'),
(1, 2, 'Tech Solutions - Facebook Business', 'FB-987654321', NOW(), 'Activa'),
(1, 3, 'Tech Solutions - TikTok Business', 'TT-456789123', NOW(), 'Activa'),
(2, 2, 'Fashion Retail - Facebook Ads', 'FB-111222333', NOW(), 'Activa'),
(2, 4, 'Fashion Retail - LinkedIn', 'LI-444555666', NOW(), 'Activa'),
(4, 1, 'Healthy Life - Google Ads', 'GA-777-888-999', NOW(), 'Activa'),
(4, 2, 'Healthy Life - Facebook e Instagram', 'FB-999888777', NOW(), 'Activa');

-- SEGMENTOS_AUDIENCIA
INSERT INTO SEGMENTOS_AUDIENCIA (seg_cli_id, seg_nombre, seg_descripcion, seg_edad_min, seg_edad_max, seg_genero, seg_ubicaciones, seg_intereses, seg_tamano_estimado)
VALUES 
(1, 'Profesionales Tech Colombia', 'Profesionales interesados en tecnología', 25, 45, 'Todos', 
 '["Colombia", "Bogotá", "Medellín"]', '["Tecnología", "Software", "Innovación"]', 250000),
(1, 'Empresarios Jóvenes', 'Emprendedores y dueños de negocios', 28, 40, 'Todos', 
 '["Colombia", "Perú", "Chile"]', '["Negocios", "Emprendimiento", "Tecnología"]', 180000),
(2, 'Mujeres Fashion 18-35', 'Mujeres interesadas en moda', 18, 35, 'Femenino', 
 '["Colombia", "Venezuela", "Ecuador"]', '["Moda", "Belleza", "Lifestyle"]', 450000),
(4, 'Wellness Enthusiasts', 'Personas interesadas en vida saludable', 25, 55, 'Todos', 
 '["Colombia"]', '["Salud", "Fitness", "Nutrición", "Bienestar"]', 320000);

-- CAMPANAS
INSERT INTO CAMPANAS (cam_cue_id, cam_nombre, cam_objetivo, cam_descripcion, cam_id_externo, cam_fecha_inicio, cam_fecha_fin, cam_presupuesto_total, cam_presupuesto_diario, cam_estado)
VALUES 
(1, 'Lanzamiento Producto Q4 2024', 'Conversión', 'Campaña de lanzamiento de nueva línea de software empresarial', 'CAMP-001-2024', '2024-10-01', '2024-12-31', 15000000.00, 150000.00, 'Activa'),
(2, 'Engagement Facebook Tech Solutions', 'Engagement', 'Generar interacción con contenido tech', 'CAMP-002-2024', '2024-09-15', '2024-11-30', 8000000.00, 100000.00, 'Activa'),
(3, 'TikTok Brand Awareness', 'Reconocimiento', 'Aumentar conocimiento de marca en audiencia joven', 'CAMP-003-2024', '2024-10-15', '2024-12-15', 5000000.00, 80000.00, 'Activa'),
(4, 'Fashion Week Colombia', 'Tráfico', 'Dirigir tráfico a tienda online durante Fashion Week', 'CAMP-004-2024', '2024-11-01', '2024-11-15', 6000000.00, 400000.00, 'Activa'),
(6, 'Google Search - Vida Saludable', 'Conversión', 'Captar leads interesados en programas wellness', 'CAMP-005-2024', '2024-10-01', '2024-12-31', 10000000.00, 110000.00, 'Activa');

-- CAMPANAS_SEGMENTOS
INSERT INTO CAMPANAS_SEGMENTOS (cs_cam_id, cs_seg_id)
VALUES 
(1, 1), (1, 2),
(2, 1),
(3, 2),
(4, 3),
(5, 4);

-- ANUNCIOS
INSERT INTO ANUNCIOS (anu_cam_id, anu_nombre, anu_tipo, anu_titulo, anu_descripcion, anu_url_destino, anu_llamada_accion, anu_id_externo, anu_estado)
VALUES 
(1, 'Anuncio Principal Software', 'Imagen', 'Transforma tu negocio con nuestra solución', 'Software empresarial que aumenta productividad en 40%', 'https://techsolutions.com/producto', 'Solicitar Demo', 'AD-001', 'Activo'),
(1, 'Video Demo Producto', 'Video', 'Mira cómo funciona', 'Demo de 30 segundos mostrando características principales', 'https://techsolutions.com/demo', 'Ver Demo', 'AD-002', 'Activo'),
(2, 'Post Interactivo Tech', 'Imagen', '¿Sabías que...?', 'Datos interesantes sobre transformación digital', 'https://techsolutions.com/blog', 'Leer Más', 'AD-003', 'Activo'),
(4, 'Carrusel Nuevas Colecciones', 'Carrusel', 'Nueva Colección Otoño', 'Descubre las tendencias de la temporada', 'https://fashionretail.com/coleccion', 'Comprar Ahora', 'AD-004', 'Activo'),
(5, 'Programa Wellness 21 Días', 'Imagen', 'Cambia tu vida en 21 días', 'Programa integral de bienestar con resultados garantizados', 'https://healthylife.com/programa', 'Inscribirse', 'AD-005', 'Activo');

-- METRICAS_DIARIAS (Últimos 7 días de ejemplo)
INSERT INTO METRICAS_DIARIAS (met_cam_id, met_anu_id, met_fecha, met_impresiones, met_alcance, met_frecuencia, met_clicks, met_ctr, met_engagement, met_conversiones, met_tasa_conversion, met_valor_conversiones, met_gasto, met_cpc, met_cpm, met_cpa, met_roas)
VALUES 
-- Campaña 1 - Últimos 7 días
(1, 1, '2024-11-02', 45000, 32000, 1.41, 1250, 2.78, 450, 32, 2.56, 9600000.00, 425000.00, 340.00, 9444.44, 13281.25, 22.59),
(1, 1, '2024-11-03', 48000, 35000, 1.37, 1320, 2.75, 480, 35, 2.65, 10500000.00, 430000.00, 325.76, 8958.33, 12285.71, 24.42),
(1, 1, '2024-11-04', 52000, 38000, 1.37, 1450, 2.79, 520, 38, 2.62, 11400000.00, 445000.00, 306.90, 8557.69, 11710.53, 25.62),
(1, 2, '2024-11-02', 38000, 28000, 1.36, 980, 2.58, 650, 28, 2.86, 8400000.00, 380000.00, 387.76, 10000.00, 13571.43, 22.11),
(1, 2, '2024-11-03', 41000, 30000, 1.37, 1050, 2.56, 700, 30, 2.86, 9000000.00, 390000.00, 371.43, 9512.20, 13000.00, 23.08),
-- Campaña 2
(2, 3, '2024-11-02', 65000, 48000, 1.35, 1800, 2.77, 2850, 0, 0.00, 0.00, 285000.00, 158.33, 4384.62, 0.00, 0.00),
(2, 3, '2024-11-03', 68000, 50000, 1.36, 1900, 2.79, 3100, 0, 0.00, 0.00, 295000.00, 155.26, 4338.24, 0.00, 0.00),
(2, 3, '2024-11-04', 72000, 53000, 1.36, 2050, 2.85, 3350, 0, 0.00, 0.00, 305000.00, 148.78, 4236.11, 0.00, 0.00),
-- Campaña 4
(4, 4, '2024-11-02', 85000, 62000, 1.37, 2850, 3.35, 1250, 95, 3.33, 47500000.00, 480000.00, 168.42, 5647.06, 5052.63, 98.96),
(4, 4, '2024-11-03', 88000, 65000, 1.35, 3100, 3.52, 1400, 105, 3.39, 52500000.00, 495000.00, 159.68, 5625.00, 4714.29, 106.06),
(4, 4, '2024-11-04', 92000, 68000, 1.35, 3250, 3.53, 1580, 112, 3.45, 56000000.00, 510000.00, 156.92, 5543.48, 4553.57, 109.80),
-- Campaña 5
(5, 5, '2024-11-02', 35000, 26000, 1.35, 1150, 3.29, 280, 48, 4.17, 14400000.00, 320000.00, 278.26, 9142.86, 6666.67, 45.00),
(5, 5, '2024-11-03', 38000, 28000, 1.36, 1250, 3.29, 310, 52, 4.16, 15600000.00, 335000.00, 268.00, 8815.79, 6442.31, 46.57),
(5, 5, '2024-11-04', 40000, 30000, 1.33, 1350, 3.38, 340, 56, 4.15, 16800000.00, 345000.00, 255.56, 8625.00, 6160.71, 48.70);

-- CONVERSIONES (Registros detallados)
INSERT INTO CONVERSIONES (con_cam_id, con_anu_id, con_fecha_hora, con_tipo, con_valor, con_id_transaccion, con_origen_trafico, con_dispositivo, con_ubicacion_geografica)
VALUES 
(1, 1, '2024-11-04 10:25:30', 'Lead', 300000.00, 'TXN-001-2024', 'google_ads_search', 'Desktop', 'Bogotá, Colombia'),
(1, 1, '2024-11-04 14:35:15', 'Lead', 300000.00, 'TXN-002-2024', 'google_ads_display', 'Mobile', 'Medellín, Colombia'),
(1, 2, '2024-11-04 16:42:10', 'Lead', 300000.00, 'TXN-003-2024', 'youtube_video', 'Desktop', 'Bogotá, Colombia'),
(4, 4, '2024-11-04 11:15:22', 'Compra', 450000.00, 'TXN-004-2024', 'facebook_feed', 'Mobile', 'Cali, Colombia'),
(4, 4, '2024-11-04 13:28:45', 'Compra', 680000.00, 'TXN-005-2024', 'instagram_stories', 'Mobile', 'Barranquilla, Colombia'),
(4, 4, '2024-11-04 15:50:12', 'Compra', 520000.00, 'TXN-006-2024', 'facebook_feed', 'Desktop', 'Bogotá, Colombia'),
(5, 5, '2024-11-04 09:30:00', 'Registro', 300000.00, 'TXN-007-2024', 'google_search', 'Desktop', 'Bogotá, Colombia'),
(5, 5, '2024-11-04 17:20:30', 'Registro', 300000.00, 'TXN-008-2024', 'google_search', 'Mobile', 'Medellín, Colombia');

-- INTEGRACIONES_CRM
INSERT INTO INTEGRACIONES_CRM (int_cli_id, int_sistema, int_webhook_url, int_ultima_sincronizacion, int_estado)
VALUES 
(1, 'Salesforce', 'https://techsolutions.webhook.salesforce.com', NOW(), 'Activa'),
(1, 'HubSpot', 'https://api.hubspot.com/webhooks/techsolutions', NOW(), 'Activa'),
(2, 'Zoho CRM', 'https://crm.zoho.com/webhook/fashionretail', NOW(), 'Activa'),
(4, 'HubSpot', 'https://api.hubspot.com/webhooks/healthylife', NOW(), 'Activa');

-- REPORTES_PERSONALIZADOS
INSERT INTO REPORTES_PERSONALIZADOS (rep_cli_id, rep_nombre, rep_descripcion, rep_tipo, rep_metricas_incluidas, rep_filtros, rep_formato, rep_envio_automatico, rep_destinatarios_email)
VALUES 
(1, 'Reporte Semanal Ejecutivo', 'Resumen de KPIs principales para gerencia', 'Semanal', 
 '["impresiones", "clicks", "conversiones", "gasto", "roas"]', 
 '{"campañas": ["todas"], "periodo": "ultima_semana"}', 
 'PDF', TRUE, '["carlos.mendoza@techsolutions.com", "ana.garcia@techsolutions.com"]'),
(1, 'Dashboard Diario Performance', 'Métricas diarias detalladas por campaña', 'Diario', 
 '["impresiones", "alcance", "clicks", "ctr", "conversiones", "cpa", "gasto"]', 
 '{"campañas": ["todas"], "periodo": "ayer"}', 
 'Excel', TRUE, '["ana.garcia@techsolutions.com"]'),
(2, 'Análisis Mensual ROI', 'Análisis completo de retorno de inversión', 'Mensual', 
 '["gasto", "ingresos", "conversiones", "roas", "cpa"]', 
 '{"campañas": ["todas"], "periodo": "ultimo_mes"}', 
 'PDF', TRUE, '["maria.gonzalez@fashionretail.com"]'),
(4, 'Reporte Leads Wellness', 'Seguimiento de leads generados', 'Semanal', 
 '["conversiones", "cpa", "tasa_conversion", "valor_conversiones"]', 
 '{"tipo_conversion": "Lead", "periodo": "ultima_semana"}', 
 'Excel', TRUE, '["ana.torres@healthylife.com"]');

-- ALERTAS
INSERT INTO ALERTAS (ale_cli_id, ale_nombre, ale_tipo, ale_condicion, ale_destinatarios, ale_metodo, ale_activa)
VALUES 
(1, 'Presupuesto 80% Consumido', 'Presupuesto', 
 '{"metrica": "gasto", "condicion": ">=", "valor": 0.8, "referencia": "presupuesto_total"}',
 '["carlos.mendoza@techsolutions.com", "ana.garcia@techsolutions.com"]', 
 'Email', TRUE),
(1, 'CPA Muy Alto', 'Rendimiento', 
 '{"metrica": "cpa", "condicion": ">", "valor": 15000, "periodo": "diario"}',
 '["ana.garcia@techsolutions.com"]', 
 'Email', TRUE),
(2, 'Tasa Conversión Baja', 'Conversión', 
 '{"metrica": "tasa_conversion", "condicion": "<", "valor": 2.0, "periodo": "3_dias"}',
 '["maria.gonzalez@fashionretail.com"]', 
 'Email', TRUE),
(4, 'Campaña Pausada', 'Pausa_Campaña', 
 '{"evento": "cambio_estado", "nuevo_estado": "Pausada"}',
 '["ana.torres@healthylife.com"]', 
 'Push', TRUE);

-- HISTORIAL_ALERTAS
INSERT INTO HISTORIAL_ALERTAS (hal_ale_id, hal_fecha_hora, hal_mensaje, hal_datos_adicionales, hal_leida)
VALUES 
(1, '2024-11-03 18:30:00', 'La campaña "Lanzamiento Producto Q4 2024" ha consumido el 82% de su presupuesto', 
 '{"campana_id": 1, "gasto_actual": 12300000, "presupuesto_total": 15000000, "porcentaje": 82}', 
 TRUE),
(2, '2024-11-04 09:15:00', 'El CPA de la campaña "Lanzamiento Producto Q4 2024" supera el umbral: $15,250', 
 '{"campana_id": 1, "cpa_actual": 15250, "umbral": 15000}', 
 FALSE);

/*-+-----------------------------+
   |   PROCEDIMIENTOS ALMACENADOS |
   +-----------------------------+*/

-- Procedimiento para crear una nueva campaña
DELIMITER //
CREATE PROCEDURE SP_CrearCampana(
    IN p_cue_id INT,
    IN p_nombre VARCHAR(150),
    IN p_objetivo ENUM('Reconocimiento','Consideración','Conversión','Tráfico','Engagement','Instalaciones','Ventas'),
    IN p_descripcion TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_presupuesto_total DECIMAL(12,2),
    IN p_presupuesto_diario DECIMAL(10,2)
)
BEGIN
    DECLARE v_cam_id INT;
    
    INSERT INTO CAMPANAS (cam_cue_id, cam_nombre, cam_objetivo, cam_descripcion, 
                         cam_fecha_inicio, cam_fecha_fin, cam_presupuesto_total, 
                         cam_presupuesto_diario, cam_estado)
    VALUES (p_cue_id, p_nombre, p_objetivo, p_descripcion, 
            p_fecha_inicio, p_fecha_fin, p_presupuesto_total, 
            p_presupuesto_diario, 'Borrador');
    
    SET v_cam_id = LAST_INSERT_ID();
    SELECT v_cam_id AS campaña_id, 'Campaña creada exitosamente' AS mensaje;
END//
DELIMITER ;

-- Procedimiento para registrar métricas diarias
DELIMITER //
CREATE PROCEDURE SP_RegistrarMetricasDiarias(
    IN p_cam_id INT,
    IN p_anu_id INT,
    IN p_fecha DATE,
    IN p_impresiones INT,
    IN p_alcance INT,
    IN p_clicks INT,
    IN p_engagement INT,
    IN p_conversiones INT,
    IN p_valor_conversiones DECIMAL(12,2),
    IN p_gasto DECIMAL(12,2)
)
BEGIN
    DECLARE v_ctr DECIMAL(5,2);
    DECLARE v_tasa_conversion DECIMAL(5,2);
    DECLARE v_frecuencia DECIMAL(5,2);
    DECLARE v_cpc DECIMAL(10,2);
    DECLARE v_cpm DECIMAL(10,2);
    DECLARE v_cpa DECIMAL(10,2);
    DECLARE v_roas DECIMAL(10,2);
    
    -- Calcular métricas derivadas
    SET v_ctr = IF(p_impresiones > 0, (p_clicks / p_impresiones) * 100, 0);
    SET v_tasa_conversion = IF(p_clicks > 0, (p_conversiones / p_clicks) * 100, 0);
    SET v_frecuencia = IF(p_alcance > 0, p_impresiones / p_alcance, 0);
    SET v_cpc = IF(p_clicks > 0, p_gasto / p_clicks, 0);
    SET v_cpm = IF(p_impresiones > 0, (p_gasto / p_impresiones) * 1000, 0);
    SET v_cpa = IF(p_conversiones > 0, p_gasto / p_conversiones, 0);
    SET v_roas = IF(p_gasto > 0, p_valor_conversiones / p_gasto, 0);
    
    INSERT INTO METRICAS_DIARIAS (
        met_cam_id, met_anu_id, met_fecha, met_impresiones, met_alcance, 
        met_frecuencia, met_clicks, met_ctr, met_engagement, met_conversiones, 
        met_tasa_conversion, met_valor_conversiones, met_gasto, met_cpc, 
        met_cpm, met_cpa, met_roas
    ) VALUES (
        p_cam_id, p_anu_id, p_fecha, p_impresiones, p_alcance, 
        v_frecuencia, p_clicks, v_ctr, p_engagement, p_conversiones, 
        v_tasa_conversion, p_valor_conversiones, p_gasto, v_cpc, 
        v_cpm, v_cpa, v_roas
    );
    
    SELECT 'Métricas registradas exitosamente' AS mensaje;
END//
DELIMITER ;

-- Procedimiento para obtener resumen de campaña
DELIMITER //
CREATE PROCEDURE SP_ResumenCampana(
    IN p_cam_id INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        c.cam_nombre,
        c.cam_objetivo,
        c.cam_presupuesto_total,
        SUM(m.met_impresiones) AS total_impresiones,
        SUM(m.met_alcance) AS alcance_total,
        AVG(m.met_frecuencia) AS frecuencia_promedio,
        SUM(m.met_clicks) AS total_clicks,
        AVG(m.met_ctr) AS ctr_promedio,
        SUM(m.met_engagement) AS engagement_total,
        SUM(m.met_conversiones) AS total_conversiones,
        AVG(m.met_tasa_conversion) AS tasa_conversion_promedio,
        SUM(m.met_valor_conversiones) AS valor_total_conversiones,
        SUM(m.met_gasto) AS gasto_total,
        AVG(m.met_cpc) AS cpc_promedio,
        AVG(m.met_cpm) AS cpm_promedio,
        AVG(m.met_cpa) AS cpa_promedio,
        AVG(m.met_roas) AS roas_promedio
    FROM CAMPANAS c
    LEFT JOIN METRICAS_DIARIAS m ON c.cam_id = m.met_cam_id
    WHERE c.cam_id = p_cam_id
      AND m.met_fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY c.cam_id;
END//
DELIMITER ;

-- Procedimiento para comparar rendimiento de anuncios
DELIMITER //
CREATE PROCEDURE SP_CompararAnuncios(
    IN p_cam_id INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        a.anu_id,
        a.anu_nombre,
        a.anu_tipo,
        SUM(m.met_impresiones) AS impresiones,
        SUM(m.met_clicks) AS clicks,
        AVG(m.met_ctr) AS ctr,
        SUM(m.met_conversiones) AS conversiones,
        AVG(m.met_tasa_conversion) AS tasa_conversion,
        SUM(m.met_gasto) AS gasto,
        AVG(m.met_cpa) AS cpa,
        AVG(m.met_roas) AS roas
    FROM ANUNCIOS a
    LEFT JOIN METRICAS_DIARIAS m ON a.anu_id = m.met_anu_id
    WHERE a.anu_cam_id = p_cam_id
      AND m.met_fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY a.anu_id
    ORDER BY conversiones DESC;
END//
DELIMITER ;

/*-+-----------------------------+
   |          FUNCIONES          |
   +-----------------------------+*/

-- Función para calcular ROI de una campaña
DELIMITER //
CREATE FUNCTION FN_CalcularROI(p_cam_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ingresos DECIMAL(12,2);
    DECLARE v_gasto DECIMAL(12,2);
    DECLARE v_roi DECIMAL(10,2);
    
    SELECT 
        COALESCE(SUM(met_valor_conversiones), 0),
        COALESCE(SUM(met_gasto), 0)
    INTO v_ingresos, v_gasto
    FROM METRICAS_DIARIAS
    WHERE met_cam_id = p_cam_id;
    
    IF v_gasto > 0 THEN
        SET v_roi = ((v_ingresos - v_gasto) / v_gasto) * 100;
    ELSE
        SET v_roi = 0;
    END IF;
    
    RETURN v_roi;
END//
DELIMITER ;

-- Función para obtener el mejor anuncio de una campaña
DELIMITER //
CREATE FUNCTION FN_MejorAnuncio(p_cam_id INT, p_metrica VARCHAR(20))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_anu_id INT;
    
    CASE p_metrica
        WHEN 'conversiones' THEN
            SELECT m.met_anu_id INTO v_anu_id
            FROM METRICAS_DIARIAS m
            WHERE m.met_cam_id = p_cam_id
            GROUP BY m.met_anu_id
            ORDER BY SUM(m.met_conversiones) DESC
            LIMIT 1;
        WHEN 'ctr' THEN
            SELECT m.met_anu_id INTO v_anu_id
            FROM METRICAS_DIARIAS m
            WHERE m.met_cam_id = p_cam_id
            GROUP BY m.met_anu_id
            ORDER BY AVG(m.met_ctr) DESC
            LIMIT 1;
        WHEN 'roas' THEN
            SELECT m.met_anu_id INTO v_anu_id
            FROM METRICAS_DIARIAS m
            WHERE m.met_cam_id = p_cam_id
            GROUP BY m.met_anu_id
            ORDER BY AVG(m.met_roas) DESC
            LIMIT 1;
        ELSE
            SET v_anu_id = NULL;
    END CASE;
    
    RETURN v_anu_id;
END//
DELIMITER ;

-- Función para calcular presupuesto restante
DELIMITER //
CREATE FUNCTION FN_PresupuestoRestante(p_cam_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_presupuesto DECIMAL(12,2);
    DECLARE v_gastado DECIMAL(12,2);
    
    SELECT cam_presupuesto_total INTO v_presupuesto
    FROM CAMPANAS
    WHERE cam_id = p_cam_id;
    
    SELECT COALESCE(SUM(met_gasto), 0) INTO v_gastado
    FROM METRICAS_DIARIAS
    WHERE met_cam_id = p_cam_id;
    
    RETURN v_presupuesto - v_gastado;
END//
DELIMITER ;

/*-+-----------------------------+
   |         TRIGGERS            |
   +-----------------------------+*/

-- Trigger para verificar alertas de presupuesto
DELIMITER //
CREATE TRIGGER TRG_VerificarPresupuesto
AFTER INSERT ON METRICAS_DIARIAS
FOR EACH ROW
BEGIN
    DECLARE v_presupuesto_total DECIMAL(12,2);
    DECLARE v_gasto_acumulado DECIMAL(12,2);
    DECLARE v_porcentaje DECIMAL(5,2);
    DECLARE v_ale_id INT;
    
    -- Obtener presupuesto de la campaña
    SELECT cam_presupuesto_total INTO v_presupuesto_total
    FROM CAMPANAS
    WHERE cam_id = NEW.met_cam_id;
    
    -- Calcular gasto acumulado
    SELECT SUM(met_gasto) INTO v_gasto_acumulado
    FROM METRICAS_DIARIAS
    WHERE met_cam_id = NEW.met_cam_id;
    
    -- Calcular porcentaje
    SET v_porcentaje = (v_gasto_acumulado / v_presupuesto_total) * 100;
    
    -- Si supera el 80%, buscar si existe alerta configurada
    IF v_porcentaje >= 80 THEN
        SELECT ale_id INTO v_ale_id
        FROM ALERTAS
        WHERE ale_tipo = 'Presupuesto'
          AND ale_activa = TRUE
          AND ale_cli_id = (
              SELECT cli_id FROM CLIENTES c
              JOIN CUENTAS_PUBLICITARIAS cu ON c.cli_id = cu.cue_cli_id
              JOIN CAMPANAS ca ON cu.cue_id = ca.cam_cue_id
              WHERE ca.cam_id = NEW.met_cam_id
          )
        LIMIT 1;
        
        -- Registrar en historial de alertas
        IF v_ale_id IS NOT NULL THEN
            INSERT INTO HISTORIAL_ALERTAS (hal_ale_id, hal_mensaje, hal_datos_adicionales)
            VALUES (
                v_ale_id,
                CONCAT('Alerta: La campaña ha consumido el ', ROUND(v_porcentaje, 2), '% del presupuesto'),
                JSON_OBJECT(
                    'campana_id', NEW.met_cam_id,
                    'gasto_actual', v_gasto_acumulado,
                    'presupuesto_total', v_presupuesto_total,
                    'porcentaje', v_porcentaje
                )
            );
        END IF;
    END IF;
END//
DELIMITER ;

-- Trigger para registrar auditoría de cambios en campañas
DELIMITER //
CREATE TRIGGER TRG_AuditoriaCampanas
AFTER UPDATE ON CAMPANAS
FOR EACH ROW
BEGIN
    IF OLD.cam_estado != NEW.cam_estado OR 
       OLD.cam_presupuesto_total != NEW.cam_presupuesto_total THEN
        
        INSERT INTO AUDITORIA (aud_usu_id, aud_accion, aud_entidad, aud_entidad_id, 
                              aud_valores_anteriores, aud_valores_nuevos)
        VALUES (
            1, -- Usuario del sistema (ajustar según contexto)
            'UPDATE',
            'CAMPANAS',
            NEW.cam_id,
            JSON_OBJECT(
                'estado', OLD.cam_estado,
                'presupuesto', OLD.cam_presupuesto_total
            ),
            JSON_OBJECT(
                'estado', NEW.cam_estado,
                'presupuesto', NEW.cam_presupuesto_total
            )
        );
    END IF;
END//
DELIMITER ;