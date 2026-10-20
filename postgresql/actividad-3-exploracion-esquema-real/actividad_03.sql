-- ACTIVIDAD 3: EXPLORACION DEL ESQUEMA REAL DE GNU HEALTH
-- Base de datos: health50
-- Esquema investigado: public
-- Objetivo: identificar estructura, columnas y relaciones sin modificar los datos de la base de datos.

-- CONSULTA 1. IDENTIFICAR EL ENTORNO
-- Consultar la version de PostgreSQL, la base de datos, el usuario conectado, el esquema actual y la direccion del servidor.

SELECT
    version() AS version_postgresql,
    current_database() AS base_actual,
    current_user AS usuario_conectado,
    current_schema() AS esquema_actual,
    inet_server_addr() AS direccion_servidor;

-- CONSULTA 2. ENUMERAR LOS ESQUEMAS
-- Identificar los esquemas disponibles en la base de datos.

SELECT
    schema_name
FROM information_schema.schemata
ORDER BY schema_name;

-- CONSULTA 3. LOCALIZAR TABLAS CANDIDATAS
-- Buscar tablas cuyos nombres hagan referencia a pacientes, personas, entidades o partes.
-- El nombre de una tabla no demuestra por si solo su funcion
-- exacta ni sus relaciones con otras tablas.

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND (
      table_name ILIKE '%patient%'
      OR table_name ILIKE '%person%'
      OR table_name ILIKE '%party%'
      OR table_name ILIKE '%entity%'
  )
ORDER BY table_schema, table_name;

-- CONSULTA 4. EXAMINAR COLUMNAS DE GNUHEALTH_PATIENT
-- Obtener las columnas, el orden, los tipos de datos y si permiten valores nulos.

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'gnuhealth_patient'
ORDER BY ordinal_position;

-- CONSULTA 5. INVESTIGAR CLAVES FORANEAS
-- Identificar las claves foraneas declaradas en PostgreSQL que apuntan a gnuhealth_patient o parten de esa tabla.
-- Tablas identificadas:
-- gnuhealth_patient, party_party, party_address, gnuhealth_healthprofessional, gnuhealth_appointment, gnuhealth_health_service, gnuhealth_lab, gnuhealth_inpatient_registration y otras.

-- gnuhealth_patient.party referencia party_party.id.

SELECT
    tc.table_schema,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS esquema_referenciado,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND (
      tc.table_name = 'gnuhealth_patient'
      OR ccu.table_name = 'gnuhealth_patient'
  )
ORDER BY tc.table_name, kcu.column_name;

-- CONSULTA 6. EXAMINAR CLAVES DE PACIENTES Y PERSONAS
-- Identificar claves primarias y foraneas de las tres tablas para investigar como se vinculan sus registros.
-- Resultados :
-- 1. gnuhealth_patient tiene la clave primaria id. 2. gnuhealth_patient.party referencia party_party.id.
-- 3. gnuhealth_person_name.party referencia party_party.id. 4. party_party tiene la clave primaria id.

SELECT
    tc.table_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.table_schema
WHERE tc.table_schema = 'public'
  AND tc.table_name IN (
      'gnuhealth_patient',
      'party_party',
      'gnuhealth_person_name'
  )
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY
    tc.table_name,
    tc.constraint_type,
    kcu.column_name;

-- CONSULTA 7. EXAMINAR LAS COLUMNAS DE PERSONAS Y ENTIDADES
-- Comparar las columnas y tipos de datos de las tres tablas para comprender mejor su estructura.
-- Resultados: gnuhealth_patient: 119 columnas party_party: 46 columnas gnuhealth_person_name: 13 columnas.

SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'gnuhealth_patient',
      'party_party',
      'gnuhealth_person_name'
  )
ORDER BY
    table_name,
    ordinal_position;

-- CONSULTA 8. EXAMINAR ESTRUCTURA DE TABLAS CANDIDATAS ATENCION Y CITAS
-- Identificar columnas y tipos de datos de tablas candidatas para investigar el proceso de atencion ambulatoria.
-- Hallazgos:gnuhealth_appointment contiene fecha, paciente, profesional, estado y tipo de cita.
-- gnuhealth_patient_evaluation contiene cita, paciente, profesional, fecha de inicio, estado y datos clinicos.
-- gnuhealth_healthprofessional contiene party, especialidad principal e institucion.
-- gnuhealth_health_service contiene paciente, fecha del servicio, estado e institucion.

SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'gnuhealth_appointment',
      'gnuhealth_health_service',
      'gnuhealth_patient_evaluation',
      'gnuhealth_healthprofessional'
  )
ORDER BY
    table_name,
    ordinal_position;

-- CONSULTA 9. VERIFICAR RELACIONES DE CITAS Y EVALUACIONES
-- Comprobar las claves declaradas para las tablas candidatas del proceso asistencial.

SELECT
    tc.table_name AS tabla_origen,
    tc.constraint_type AS tipo_restriccion,
    kcu.column_name AS columna_origen,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    tc.constraint_name AS nombre_restriccion
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.table_schema
WHERE tc.table_schema = 'public'
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
  AND (
      tc.table_name IN (
          'gnuhealth_appointment',
          'gnuhealth_patient_evaluation',
          'gnuhealth_healthprofessional',
          'gnuhealth_health_service'
      )
      OR ccu.table_name IN (
          'gnuhealth_appointment',
          'gnuhealth_patient_evaluation',
          'gnuhealth_healthprofessional',
          'gnuhealth_health_service'
      )
  )
ORDER BY
    tc.table_name,
    tc.constraint_type,
    kcu.column_name;

-- CONSULTA 10. RESUMEN DE CITAS Y EVALUACIONES
-- Contar registros y revisar la presencia de relaciones clave. No muestra nombres ni datos clinicos de pacientes.

SELECT
    'Citas' AS tipo_registro,
    COUNT(*) AS total_registros,
    COUNT(patient) AS con_paciente_asociado,
    COUNT(healthprof) AS con_profesional_asociado
FROM public.gnuhealth_appointment

UNION ALL

SELECT
    'Evaluaciones' AS tipo_registro,
    COUNT(*) AS total_registros,
    COUNT(patient) AS con_paciente_asociado,
    COUNT(healthprof) AS con_profesional_asociado
FROM public.gnuhealth_patient_evaluation;

-- CONSULTA 11. EVALUACIONES CON Y SIN CITA VINCULADA
-- Analizar la relacion declarada entre evaluaciones y citas. No muestra datos personales ni clinicos.

SELECT
    COUNT(*) AS total_evaluaciones,
    COUNT(appointment) AS con_cita_asociada,
    COUNT(*) - COUNT(appointment) AS sin_cita_asociada
FROM public.gnuhealth_patient_evaluation;


-- CONSULTA 12. INSPECCIONAR COLUMNAS DE ir_module
-- identificar los campos disponibles para verificar los modulos instalados sin modificar datos.

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ir_module'
ORDER BY ordinal_position;


-- CONSULTA 13. MODULOS DE GNU HEALTH REGISTRADOS
-- Proposito: identificar los modulos relacionados con GNU Health y su estado en la base de datos.

SELECT
    name AS nombre_modulo,
    state AS estado,
    description AS descripcion
FROM public.ir_module
WHERE name ILIKE '%health%'
ORDER BY name;

-- CONSULTA FINAL 1
-- Proposito: contar citas por estado y observar la presencia de paciente y profesional asociados. Solo lectura; no muestra datos personales.

SELECT
    state AS estado_cita,
    COUNT(*) AS total_citas,
    COUNT(patient) AS citas_con_paciente,
    COUNT(healthprof) AS citas_con_profesional
FROM public.gnuhealth_appointment
GROUP BY state
ORDER BY state;

-- CONSULTA FINAL 2
-- Proposito: contar evaluaciones con y sin cita asociada. Solo lectura; no muestra datos personales ni clinicos.

SELECT
    COUNT(*) AS total_evaluaciones,
    COUNT(appointment) AS evaluaciones_con_cita,
    COUNT(*) - COUNT(appointment) AS evaluaciones_sin_cita
FROM public.gnuhealth_patient_evaluation;


-- CONSULTA FINAL 3
-- Proposito: relacionar evaluaciones con citas y contar evaluaciones segun el estado de la cita asociada.
-- LEFT JOIN permite conservar las evaluaciones sin cita. Solo lectura; no muestra datos personales ni clinicos.

SELECT
    CASE
        WHEN a.id IS NULL THEN 'Sin cita vinculada'
        ELSE a.state
    END AS estado_cita,
    COUNT(*) AS total_evaluaciones
FROM public.gnuhealth_patient_evaluation AS e
LEFT JOIN public.gnuhealth_appointment AS a
    ON e.appointment = a.id
GROUP BY
    CASE
        WHEN a.id IS NULL THEN 'Sin cita vinculada'
        ELSE a.state
    END
ORDER BY estado_cita;
