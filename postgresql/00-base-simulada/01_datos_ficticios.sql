
-- Datos para practicar SQL.

INSERT INTO pacientes (nombre, apellido, fecha_nacimiento, activo)
VALUES
    ('Homero', 'Simpson', '1990-04-12', TRUE),
    ('Ned', 'Flanders', '1985-09-23', TRUE),
    ('Moe ', 'Szyslak', '2001-02-08', TRUE),
    ('Seymour', 'Skinner', '1978-11-30', FALSE),
    ('Charles', 'Montgomery Burns', '1995-06-17', TRUE),
    ('Milhouse ', 'Van Houten', '1969-01-05', TRUE),
    ('Apu', 'Nahasapeemapetilon', '2010-08-21', TRUE),
    ('Hyman', 'Krustofsky', '1988-12-14', FALSE);

INSERT INTO profesionales (nombre, apellido, especialidad)
VALUES
    ('Laura', 'Silva', 'Clinica medica'),
    ('Pablo', 'Ruiz', 'Cardiologia'),
    ('Marta', 'Castro', 'Pediatria'),
    ('Jorge', 'Molina', 'Clinica medica');

INSERT INTO consultas
    (paciente_id, profesional_id, fecha_consulta, motivo)
VALUES
    (1, 1, '2026-09-01', 'Control general'),
    (2, 2, '2026-09-02', 'Control cardiologico'),
    (3, 3, '2026-09-03', 'Consulta pediatrica'),
    (1, 2, '2026-09-10', 'Seguimiento'),
    (5, 1, '2026-09-12', 'Control general'),
    (6, 4, '2026-09-15', 'Consulta clinica'),
    (7, 3, '2026-10-01', 'Control pediatrico'),
    (2, 1, '2026-10-05', 'Seguimiento');
