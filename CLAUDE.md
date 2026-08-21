# hilo-conductor-redes-ataques

Etapas 1 (`crud-stress-test`), 3 (`crud-ataques-red`) y 4 (`crud-sqli`) del hilo conductor de
redes de Infraestructura de Redes (`la-cajonera`), sacadas de ahí porque Killercoda bloqueó
la cuenta docente el 2026-08-10 por "security scanners, bruteforce or hacker-tools" —
exactamente lo que `ab`/`nmap`/`hydra`/`sqlmap` son (categorías, no intensidad: el mail de
desbloqueo aclara que no pueden diferenciar uso legítimo de malicioso, así que ni siquiera
una versión liviana de estas herramientas es segura en su plataforma). Detalle completo del
incidente en `NOTAS-DOCENTE.md`.

**Este repo reemplaza Killercoda para estas tres etapas**, cada una con su propio entorno:

- `crud-ataques-red/` y `crud-sqli/` comparten el `docker-compose.yml`/`Dockerfile` de
  `entorno-ataques/`: MySQL + PhpMyAdmin + la app CRUD dockerizada (branch `feature-login` de
  [`pablopedernera0/crud-python`](https://github.com/pablopedernera0/crud-python)) +
  `toolbox` (`toolbox/Dockerfile`: `nmap`/`hydra`/`sqlmap`/cliente `mysql`, en la misma red
  interna, se queda esperando comandos con `docker compose exec toolbox <comando>`) — así el
  alumno tampoco necesita instalar esas herramientas, solo Docker.
- `crud-stress-test/` tiene su **propio** `docker-compose.yml` (solo MySQL + PhpMyAdmin,
  MySQL expuesto en `localhost:3306`) — la app va sin dockerizar, como proceso suelto
  (branch `main`, sin login), porque el ejercicio depende de matarla y reiniciarla con otro
  servidor WSGI (`python3 app.py` vs. `gunicorn`). Ver su propio `README.md`. No usa
  `toolbox`: `ab` corre en la terminal del alumno.

Ningún caso depende de plataformas de terceros con detección de abuso.

## Estado (ver también `NOTAS-DOCENTE.md` para el detalle completo)

- `crud-stress-test/`: **armado, adaptado y probado end-to-end** (compose up, app bare,
  `ab` real, dev server vs. Gunicorn) — confirmado funcionando de punta a punta.
- Entorno de `crud-ataques-red`/`crud-sqli` (`entorno-ataques/`): **armado y probado
  end-to-end** (2026-08-11). El build de la imagen `app` necesita salir a internet
  (`git clone`/`apt-get`); en redes con proxy corporativo hace falta exportar
  `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` antes de `docker compose up --build` — el
  `Dockerfile`/`docker-compose.yml` ya lo soportan (`ARG`/`build.args`, default vacío, no
  afecta a quien no esté detrás de un proxy). Documentado en el `README.md` de
  `entorno-ataques/`.
  **2026-08-20/21: la infraestructura suelta (`docker-compose.yml`, `Dockerfile`, `init.sql`,
  `toolbox/`) se mudó de la raíz del repo a su propia carpeta, `entorno-ataques/`** — mismo
  patrón autocontenido que `crud-stress-test/`. Motivo: un `docker-compose.yml` suelto al
  lado de dos carpetas de contenido invitaba a confundirlo con "el compose de todo el repo",
  y de hecho causó un bug real (ver más abajo, "colisión de puertos").
- Contenido pedagógico de `crud-ataques-red/`, `crud-sqli/`: **adaptado y probado
  end-to-end** (completado 2026-08-11) — ya no quedan referencias a `/root/setup.sh`, la UI
  de Killercoda, ni a instalar herramientas en la máquina del alumno. Se sacaron también
  `index.json` y `assets/setup.sh` de ambas carpetas (artefactos de Killercoda sin uso acá).
  Todos los pasos, **incluidos `hydra` y `sqlmap`** (antes sin probar por no tener esas
  herramientas instaladas localmente), corridos en vivo contra el stack real vía el
  contenedor `toolbox`. Detalle completo, incluido un hallazgo real de `nmap` que corrigió el
  paso 1 de `crud-ataques-red` y un bug real de proxy persistiendo en runtime, en
  `NOTAS-DOCENTE.md`.
- Visibilidad: **público** (pasado el 2026-08-10), los alumnos ya lo pueden clonar.

## Convenciones

**Nunca corras `entorno-ataques/` y `crud-stress-test/` al mismo tiempo.** Comparten el
puerto 8888 (y `crud-stress-test/` también expone MySQL en el 3306) — si ambos entornos están
arriba a la vez, el tráfico de uno puede terminar pegándole a la app del otro sin ningún error
visible (un `POST` que "funciona" según `ab`/`curl` pero nunca llega a la base correcta), y
comandos con `docker ps -qf "name=mysql"` o `"name=app"` pueden matchear el contenedor
equivocado por substring (mismo bug de colisión por nombre que ya estaba documentado para el
`mysqld-exporter` de la Etapa 6 en `la-cajonera`). Bug real, reproducido en vivo el
2026-08-20/21 — ver `NOTAS-DOCENTE.md`. Antes de levantar uno, bajar el otro con `docker compose down` desde su propia carpeta —
cada entorno tiene su propio `docker-compose.yml` independiente.

Válidas para `crud-ataques-red/`/`crud-sqli/` (`entorno-ataques/`):

- MySQL se referencia por **nombre de servicio** (`mysql`), no por IP + `sed` como en la
  versión de Killercoda — Docker Compose resuelve el nombre por DNS interno.
- Las tablas se siembran vía `init.sql` montado en `/docker-entrypoint-initdb.d/`
  (mecanismo nativo de la imagen oficial de MySQL, corre una sola vez).
- La app va dockerizada acá (a diferencia de Killercoda, donde corría como proceso Python
  suelto sobre una imagen `ubuntu`) — necesario porque la máquina del alumno es heterogénea.
- Herramientas de ataque (`nmap`/`hydra`/`sqlmap`/cliente `mysql`) van en el contenedor
  `toolbox`, no se le pide al alumno que las instale — mismo criterio que la app dockerizada:
  no asumir nada del sistema operativo de quien corre esto. Si se agrega una herramienta
  nueva a una práctica futura, va ahí también, no a un requisito de instalación en el README.
- Cualquier `Dockerfile` que reciba `ARG`/`ENV` de proxy para el build (`HTTP_PROXY` etc.)
  tiene que **limpiarlos después** (`ENV http_proxy="" ...` antes del `CMD`) — si quedan
  activos en runtime, herramientas como `curl`/`sqlmap`/`hydra` intentan salir por ese proxy
  para pedidos que deberían quedarse en la red interna de Docker, y fallan. Bug real,
  encontrado y corregido en `toolbox/Dockerfile` y `Dockerfile` — ver `NOTAS-DOCENTE.md`.
- Antes de dar por cerrado un cambio, probar `docker compose up -d --build` de punta a
  punta, no alcanza con revisar el YAML/Dockerfile a ojo (ver
  `feedback-test-scenarios-locally` en la memoria del proyecto hermano `la-cajonera`).

`crud-stress-test/` es la excepción deliberada a los dos primeros puntos: MySQL se expone
en `localhost:3306` (no por nombre de servicio) y la app **no** va dockerizada, corre como
proceso suelto — porque el ejercicio necesita matarla y reiniciarla con otro servidor WSGI
sin tocar contenedores. No "corregir" esto para que coincida con el resto del repo.
