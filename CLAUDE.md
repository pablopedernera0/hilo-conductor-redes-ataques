# hilo-conductor-redes-ataques

Etapas 3 (`crud-ataques-red`) y 4 (`crud-sqli`) del hilo conductor de redes de
Infraestructura de Redes (`la-cajonera`), sacadas de ahí el 2026-08-10 porque Killercoda
bloqueó la cuenta docente por "security scanners, bruteforce or hacker-tools" —
exactamente lo que `nmap`/`hydra`/`sqlmap` son. Detalle completo del incidente en
`NOTAS-DOCENTE.md`.

**Este repo reemplaza Killercoda para estas dos etapas:** el alumno clona el repo y corre
`docker-compose up -d --build` en su propia máquina — mismo `docker-compose.yml`/`Dockerfile`
levantan MySQL + PhpMyAdmin + la app CRUD (branch `feature-login` de
[`pablopedernera0/crud-python`](https://github.com/pablopedernera0/crud-python)), sin
ninguna plataforma de terceros de por medio.

## Estado (ver también `NOTAS-DOCENTE.md` para el detalle completo)

- Entorno base: **armado y probado parcialmente**. MySQL + PhpMyAdmin + `init.sql` +
  resolución de `mysql` por DNS interno de Docker Compose: confirmado funcionando. El build
  de la imagen `app` (necesita salir a internet para `git clone`/`apt-get`) no se pudo
  probar en la máquina de desarrollo usada — sin salida a internet desde contenedores ahí.
  Pendiente confirmación en una máquina normal.
- Contenido pedagógico (`crud-ataques-red/`, `crud-sqli/`): todavía en **formato
  Killercoda** (asume `/root/setup.sh`, rutas de esa sandbox) — falta adaptarlo a "tu propia
  terminal contra `localhost`". Los comandos de `nmap`/`hydra`/`sqlmap` en sí no cambian.
- Visibilidad: **privado hoy**, tiene que pasar a público (o accesible a todo el curso)
  para que los alumnos lo puedan clonar — pendiente de decidir cuándo.

## Convenciones

- MySQL se referencia por **nombre de servicio** (`mysql`), no por IP + `sed` como en la
  versión de Killercoda — Docker Compose resuelve el nombre por DNS interno.
- Las tablas se siembran vía `init.sql` montado en `/docker-entrypoint-initdb.d/`
  (mecanismo nativo de la imagen oficial de MySQL, corre una sola vez).
- La app va dockerizada acá (a diferencia de Killercoda, donde corría como proceso Python
  suelto sobre una imagen `ubuntu`) — necesario porque la máquina del alumno es heterogénea.
- Antes de dar por cerrado un cambio, probar `docker compose up -d --build` de punta a
  punta, no alcanza con revisar el YAML/Dockerfile a ojo (ver
  `feedback-test-scenarios-locally` en la memoria del proyecto hermano `la-cajonera`).
