
-- ACTIVIDAD 1: PRIMERAS CONSULTAS
-- Base de datos ficticia de prácticas.
-- Tabla utilizada: pacientes.

-- 1. Mostrar todos los registros de pacientes.
SELECT *
FROM pacientes;

-- 2. Mostrar únicamente identificador, nombre y fecha de nacimiento.
SELECT id, nombre, fecha_nacimiento
FROM pacientes;

-- 3. Filtrar pacientes activos.
SELECT *
FROM pacientes
WHERE activo = TRUE;

-- 4. Ordenar alfabéticamente por apellido y nombre.
SELECT id, nombre, apellido, fecha_nacimiento
FROM pacientes
ORDER BY apellido ASC, nombre ASC;

-- 5. Limitar los resultados a cinco pacientes.
SELECT *
FROM pacientes
ORDER BY id
LIMIT 5;
