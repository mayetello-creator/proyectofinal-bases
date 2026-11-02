# Proyecto Final de Bases de Datos — EPS Villavicencio

Sistema de reserva de citas médicas desarrollado con PHP y PostgreSQL, sin framework.

## Requisitos

- Linux
- PHP 7 o superior con las extensiones `pdo` y `pdo_pgsql`
- PostgreSQL y permiso para habilitar la extensión `btree_gist` usada por el SQL

## Primera instalación local

1. Cree una base de datos vacía llamada `eps_villavicencio`. Por ejemplo: `sudo -u postgres createdb eps_villavicencio`.
2. Importe el archivo SQL una sola vez: `sudo -u postgres psql -d eps_villavicencio -f proyecto.sql`. El SQL crea tablas, relaciones, reglas, disparadores y datos de demostración.
3. Configure `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASSWORD`, o use `DATABASE_URL`. El valor `DB_PASSWORD` debe coincidir con la contraseña del usuario PostgreSQL.
4. Desde `eps_citas_php`, inicie PHP: `php -S 127.0.0.1:8000`. Abra `http://127.0.0.1:8000`.

Si desea introducir la contraseña sin escribirla en el comando, en Bash puede usar `read -s -p "Clave de PostgreSQL: " DB_PASSWORD; export DB_PASSWORD; echo` antes de iniciar PHP.

## Módulos

- Resumen de afiliados, citas y horarios.
- Registro, actualización y consulta de afiliados.
- Registro y actualización de médicos, consultorios/salas y horarios.
- Reserva de citas seleccionando médico, fecha y hora disponible.
- Consulta de citas, marcado de atención y eliminación con liberación del horario.

## Reglas destacadas

- CC, TI y RC: solo dígitos, máximo 10. CE y PA: letras y dígitos, máximo 20.
- Nombres: no aceptan números.
- Ingresos y capacidad: no pueden ser negativos.
- Las citas toman su valor del costo del servicio y la tarifa del afiliado.
- Los disparadores del proyecto permanecen en `proyecto.sql`.
