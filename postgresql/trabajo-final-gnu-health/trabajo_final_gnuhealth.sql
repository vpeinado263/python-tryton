-- Trabajo práctico final: PostgreSQL aplicado a GNU Health
-- Proceso analizado: Atención ambulatoria (turno - evaluación - diagnóstico CIE-10)

-- Entorno de laboratorio:
--  Base: health50 | Usuario: gnuhealth
--  PostgreSQL 15.13 (Debian 12) | GNU Health 5.0.0 | Tryton (trytond) 7.0.33

-- Precauciones de integridad y confidencialidad:
--   * Este archivo contiene únicamente sentencias SELECT y SHOW.
--   * La sesión se pone en solo lectura (ver Parte 0).
--   * Las consultas muestran identificadores numéricos de pacientes y profesionales; no consultan nombres, fotos ni datos de contacto.
--   * No se ejecuta nada sobre bases de producción.

-- PARTE 0. Protección de la sesión

SET default_transaction_read_only = on;

-- Verificación: debe devolver "on". 
SHOW default_transaction_read_only;
-- Impide INSERT, UPDATE, DELETE y DDL (Lenguaje de Definición de Datos) durante esta sesión.

-----------------------------------------------------
-- PARTE 1. Relevamiento del entorno y del esquema --
-----------------------------------------------------

--# 1.1 Versión de PostgreSQL, base y usuario conectados.

SELECT version();
SELECT current_database() AS base, current_user AS usuario;

--# 1.2 Cantidad de filas de las tablas del proceso.

SELECT 'gnuhealth_patient' AS tabla, count(*) AS filas FROM gnuhealth_patient
UNION ALL SELECT 'gnuhealth_appointment', count(*) FROM gnuhealth_appointment
UNION ALL SELECT 'gnuhealth_patient_evaluation', count(*) FROM gnuhealth_patient_evaluation
UNION ALL SELECT 'gnuhealth_patient_disease', count(*) FROM gnuhealth_patient_disease
UNION ALL SELECT 'gnuhealth_pathology', count(*) FROM gnuhealth_pathology
UNION ALL SELECT 'gnuhealth_healthprofessional', count(*) FROM gnuhealth_healthprofessional
UNION ALL SELECT 'party_party', count(*) FROM party_party;

--# 1.3 Columnas de las tablas del proceso (una fila por tabla).
-- En gnuhealth_patient_evaluation se listan solo las columnas relevantes.

SELECT table_name,
       string_agg(column_name || ' (' || data_type || ')', ', '
                  ORDER BY ordinal_position) AS columnas
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (table_name IN ('gnuhealth_appointment', 'gnuhealth_healthprofessional',
                      'gnuhealth_pathology', 'gnuhealth_patient_disease')
       OR (table_name = 'gnuhealth_patient_evaluation'
           AND column_name IN ('id', 'patient', 'appointment', 'healthprof',
                'evaluation_start', 'evaluation_endtime', 'state',
                'evaluation_type', 'visit_type', 'chief_complaint',
                'diagnosis', 'info_diagnosis', 'systolic', 'diastolic', 'bpm',
                'temperature', 'weight', 'height', 'bmi', 'specialty',
                'urgency', 'institution', 'related_condition',
                'next_evaluation', 'signed_by')))
GROUP BY table_name
ORDER BY table_name;

--# 1.4 Claves primarias (Primary Key).

SELECT tc.table_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_name IN ('gnuhealth_appointment', 'gnuhealth_patient_evaluation',
        'gnuhealth_patient_disease', 'gnuhealth_pathology',
        'gnuhealth_healthprofessional', 'gnuhealth_patient', 'party_party')
ORDER BY tc.table_name;

--# 1.5 Claves foráneas (Foreign Key) entre las tablas del proceso.

SELECT c.conrelid::regclass  AS tabla_origen,
       a.attname             AS columna_origen,
       c.confrelid::regclass AS tabla_destino,
       af.attname            AS columna_destino,
       c.conname             AS restriccion
FROM pg_constraint c
JOIN pg_attribute a  ON a.attrelid  = c.conrelid  AND a.attnum  = ANY(c.conkey)
JOIN pg_attribute af ON af.attrelid = c.confrelid AND af.attnum = ANY(c.confkey)
WHERE c.contype = 'f'
  AND c.conrelid::regclass::text IN ('gnuhealth_appointment',
        'gnuhealth_patient_evaluation', 'gnuhealth_patient_disease',
        'gnuhealth_patient', 'gnuhealth_healthprofessional')
  AND c.confrelid::regclass::text IN ('gnuhealth_appointment',
        'gnuhealth_patient_evaluation', 'gnuhealth_patient_disease',
        'gnuhealth_patient', 'gnuhealth_healthprofessional',
        'gnuhealth_pathology', 'party_party')
ORDER BY tabla_origen, columna_origen;

-----------------------------------
-- PARTE 2. Consultas analíticas --
-----------------------------------
-- Nota general sobre los datos: en gnuhealth_appointment el estado 'free'
-- representa franjas libres de la agenda, no atenciones realizadas.
-- Para analizar atenciones se filtra state <> 'free'.

------------------------------------------------------------------------------------
-- C1. Turnos reservados, del más reciente al más antiguo (filtro + ordenamiento) --
------------------------------------------------------------------------------------

-- OBJETIVO: listar los turnos que ya fueron tomados por un paciente.
-- TABLAS: gnuhealth_appointment
-- LIMITACIÓN: la cantidad de turnos reservados es pequeña frente a las franjas libres; la columna state puede cambiar con el uso.

SELECT a.id                AS id_turno,
       a.appointment_date  AS fecha_turno,
       a.state             AS estado,
       a.appointment_type  AS tipo_turno,
       a.urgency           AS urgencia,
       a.patient           AS id_paciente,
       a.healthprof        AS id_profesional
FROM gnuhealth_appointment a
WHERE a.state <> 'free'
ORDER BY a.appointment_date DESC, a.id;

----------------------------------------------------------------------------
-- C2. Evaluaciones con presión sistólica elevada (filtro + ordenamiento) --
----------------------------------------------------------------------------

-- OBJETIVO: identificar evaluaciones con presión sistólica >= 130 mmHg (umbral de referencia, ajustable).
-- TABLAS: gnuhealth_patient_evaluation
-- LIMITACIÓN: hay pocas evaluaciones en la base y algunas pueden no tener el dato cargado; un valor nulo no cumple el filtro.

SELECT e.id               AS id_evaluacion,
       e.patient          AS id_paciente,
       e.evaluation_start AS fecha_evaluacion,
       e.systolic         AS sistolica,
       e.diastolic        AS diastolica,
       e.bpm              AS frecuencia_cardiaca
FROM gnuhealth_patient_evaluation e
WHERE e.systolic >= 130
ORDER BY e.systolic DESC, e.evaluation_start DESC;

-------------------------------------------------------
-- C3. Evaluaciones con su diagnóstico CIE-10 (JOIN) --
-------------------------------------------------------

-- OBJETIVO: relacionar cada evaluación con el diagnóstico del catálogo.
-- TABLAS: gnuhealth_patient_evaluation, gnuhealth_pathology (clave: evaluation.diagnosis -> pathology.id)
-- LIMITACIÓN: INNER JOIN; las evaluaciones sin diagnóstico no aparecen.

SELECT e.id               AS id_evaluacion,
       e.patient          AS id_paciente,
       e.evaluation_start AS fecha_evaluacion,
       p.code             AS codigo_cie10,
       p.name             AS diagnostico
FROM gnuhealth_patient_evaluation e
JOIN gnuhealth_pathology p ON p.id = e.diagnosis
ORDER BY e.evaluation_start DESC;

---------------------------------------------------------------------
-- C4. Turnos reservados con su profesional y su evaluación (JOIN) --
---------------------------------------------------------------------

-- OBJETIVO: ver qué turnos reservados llegaron a tener una evaluación.
-- TABLAS: gnuhealth_appointment, gnuhealth_healthprofessional, gnuhealth_patient_evaluation 
--(claves: appointment.healthprof -> healthprofessional.id; evaluation.appointment -> appointment.id)
-- LIMITACIÓN: ambos son LEFT JOIN. id_evaluacion nulo indica que el turno no tiene evaluación
-- asociada; codigo_profesional nulo indica que el turno no tiene profesional asignado (2 casos).
-- Con INNER JOIN esos turnos no aparecerían. El profesional se identifica por su código.

SELECT a.id               AS id_turno,
       a.appointment_date AS fecha_turno,
       a.state            AS estado,
       hp.code            AS codigo_profesional,
       e.id               AS id_evaluacion
FROM gnuhealth_appointment a
LEFT JOIN gnuhealth_healthprofessional hp ON hp.id = a.healthprof
LEFT JOIN gnuhealth_patient_evaluation e ON e.appointment = a.id
WHERE a.state <> 'free'
ORDER BY a.appointment_date;

------------------------------------------------------------------
-- C5. Turnos por estado con porcentaje (agregación + GROUP BY) --
------------------------------------------------------------------

-- OBJETIVO: conocer la distribución de la agenda por estado.
-- TABLAS: gnuhealth_appointment
-- LIMITACIÓN: el estado 'free' domina el total porque representa franjas sin reservar; interpretar el porcentaje con ese contexto.

SELECT a.state AS estado,
       count(*) AS cantidad,
       round(100.0 * count(*) / sum(count(*)) OVER (), 2) AS porcentaje
FROM gnuhealth_appointment a
GROUP BY a.state
ORDER BY cantidad DESC;

------------------------------------------------------------------------
-- C6. Ocupación de la agenda por profesional (agregación + GROUP BY) --
------------------------------------------------------------------------

-- OBJETIVO: comparar franjas totales, libres y reservadas por profesional.
-- TABLAS: gnuhealth_appointment
-- LIMITACIÓN: todas las franjas, salvo 2, pertenecen a un único profesional, por lo que no permite 
--comparar entre profesionales; la fila con id_profesional vacío corresponde a turnos sin profesional asignado.

SELECT a.healthprof AS id_profesional,
       count(*) AS franjas_totales,
       count(*) FILTER (WHERE a.state = 'free')  AS libres,
       count(*) FILTER (WHERE a.state <> 'free') AS reservadas,
       round(100.0 * count(*) FILTER (WHERE a.state <> 'free') / count(*), 2)
           AS porcentaje_ocupacion
FROM gnuhealth_appointment a
GROUP BY a.healthprof
ORDER BY franjas_totales DESC;

---------------------------------------------------------------
-- C7. Clasificación de la presión arterial (expresión CASE) --
---------------------------------------------------------------

-- OBJETIVO: clasificar cada evaluación según su presión arterial según parámetros médicos actuales de Argentina y la OMS ("umbrales de referencia simplificados".).
-- TABLAS: gnuhealth_patient_evaluation
-- LIMITACIÓN: clasificación simplificada con fines de análisis de datos; no reemplaza el criterio clínico. Las evaluaciones sin dato se informan como 'Sin dato'.

SELECT e.id          AS id_evaluacion,
       e.patient     AS id_paciente,
       e.systolic    AS sistolica,
       e.diastolic   AS diastolica,
       CASE
           -- 1. Validación de nulos
           WHEN e.systolic IS NULL OR e.diastolic IS NULL THEN 'Sin dato'
           
           -- 2. Alta (Hipertensión): >= 140 máx ó >= 90 mín
           WHEN e.systolic >= 140 OR e.diastolic >= 90 THEN 'Alta'
           
           -- 3. Normal Alta / Limítrofe: 130-139 máx ó 85-89 mín
           WHEN (e.systolic BETWEEN 130 AND 139) OR (e.diastolic BETWEEN 85 AND 89) THEN 'Normal Alta'
           
           -- 4. Baja (Hipotensión): < 90 máx ó < 60 mín
           WHEN e.systolic < 90 OR e.diastolic < 60 THEN 'Baja'
           
           -- 5. Normal / Óptima: El resto de los valores intermedios
           ELSE 'Normal'
       END AS clasificacion_presion
FROM gnuhealth_patient_evaluation e
ORDER BY e.evaluation_start DESC;

-------------------------------------------------------------------
-- C8. Turnos reservados sin evaluación (subconsulta NOT EXISTS) --
-------------------------------------------------------------------

-- OBJETIVO: detectar turnos tomados que no tienen evaluación registrada, útil para revisar el cierre del proceso de atención.
-- TABLAS: gnuhealth_appointment, gnuhealth_patient_evaluation
-- LIMITACIÓN: un turno en estado 'confirmed' puede no tener evaluación simplemente porque la atención todavía no ocurrió.

SELECT a.id               AS id_turno,
       a.appointment_date AS fecha_turno,
       a.state            AS estado,
       a.patient          AS id_paciente
FROM gnuhealth_appointment a
WHERE a.state <> 'free'
  AND NOT EXISTS (
        SELECT 1
        FROM gnuhealth_patient_evaluation e
        WHERE e.appointment = a.id)
ORDER BY a.appointment_date;

------------------------
-- C9. Turnos por mes --
------------------------

-- OBJETIVO: ver cómo se distribuyen las franjas y las reservas en el tiempo.
-- TABLAS: gnuhealth_appointment
-- LIMITACIÓN: depende del rango de fechas con que se cargó la agenda; los meses sin turnos no aparecen en el resultado.

SELECT date_trunc('month', a.appointment_date)::date AS mes,
       count(*) AS franjas_totales,
       count(*) FILTER (WHERE a.state <> 'free') AS reservadas
FROM gnuhealth_appointment a
GROUP BY 1
ORDER BY 1;