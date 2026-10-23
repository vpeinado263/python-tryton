-- =====================================================================
-- Verificación de los pacientes de ejemplo de la imagen de GNU Health
-- Base: health50 | Solo lectura (únicamente SELECT y SHOW)
-- =====================================================================
-- Nota de confidencialidad: las consultas muestran identificadores y
-- cantidades, sin nombres de pacientes.

SET default_transaction_read_only = on;
SHOW default_transaction_read_only;   -- debe devolver "on"


-- ---------------------------------------------------------------------
-- V1. Una fila por paciente, con la cantidad de registros asociados
-- ---------------------------------------------------------------------
-- Resultado esperado: 24 filas, una por paciente.
-- Cuadre con los conteos conocidos de la base:
--   suma de turnos_reservados = 18
--   suma de evaluaciones      = 10
--   suma de condiciones       = 4
SELECT p.id    AS id_paciente,
       p.party AS id_persona,
       pp.gender AS genero,
       pp.dob    AS fecha_nacimiento,
       date_part('year', age(pp.dob))::int AS edad,
       (SELECT count(*) FROM gnuhealth_appointment a
         WHERE a.patient = p.id AND a.state <> 'free')       AS turnos_reservados,
       (SELECT count(*) FROM gnuhealth_patient_evaluation e
         WHERE e.patient = p.id)                             AS evaluaciones,
       (SELECT count(*) FROM gnuhealth_patient_disease d
         WHERE d.patient = p.id)                             AS condiciones,
       (SELECT count(*) FROM gnuhealth_patient_disease d
         WHERE d.patient = p.id AND d.hcop)                  AS condiciones_hcop,
       (SELECT count(*) FROM gnuhealth_surgery s
         WHERE s.patient = p.id)                             AS cirugias,
       (SELECT count(*) FROM gnuhealth_vaccination v
         WHERE v.patient = p.id)                             AS vacunas,
       (SELECT count(*) FROM gnuhealth_prescription_order r
         WHERE r.patient = p.id)                             AS recetas,
       (SELECT count(*) FROM gnuhealth_patient_lab_test l
         WHERE l.patient_id = p.id)                          AS laboratorio,
       (SELECT count(*) FROM gnuhealth_imaging_test_request i
         WHERE i.patient = p.id)                             AS imagenes
FROM gnuhealth_patient p
JOIN party_party pp ON pp.id = p.party
ORDER BY p.id;


-- ---------------------------------------------------------------------
-- V2. Pacientes frente al total de personas (party_party)
-- ---------------------------------------------------------------------
-- La tabla party_party guarda a todas las personas y organizaciones, no
-- solo a los pacientes: también profesionales e instituciones.
-- Resultado esperado: 24 pacientes, 24 personas distintas, 40 personas
-- en total y 16 personas que no son pacientes.
SELECT count(*)               AS pacientes,
       count(DISTINCT p.party) AS personas_distintas,
       (SELECT count(*) FROM party_party) AS personas_total,
       (SELECT count(*) FROM party_party pp
         WHERE NOT EXISTS (SELECT 1 FROM gnuhealth_patient x
                            WHERE x.party = pp.id))  AS personas_sin_paciente
FROM gnuhealth_patient p;
