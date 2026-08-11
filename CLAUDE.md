# hilo-conductor-redes-ataques

Etapas 1 (`crud-stress-test`), 3 (`crud-ataques-red`) y 4 (`crud-sqli`) del hilo conductor de
redes de Infraestructura de Redes (`la-cajonera`), sacadas de ahí porque Killercoda bloqueó
la cuenta docente el 2026-08-10 por "security scanners, bruteforce or hacker-tools" —
exactamente lo que `ab`/`nmap`/`hydra`/`sqlmap` son (categorías, no intensidad: el mail de
desbloqueo aclara que no pueden diferenciar uso legítimo de malicioso, así que ni siquiera
una versión liviana de estas herramientas es segura en su plataforma). Detalle completo del
incidente en `NOTAS-DOCENTE.md`.

**Este repo reemplaza Killercoda para estas tres etapas**, cada una con su propio entorno:

- `crud-ataques-red/` y `crud-sqli/` comparten el `docker-compose.yml`/`Dockerfile` de la
  raíz: MySQL + PhpMyAdmin + la app CRUD dockerizada (branch `feature-login` de
  [`pablopedernera0/crud-python`](https://github.com/pablopedernera0/crud-python)).
- `crud-stress-test/` tiene su **propio** `docker-compose.yml` (solo MySQL + PhpMyAdmin,
  MySQL expuesto en `localhost:3306`) — la app va sin dockerizar, como proceso suelto
  (branch `main`, sin login), porque el ejercicio depende de matarla y reiniciarla con otro
  servidor WSGI (`python3 app.py` vs. `gunicorn`). Ver su propio `README.md`.

Ningún caso depende de plataformas de terceros con detección de abuso.

## Estado (ver también `NOTAS-DOCENTE.md` para el detalle completo)

- `crud-stress-test/`: **armado, adaptado y probado end-to-end** (compose up, app bare,
  `ab` real, dev server vs. Gunicorn) — confirmado funcionando de punta a punta.
- Entorno de `crud-ataques-red`/`crud-sqli` (raíz del repo): **armado y probado
  end-to-end** (2026-08-11). El build de la imagen `app` necesita salir a internet
  (`git clone`/`apt-get`); en redes con proxy corporativo hace falta exportar
  `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` antes de `docker compose up --build` — el
  `Dockerfile`/`docker-compose.yml` ya lo soportan (`ARG`/`build.args`, default vacío, no
  afecta a quien no esté detrás de un proxy). Documentado en el `README.md` de la raíz.
- Contenido pedagógico de `crud-ataques-red/`, `crud-sqli/`: **adaptado** a "tu propia
  terminal contra `localhost`" (completado 2026-08-11) — ya no quedan referencias a
  `/root/setup.sh` ni a la UI de Killercoda. Se sacaron también `index.json` y
  `assets/setup.sh` de ambas carpetas (artefactos de Killercoda sin uso acá). Reconocimiento
  y bypass manual probados en vivo contra el stack real; `hydra` y `sqlmap` en sí (los
  comandos no cambiaron) no se re-probaron en esta sesión por no tener esas herramientas
  instaladas en la máquina de desarrollo usada — pendiente confirmarlo una vez con cada una
  instalada. Detalle completo, incluido un hallazgo real de `nmap` que corrigió el paso 1 de
  `crud-ataques-red`, en `NOTAS-DOCENTE.md`.
- Visibilidad: **público** (pasado el 2026-08-10), los alumnos ya lo pueden clonar.

## Convenciones

Válidas para `crud-ataques-red/`/`crud-sqli/` (raíz del repo):

- MySQL se referencia por **nombre de servicio** (`mysql`), no por IP + `sed` como en la
  versión de Killercoda — Docker Compose resuelve el nombre por DNS interno.
- Las tablas se siembran vía `init.sql` montado en `/docker-entrypoint-initdb.d/`
  (mecanismo nativo de la imagen oficial de MySQL, corre una sola vez).
- La app va dockerizada acá (a diferencia de Killercoda, donde corría como proceso Python
  suelto sobre una imagen `ubuntu`) — necesario porque la máquina del alumno es heterogénea.
- Antes de dar por cerrado un cambio, probar `docker compose up -d --build` de punta a
  punta, no alcanza con revisar el YAML/Dockerfile a ojo (ver
  `feedback-test-scenarios-locally` en la memoria del proyecto hermano `la-cajonera`).

`crud-stress-test/` es la excepción deliberada a los dos primeros puntos: MySQL se expone
en `localhost:3306` (no por nombre de servicio) y la app **no** va dockerizada, corre como
proceso suelto — porque el ejercicio necesita matarla y reiniciarla con otro servidor WSGI
sin tocar contenedores. No "corregir" esto para que coincida con el resto del repo.
