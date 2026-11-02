-- Proyecto de citas médicas EPS Villavicencio
-- Ejecutar en una base de datos vacía creada previamente.
CREATE TABLE tipo_documento (
    id_tipo_doc SERIAL PRIMARY KEY,
    sigla VARCHAR(10) NOT NULL,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE estado (
    id_estado SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    ambito VARCHAR(50) -- Ej: 'Consultorio', 'Cita', 'Horario'
);

CREATE TABLE tarifa (
    id_tarifa SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    ingreso_min NUMERIC(12,2) NOT NULL,
    ingreso_max NUMERIC(12,2) NOT NULL,
    porcentaje_cobro NUMERIC(5,2) NOT NULL
);

CREATE TABLE servicio (
    id_servicio SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    costo_base NUMERIC(10,2) NOT NULL
);

CREATE TABLE especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE afiliado (
    id_afiliado SERIAL PRIMARY KEY,
    id_tipo_doc INT NOT NULL REFERENCES tipo_documento(id_tipo_doc),
    num_doc VARCHAR(20) NOT NULL,
    nombre1 VARCHAR(50) NOT NULL,
    nombre2 VARCHAR(50),
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50),
    sexo VARCHAR(15),
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(150),
    ingreso_mensual NUMERIC(12,2),
    id_tarifa INT REFERENCES tarifa(id_tarifa),
    -- Restricción UQ para que no se repita el mismo documento con el mismo tipo
    CONSTRAINT uq_afiliado_doc UNIQUE (id_tipo_doc, num_doc)
);

CREATE TABLE consultorio (
    id_consultorio SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    capacidad INT,
    id_estado INT NOT NULL REFERENCES estado(id_estado)
);

CREATE TABLE historial (
    id_historial SERIAL PRIMARY KEY,
    -- Restricción UNIQUE para garantizar la relación 1 a 1 con el afiliado
    id_afiliado INT NOT NULL UNIQUE REFERENCES afiliado(id_afiliado) ON DELETE CASCADE,
    fecha_apertura DATE DEFAULT CURRENT_DATE,
    alergias TEXT,
    grupo_sanguineo VARCHAR(5),
    antecedentes TEXT,
    observaciones TEXT
);

CREATE TABLE consultorio_especialidad (
    id_consultorio INT NOT NULL REFERENCES consultorio(id_consultorio) ON DELETE CASCADE,
    id_especialidad INT NOT NULL REFERENCES especialidad(id_especialidad) ON DELETE CASCADE,
    -- Llave primaria compuesta
    PRIMARY KEY (id_consultorio, id_especialidad)
);

CREATE TABLE medico (
    id_medico SERIAL PRIMARY KEY,
    id_tipo_doc INT NOT NULL REFERENCES tipo_documento(id_tipo_doc),
    num_documento VARCHAR(20) NOT NULL,
    nombre1 VARCHAR(50) NOT NULL,
    nombre2 VARCHAR(50),
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50),
    correo VARCHAR(100),
    telefono VARCHAR(20),
    id_especialidad INT NOT NULL REFERENCES especialidad(id_especialidad),
    id_consultorio INT REFERENCES consultorio(id_consultorio),
    -- Restricción UQ para el documento del médico
    CONSTRAINT uq_medico_doc UNIQUE (id_tipo_doc, num_documento)
);

CREATE TABLE horario (
    id_horario SERIAL PRIMARY KEY,
    id_medico INT NOT NULL REFERENCES medico(id_medico) ON DELETE CASCADE,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    id_estado INT NOT NULL REFERENCES estado(id_estado)
);

CREATE TABLE cita (
    id_cita SERIAL PRIMARY KEY,
    id_afiliado INT NOT NULL REFERENCES afiliado(id_afiliado),
    id_servicio INT NOT NULL REFERENCES servicio(id_servicio),
    -- Restricción UNIQUE para que un horario no pueda ser agendado en dos citas distintas
    id_horario INT NOT NULL UNIQUE REFERENCES horario(id_horario),
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_estado INT NOT NULL REFERENCES estado(id_estado),
    valor_cobrado NUMERIC(10,2)
);

ALTER TABLE cita DROP CONSTRAINT cita_id_afiliado_fkey;
ALTER TABLE cita ADD CONSTRAINT cita_id_afiliado_fkey
  FOREIGN KEY (id_afiliado) REFERENCES afiliado(id_afiliado)
  ON DELETE RESTRICT ON UPDATE CASCADE;
  
-------RESTRINCCIONES-------
ALTER TABLE afiliado ADD CONSTRAINT ck_afi_ingreso CHECK (ingreso_mensual >= 0);
ALTER TABLE afiliado ADD CONSTRAINT ck_afi_fnac CHECK (fecha_nacimiento <= CURRENT_DATE);
ALTER TABLE servicio ADD CONSTRAINT ck_serv_costo CHECK (costo_base >= 0);
ALTER TABLE consultorio ADD CONSTRAINT ck_cons_cap CHECK (capacidad >= 0);
ALTER TABLE tarifa ADD CONSTRAINT ck_tarifa CHECK (porcentaje_cobro >= 0 AND ingreso_max >= ingreso_min);
ALTER TABLE horario ADD CONSTRAINT ck_hor_horas CHECK (hora_fin > hora_inicio);
ALTER TABLE cita ADD CONSTRAINT ck_cita_valor CHECK (valor_cobrado >= 0);
ALTER TABLE afiliado DROP CONSTRAINT afiliado_id_tipo_doc_fkey, ADD CONSTRAINT afiliado_id_tipo_doc_fkey FOREIGN KEY (id_tipo_doc) REFERENCES tipo_documento(id_tipo_doc) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE afiliado DROP CONSTRAINT afiliado_id_tarifa_fkey, ADD CONSTRAINT afiliado_id_tarifa_fkey FOREIGN KEY (id_tarifa) REFERENCES tarifa(id_tarifa) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE historial DROP CONSTRAINT historial_id_afiliado_fkey, ADD CONSTRAINT historial_id_afiliado_fkey FOREIGN KEY (id_afiliado) REFERENCES afiliado(id_afiliado) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE medico DROP CONSTRAINT medico_id_tipo_doc_fkey, ADD CONSTRAINT medico_id_tipo_doc_fkey FOREIGN KEY (id_tipo_doc) REFERENCES tipo_documento(id_tipo_doc) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE medico DROP CONSTRAINT medico_id_especialidad_fkey, ADD CONSTRAINT medico_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE medico DROP CONSTRAINT medico_id_consultorio_fkey, ADD CONSTRAINT medico_id_consultorio_fkey FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE consultorio DROP CONSTRAINT consultorio_id_estado_fkey, ADD CONSTRAINT consultorio_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE horario DROP CONSTRAINT horario_id_medico_fkey, ADD CONSTRAINT horario_id_medico_fkey FOREIGN KEY (id_medico) REFERENCES medico(id_medico) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE horario DROP CONSTRAINT horario_id_estado_fkey, ADD CONSTRAINT horario_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE cita DROP CONSTRAINT cita_id_servicio_fkey, ADD CONSTRAINT cita_id_servicio_fkey FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE cita DROP CONSTRAINT cita_id_horario_fkey, ADD CONSTRAINT cita_id_horario_fkey FOREIGN KEY (id_horario) REFERENCES horario(id_horario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE cita DROP CONSTRAINT cita_id_estado_fkey, ADD CONSTRAINT cita_id_estado_fkey FOREIGN KEY (id_estado) REFERENCES estado(id_estado) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE consultorio_especialidad DROP CONSTRAINT consultorio_especialidad_id_consultorio_fkey, ADD CONSTRAINT consultorio_especialidad_id_consultorio_fkey FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE consultorio_especialidad DROP CONSTRAINT consultorio_especialidad_id_especialidad_fkey, ADD CONSTRAINT consultorio_especialidad_id_especialidad_fkey FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE tarifa ADD CONSTRAINT ck_tarifa_porc_max CHECK (porcentaje_cobro <= 100);
ALTER TABLE tarifa ADD CONSTRAINT ck_tarifa_ing_min CHECK (ingreso_min >= 0);
ALTER TABLE estado ADD CONSTRAINT ck_estado_ambito CHECK (ambito IN ('horario','consultorio','cita'));

-------disparadores-------

CREATE OR REPLACE FUNCTION fn_valor_cobrado() RETURNS trigger AS $$
DECLARE
  v_costo NUMERIC;
  v_porc  NUMERIC;
BEGIN
  SELECT costo_base INTO v_costo
    FROM servicio WHERE id_servicio = NEW.id_servicio;
  SELECT t.porcentaje_cobro INTO v_porc
    FROM afiliado a JOIN tarifa t ON t.id_tarifa = a.id_tarifa
   WHERE a.id_afiliado = NEW.id_afiliado;
  IF v_costo IS NULL OR v_porc IS NULL THEN
    RAISE EXCEPTION 'No se puede calcular el valor: servicio o tarifa del afiliado no encontrados';
  END IF;
  NEW.valor_cobrado := ROUND(v_costo * v_porc / 100, 2);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_valor_cobrado
BEFORE INSERT OR UPDATE OF id_servicio, id_afiliado ON cita
FOR EACH ROW EXECUTE FUNCTION fn_valor_cobrado();

CREATE OR REPLACE FUNCTION fn_ocupar_horario() RETURNS trigger AS $$
DECLARE
  v_disp   INT;
  v_ocup   INT;
  v_actual INT;
BEGIN
  SELECT id_estado INTO v_disp FROM estado WHERE ambito = 'horario' AND nombre = 'Disponible';
  SELECT id_estado INTO v_ocup FROM estado WHERE ambito = 'horario' AND nombre = 'Ocupado';
  SELECT id_estado INTO v_actual FROM horario WHERE id_horario = NEW.id_horario;
  IF v_actual IS DISTINCT FROM v_disp THEN
    RAISE EXCEPTION 'El horario % no está disponible', NEW.id_horario;
  END IF;
  UPDATE horario SET id_estado = v_ocup WHERE id_horario = NEW.id_horario;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_ocupar_horario
BEFORE INSERT ON cita
FOR EACH ROW EXECUTE FUNCTION fn_ocupar_horario();
CREATE OR REPLACE FUNCTION fn_liberar_horario() RETURNS trigger AS $$
BEGIN
  UPDATE horario
     SET id_estado = (SELECT id_estado FROM estado WHERE ambito = 'horario' AND nombre = 'Disponible')
   WHERE id_horario = OLD.id_horario;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_liberar_horario
AFTER DELETE ON cita
FOR EACH ROW EXECUTE FUNCTION fn_liberar_horario();

-----------------------LLENAR DATOS-----------------------
--------------------1. Catálogos--------------------------

-- Estados usados por consultorios, horarios y citas.
INSERT INTO estado (nombre, ambito) VALUES
  ('Disponible', 'consultorio'),
  ('Disponible', 'horario'),
  ('Ocupado', 'horario'),
  ('Programada', 'cita'),
  ('Cancelada', 'cita'),
  ('Atendida', 'cita');

INSERT INTO tipo_documento (sigla, nombre) VALUES
  ('TI','Tarjeta de identidad'), ('CC','Cédula de ciudadanía'),
  ('CE','Cédula de extranjería'), ('PA','Pasaporte'), ('RC','Registro civil');

INSERT INTO tarifa (nombre, ingreso_min, ingreso_max, porcentaje_cobro) VALUES
  ('Categoría A (ingresos bajos)',  0,       2000000,  10),
  ('Categoría B (ingresos medios)', 2000001, 5000000,  30),
  ('Categoría C (ingresos altos)',  5000001, 50000000, 60),
  ('Régimen especial (Policía/Estado)', 0,   50000000, 0);

INSERT INTO servicio (nombre, descripcion, costo_base) VALUES
  ('Consulta medicina general', 'Consulta médica general', 50000),
  ('Consulta pediatría',        'Atención a menores de edad', 70000),
  ('Consulta odontología',      'Valoración odontológica',   60000);

INSERT INTO especialidad (nombre, descripcion) VALUES
  ('Medicina general', 'Atención médica primaria'),
  ('Pediatría',        'Atención infantil'),
  ('Odontología',      'Salud oral');
  
---------2. Consultorios y su relación con especialidades-----------------------

INSERT INTO consultorio (nombre, ubicacion, capacidad, id_estado) VALUES
  ('Consultorio 101', 'Piso 1', 3, (SELECT id_estado FROM estado WHERE ambito='consultorio' AND nombre='Disponible')),
  ('Consultorio 102', 'Piso 1', 3, (SELECT id_estado FROM estado WHERE ambito='consultorio' AND nombre='Disponible')),
  ('Consultorio 201', 'Piso 2', 2, (SELECT id_estado FROM estado WHERE ambito='consultorio' AND nombre='Disponible'));

INSERT INTO consultorio_especialidad (id_consultorio, id_especialidad) VALUES
  ((SELECT id_consultorio FROM consultorio WHERE nombre='Consultorio 101'), (SELECT id_especialidad FROM especialidad WHERE nombre='Medicina general')),
  ((SELECT id_consultorio FROM consultorio WHERE nombre='Consultorio 102'), (SELECT id_especialidad FROM especialidad WHERE nombre='Pediatría')),
  ((SELECT id_consultorio FROM consultorio WHERE nombre='Consultorio 201'), (SELECT id_especialidad FROM especialidad WHERE nombre='Odontología'));

-------------------3. Afiliados (uno normal y uno de régimen especial) y sus historiales--------------------------------

INSERT INTO afiliado (id_tipo_doc, num_doc, nombre1, nombre2, apellido1, apellido2, sexo,
                      fecha_nacimiento, telefono, correo, direccion, ingreso_mensual, id_tarifa) VALUES
  ((SELECT id_tipo_doc FROM tipo_documento WHERE sigla='CC'), '1000000001', 'Ana', 'María', 'Gómez', 'Ruiz', 'F',
   '1998-05-14', '3101234567', 'ana@correo.com', 'Calle 10 # 5-20', 3000000,
   (SELECT id_tarifa FROM tarifa WHERE nombre LIKE 'Categoría B%')),
  ((SELECT id_tipo_doc FROM tipo_documento WHERE sigla='CC'), '1000000002', 'Carlos', NULL, 'Pérez', 'Díaz', 'M',
   '1985-11-02', '3207654321', 'carlos@correo.com', 'Carrera 22 # 8-15', 4500000,
   (SELECT id_tarifa FROM tarifa WHERE nombre LIKE 'Régimen especial%'));

INSERT INTO historial (id_afiliado, fecha_apertura, alergias, grupo_sanguineo, antecedentes, observaciones) VALUES
  ((SELECT id_afiliado FROM afiliado WHERE num_doc='1000000001'), CURRENT_DATE, 'Ninguna', 'O+', 'Ninguno', 'Primera consulta'),
  ((SELECT id_afiliado FROM afiliado WHERE num_doc='1000000002'), CURRENT_DATE, 'Ninguna', 'A+', 'Ninguno', 'Primera consulta');

---------------------4. Médicos y horario-------------------------------

INSERT INTO medico (id_tipo_doc, num_documento, nombre1, nombre2, apellido1, apellido2, correo, telefono,
                    id_especialidad, id_consultorio) VALUES
  ((SELECT id_tipo_doc FROM tipo_documento WHERE sigla='CC'), '900000001', 'Laura', NULL, 'Rojas', 'Mora', 'laura@eps.com', '3001112222',
   (SELECT id_especialidad FROM especialidad WHERE nombre='Medicina general'),
   (SELECT id_consultorio FROM consultorio WHERE nombre='Consultorio 101')),
  ((SELECT id_tipo_doc FROM tipo_documento WHERE sigla='CC'), '900000002', 'Pedro', NULL, 'Salas', 'Vega', 'pedro@eps.com', '3003334444',
   (SELECT id_especialidad FROM especialidad WHERE nombre='Pediatría'),
   (SELECT id_consultorio FROM consultorio WHERE nombre='Consultorio 102'));

INSERT INTO horario (id_medico, fecha, hora_inicio, hora_fin, id_estado) VALUES
  ((SELECT id_medico FROM medico WHERE num_documento='900000001'), CURRENT_DATE + 1, '08:00', '08:30', (SELECT id_estado FROM estado WHERE ambito='horario' AND nombre='Disponible')),
  ((SELECT id_medico FROM medico WHERE num_documento='900000001'), CURRENT_DATE + 1, '08:30', '09:00', (SELECT id_estado FROM estado WHERE ambito='horario' AND nombre='Disponible')),
  ((SELECT id_medico FROM medico WHERE num_documento='900000002'), CURRENT_DATE + 1, '09:00', '09:30', (SELECT id_estado FROM estado WHERE ambito='horario' AND nombre='Disponible')),
  ((SELECT id_medico FROM medico WHERE num_documento='900000002'), CURRENT_DATE + 2, '10:00', '10:30', (SELECT id_estado FROM estado WHERE ambito='horario' AND nombre='Disponible'));


---------------------1. Descripciones de tablas y columnas---------------------
-- TABLAS
COMMENT ON TABLE tipo_documento IS 'Catálogo de tipos de documento de identidad (lista desplegable)';
COMMENT ON TABLE estado IS 'Catálogo de estados para horarios, consultorios y citas (lista desplegable)';
COMMENT ON TABLE tarifa IS 'Categorías de cobro según ingresos y régimen del afiliado';
COMMENT ON TABLE afiliado IS 'Personas afiliadas que solicitan citas médicas';
COMMENT ON TABLE historial IS 'Historia clínica básica de cada afiliado';
COMMENT ON TABLE servicio IS 'Servicios médicos ofrecidos y su costo base';
COMMENT ON TABLE especialidad IS 'Especialidades médicas';
COMMENT ON TABLE consultorio IS 'Consultorios o salas donde se atiende a los afiliados';
COMMENT ON TABLE consultorio_especialidad IS 'Relación Ejerce: especialidades que se atienden en cada consultorio (N:M)';
COMMENT ON TABLE medico IS 'Médicos que atienden las citas';
COMMENT ON TABLE horario IS 'Franjas de atención de cada médico';
COMMENT ON TABLE cita IS 'Reservas de citas médicas de los afiliados';

-- tipo_documento
COMMENT ON COLUMN tipo_documento.id_tipo_doc IS 'Identificador del tipo de documento (PK)';
COMMENT ON COLUMN tipo_documento.sigla IS 'Abreviatura del tipo de documento (TI, CC, CE, PA, RC)';
COMMENT ON COLUMN tipo_documento.nombre IS 'Nombre completo del tipo de documento';

-- estado
COMMENT ON COLUMN estado.id_estado IS 'Identificador del estado (PK)';
COMMENT ON COLUMN estado.nombre IS 'Nombre del estado (Disponible, Ocupado, Reservada, etc.)';
COMMENT ON COLUMN estado.ambito IS 'Entidad a la que aplica: horario, consultorio o cita';

-- tarifa
COMMENT ON COLUMN tarifa.id_tarifa IS 'Identificador de la categoría de tarifa (PK)';
COMMENT ON COLUMN tarifa.nombre IS 'Nombre de la categoría o régimen';
COMMENT ON COLUMN tarifa.ingreso_min IS 'Ingreso mensual mínimo de la categoría';
COMMENT ON COLUMN tarifa.ingreso_max IS 'Ingreso mensual máximo de la categoría';
COMMENT ON COLUMN tarifa.porcentaje_cobro IS 'Porcentaje del costo del servicio que paga el afiliado (0 a 100)';

-- afiliado
COMMENT ON COLUMN afiliado.id_afiliado IS 'Identificador del afiliado (PK)';
COMMENT ON COLUMN afiliado.id_tipo_doc IS 'Tipo de documento del afiliado (FK a tipo_documento)';
COMMENT ON COLUMN afiliado.num_doc IS 'Número de documento de identidad';
COMMENT ON COLUMN afiliado.nombre1 IS 'Primer nombre';
COMMENT ON COLUMN afiliado.nombre2 IS 'Segundo nombre (opcional)';
COMMENT ON COLUMN afiliado.apellido1 IS 'Primer apellido';
COMMENT ON COLUMN afiliado.apellido2 IS 'Segundo apellido (opcional)';
COMMENT ON COLUMN afiliado.sexo IS 'Sexo del afiliado';
COMMENT ON COLUMN afiliado.fecha_nacimiento IS 'Fecha de nacimiento (no puede ser futura)';
COMMENT ON COLUMN afiliado.telefono IS 'Teléfono de contacto';
COMMENT ON COLUMN afiliado.correo IS 'Correo electrónico';
COMMENT ON COLUMN afiliado.direccion IS 'Dirección de residencia';
COMMENT ON COLUMN afiliado.ingreso_mensual IS 'Ingreso mensual declarado (mayor o igual a 0)';
COMMENT ON COLUMN afiliado.id_tarifa IS 'Categoría de tarifa asignada (FK a tarifa)';

-- historial
COMMENT ON COLUMN historial.id_historial IS 'Identificador del historial (PK)';
COMMENT ON COLUMN historial.id_afiliado IS 'Afiliado dueño del historial (FK, único: uno por afiliado)';
COMMENT ON COLUMN historial.fecha_apertura IS 'Fecha en que se abrió el historial';
COMMENT ON COLUMN historial.alergias IS 'Alergias conocidas del afiliado';
COMMENT ON COLUMN historial.grupo_sanguineo IS 'Grupo sanguíneo y factor RH';
COMMENT ON COLUMN historial.antecedentes IS 'Antecedentes médicos';
COMMENT ON COLUMN historial.observaciones IS 'Observaciones generales';

-- servicio
COMMENT ON COLUMN servicio.id_servicio IS 'Identificador del servicio (PK)';
COMMENT ON COLUMN servicio.nombre IS 'Nombre del servicio médico';
COMMENT ON COLUMN servicio.descripcion IS 'Descripción del servicio';
COMMENT ON COLUMN servicio.costo_base IS 'Costo base del servicio antes de aplicar la tarifa (mayor o igual a 0)';

-- especialidad
COMMENT ON COLUMN especialidad.id_especialidad IS 'Identificador de la especialidad (PK)';
COMMENT ON COLUMN especialidad.nombre IS 'Nombre de la especialidad';
COMMENT ON COLUMN especialidad.descripcion IS 'Descripción de la especialidad';

-- consultorio
COMMENT ON COLUMN consultorio.id_consultorio IS 'Identificador del consultorio (PK)';
COMMENT ON COLUMN consultorio.nombre IS 'Nombre o número del consultorio';
COMMENT ON COLUMN consultorio.ubicacion IS 'Ubicación física (piso, sede)';
COMMENT ON COLUMN consultorio.capacidad IS 'Capacidad de personas (mayor o igual a 0)';
COMMENT ON COLUMN consultorio.id_estado IS 'Estado del consultorio (FK a estado)';

-- consultorio_especialidad
COMMENT ON COLUMN consultorio_especialidad.id_consultorio IS 'Consultorio (FK, parte de la PK compuesta)';
COMMENT ON COLUMN consultorio_especialidad.id_especialidad IS 'Especialidad (FK, parte de la PK compuesta)';

-- medico
COMMENT ON COLUMN medico.id_medico IS 'Identificador del médico (PK)';
COMMENT ON COLUMN medico.id_tipo_doc IS 'Tipo de documento del médico (FK a tipo_documento)';
COMMENT ON COLUMN medico.num_documento IS 'Número de documento de identidad';
COMMENT ON COLUMN medico.nombre1 IS 'Primer nombre';
COMMENT ON COLUMN medico.nombre2 IS 'Segundo nombre (opcional)';
COMMENT ON COLUMN medico.apellido1 IS 'Primer apellido';
COMMENT ON COLUMN medico.apellido2 IS 'Segundo apellido (opcional)';
COMMENT ON COLUMN medico.correo IS 'Correo electrónico';
COMMENT ON COLUMN medico.telefono IS 'Teléfono de contacto';
COMMENT ON COLUMN medico.id_especialidad IS 'Especialidad del médico (FK a especialidad)';
COMMENT ON COLUMN medico.id_consultorio IS 'Consultorio donde atiende (FK, acepta nulo)';

-- horario
COMMENT ON COLUMN horario.id_horario IS 'Identificador del horario (PK)';
COMMENT ON COLUMN horario.id_medico IS 'Médico al que pertenece el horario (FK a medico)';
COMMENT ON COLUMN horario.fecha IS 'Fecha de la franja de atención';
COMMENT ON COLUMN horario.hora_inicio IS 'Hora de inicio de la franja';
COMMENT ON COLUMN horario.hora_fin IS 'Hora de fin (debe ser posterior a la de inicio)';
COMMENT ON COLUMN horario.id_estado IS 'Estado del horario (FK a estado): Disponible u Ocupado';

-- cita
COMMENT ON COLUMN cita.id_cita IS 'Identificador de la cita (PK)';
COMMENT ON COLUMN cita.id_afiliado IS 'Afiliado que solicita la cita (FK a afiliado)';
COMMENT ON COLUMN cita.id_servicio IS 'Servicio solicitado (FK a servicio)';
COMMENT ON COLUMN cita.id_horario IS 'Horario reservado (FK a horario, único: un horario por cita)';
COMMENT ON COLUMN cita.fecha_solicitud IS 'Fecha en que se solicitó la cita';
COMMENT ON COLUMN cita.id_estado IS 'Estado de la cita (FK a estado)';
COMMENT ON COLUMN cita.valor_cobrado IS 'Valor a pagar, calculado por el disparador: costo_base por porcentaje de la tarifa';

------------3. Llaves y reglas por tabla------------------------
SELECT conrelid::regclass AS tabla,
       conname AS restriccion,
       CASE contype WHEN 'p' THEN 'PK' WHEN 'f' THEN 'FK'
                    WHEN 'u' THEN 'UNIQUE' WHEN 'c' THEN 'CHECK' END AS tipo,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY 1, tipo;

  CREATE EXTENSION IF NOT EXISTS btree_gist;
  ALTER TABLE horario ADD CONSTRAINT ex_horario_sin_cruce
    EXCLUDE USING gist (id_medico WITH =,
                        tsrange(fecha + hora_inicio, fecha + hora_fin) WITH &&);


