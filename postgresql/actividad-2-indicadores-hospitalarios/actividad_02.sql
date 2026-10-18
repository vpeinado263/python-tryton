-- ACTIVIDAD PRACTICA 2: INDICADORES HOSPITALARIOS
-- Base de datos: hospital_practice


-- 1. Obtener la cantidad de consultas por profesional.

SELECT
    p.id,
    p.nombre,
    p.apellido,
    COUNT(c.id) AS cantidad_consultas
FROM profesionales AS p
LEFT JOIN consultas AS c
    ON c.profesional_id = p.id
GROUP BY p.id, p.nombre, p.apellido
ORDER BY cantidad_consultas DESC, p.apellido ASC;

-- 2. Listar pacientes con sus consultas registradas.

SELECT
    pa.id AS paciente_id,
    pa.nombre AS paciente_nombre,
    pa.apellido AS paciente_apellido,
    c.id AS consulta_id,
    c.fecha_consulta,
    c.motivo,
    p.nombre AS profesional_nombre,
    p.apellido AS profesional_apellido
FROM pacientes AS pa
INNER JOIN consultas AS c
    ON c.paciente_id = pa.id
INNER JOIN profesionales AS p
    ON p.id = c.profesional_id
ORDER BY pa.apellido, pa.nombre, c.fecha_consulta;

-- 3. Identificar profesionales sin consultas asociadas.

SELECT
    p.id,
    p.nombre,
    p.apellido,
    p.especialidad
FROM profesionales AS p
LEFT JOIN consultas AS c
    ON c.profesional_id = p.id
WHERE c.id IS NULL
ORDER BY p.apellido, p.nombre;

-- 4. Contar consultas por especialidad.

SELECT
    p.especialidad,
    COUNT(c.id) AS cantidad_consultas
FROM profesionales AS p
LEFT JOIN consultas AS c
    ON c.profesional_id = p.id
GROUP BY p.especialidad
ORDER BY cantidad_consultas DESC, p.especialidad ASC;

-- 5. Obtener la cantidad de consultas por mes.

SELECT
    DATE_TRUNC('month', fecha_consulta)::date AS mes,
    COUNT(*) AS cantidad_consultas
FROM consultas
GROUP BY DATE_TRUNC('month', fecha_consulta)
ORDER BY mes;


-- 6. Mostrar especialidades que superan una cantidad

SELECT
    p.especialidad,
    COUNT(c.id) AS cantidad_consultas
FROM profesionales AS p
INNER JOIN consultas AS c
    ON c.profesional_id = p.id
GROUP BY p.especialidad
HAVING COUNT(c.id) > 2
ORDER BY cantidad_consultas DESC;


