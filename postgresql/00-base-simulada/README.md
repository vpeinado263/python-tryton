Objetivo
Practicar consultas SQL sobre una base de datos hospitalaria ficticia.
La Actividad 1 trabaja con consultas básicas; la Actividad 2 incorpora
relaciones entre tablas y consultas de resumen para obtener indicadores
sencillos.

Esta base es un entorno didáctico independiente de la instalación real
de GNU Health que se utiliza en la Actividad 3.
Entorno utilizado
- Motor: PostgreSQL 16, ejecutado en Docker.
- Contenedor: tryton-postgres.
- Base de datos: hospital_practice.
- Cliente SQL: DBeaver.
- Datos: exclusivamente ficticios, creados para practicar.
Estructura de archivos
La carpeta 00-base-simulada/ contiene los archivos necesarios para
crear y poblar la base de práctica:
- 00_esquema.sql: crea las tablas pacientes, profesionales y
  consultas.
- 01_datos_ficticios.sql: inserta los registros ficticios.
Las consultas de cada actividad se encuentran en:
- actividad-1-primeras-consultas/actividad_01.sql
- actividad-2-indicadores-hospitalarios/actividad_02.sql
Tablas utilizadas
- pacientes: identificador, nombre, apellido, fecha de
  nacimiento y estado de actividad.
- profesionales: identificador, nombre, apellido y especialidad.
- consultas: relaciona pacientes y profesionales con una fecha y
  un motivo de consulta.
Actividad 1: primeras consultas
El objetivo es practicar la consulta y presentación de registros. Las
cinco consultas permiten:
1. Mostrar todos los registros de pacientes.
2. Seleccionar únicamente el identificador, nombre y fecha de
   nacimiento.
3. Filtrar pacientes activos.
4. Ordenar pacientes por apellido y nombre.
5. Limitar la salida a cinco registros.
Cómo ejecutar la Actividad 1
1. Desde la carpeta que contiene docker-compose.yml, iniciar
   PostgreSQL:
   docker compose up -d
2. Abrir DBeaver y conectarse a la base hospital_practice.
3. Abrir actividad-1-primeras-consultas/actividad_01.sql.
4. Ejecutar cada consulta por separado y revisar los resultados.
5. Guardar capturas de pantalla que muestren las consultas y sus
   resultados como evidencia de la actividad.
Actividad 2: indicadores hospitalarios
El objetivo es practicar consultas que relacionan tablas y generan
resúmenes sencillos a partir de los datos ficticios.

Las seis consultas permiten:
1. Contar las consultas registradas para cada profesional.
2. Listar pacientes que tienen consultas, junto con información del
   profesional.
3. Identificar profesionales que no tienen consultas registradas.
4. Contar las consultas por especialidad.
5. Agrupar las consultas por mes.
6. Filtrar las especialidades que superan el umbral indicado mediante
   HAVING.
Cómo ejecutar la Actividad 2
1. Verificar que el contenedor tryton-postgres esté en ejecución.
2. Abrir DBeaver y conectarse a hospital_practice.
3. Abrir actividad-2-indicadores-hospitalarios/actividad_02.sql.
4. Ejecutar las consultas individualmente y revisar los resultados.
5. Guardar capturas de pantalla de las consultas y sus resultados.
6. Al interpretar los resultados mensuales, tener presente que octubre
   de 2026 contiene registros solo hasta el 5 de octubre en los datos
   de práctica; por lo tanto, ese mes está incompleto.
Preparación inicial de la base
Si las tablas todavía no existen en hospital_practice, ejecutar los
archivos en este orden:
1. 00-base-simulada/00_esquema.sql
2. 00-base-simulada/01_datos_ficticios.sql
Ambos archivos deben ejecutarse usando la conexión a la base
hospital_practice.