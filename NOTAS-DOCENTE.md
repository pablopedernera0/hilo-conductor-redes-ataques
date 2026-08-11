# Notas para el docente (no es material para el alumno)

## Por qué existe este repo

Etapas 1 (`crud-stress-test`), 3 (`crud-ataques-red`) y 4 (`crud-sqli`) del hilo conductor de
redes, originalmente escritas para Killercoda. El 2026-08-10, corriendo `ab` (Apache Bench,
Etapa 1) la cuenta de Killercoda `pablop22` quedó bloqueada por "illegal activity...
cryptominers, security scanners, bruteforce or hacker-tools". `nmap` (security scanner),
`hydra` (bruteforce) y `sqlmap` (hacker-tool) caen exactamente en esas categorías, así que
las Etapas 3 y 4 se sacaron de `la-cajonera` como precaución.

`security@killercoda.com` respondió el mismo día desbloqueando la cuenta, pero con una
condición explícita: prohíben esas categorías de herramientas por nombre, aclarando que
**no pueden diferenciar uso legítimo de malicioso** — es decir, no es un tema de intensidad
de la carga. Eso confirmó que la Etapa 1 necesitaba el mismo tratamiento que 3 y 4, aunque
la primera corrida liviana de `ab` no hubiera disparado nada: correrla de nuevo, aunque sea
suave, seguía siendo la misma categoría de herramienta prohibida. Por eso también se sacó y
se sumó acá.

Se armó este entorno con `docker-compose` para que cada alumno lo corra en su propia
máquina — sin depender de ninguna plataforma de terceros con detección de abuso.

## Decisión: Etapa 1 dividida en liviana + realista

En vez de sacar toda la Etapa 1 de Killercoda, se dividió en dos:

- **Liviana** (se queda en Killercoda, `la-cajonera/crud-stress-test`): mide los mismos
  conceptos (throughput, latencia, concurrencia, tasa de error) con un loop de `curl` en vez
  de `ab` — no invoca una herramienta que Killercoda nombra por categoría.
- **Realista** (acá, `crud-stress-test/`): la carga real con `ab` que rompía la app y
  mostraba la diferencia entre Flask dev server y Gunicorn — se mudó tal cual, sin
  suavizarla, porque suavizarla no hubiera evitado el problema (ver arriba).

Así, el alumno sin PC propia puede seguir la práctica liviana en Killercoda, y el que tiene
PC hace la prueba de carga real en su máquina. El docente explica el motivo (restricción de
seguridad de Killercoda) y puede mostrar la corrida real desde su propia computadora si hace
falta.

## Estado

- [x] Entorno de `crud-ataques-red`/`crud-sqli` (`docker-compose.yml`, `Dockerfile`,
      `init.sql`) — probado end-to-end localmente
- [x] Entorno y contenido de `crud-stress-test/` — armado, adaptado y probado end-to-end
      localmente (compose up, app bare, `ab` real, dev server vs. Gunicorn)
- [x] Versión liviana de la Etapa 1 en `la-cajonera/crud-stress-test` (con `curl`)
- [x] **Adaptar `crud-ataques-red/steps/*.md` y `crud-sqli/steps/*.md` — completado el
      2026-08-11.** Se sacaron también `index.json` y `assets/setup.sh` de ambas carpetas
      (artefactos de Killercoda que quedaron sin uso — este repo no los necesita, igual que
      `crud-stress-test/`, que nunca los tuvo).

      **Hallazgos de la sesión anterior (2026-08-10), confirmados y ya reflejados en el
      contenido:**
      - El `docker-compose.yml` **no tiene servicio `web`/nginx** — solo `mysql`,
        `phpmyadmin`, `app`. Se sacaron todas las referencias a nginx/puerto 80 del
        contenido (estaban en `step2.md` y `finish.md` de `crud-ataques-red`).
      - PhpMyAdmin corre sobre **Apache** (confirmado con `nmap -sV`, puerto 8080).
      - Puerto 3306 (MySQL) cerrado desde `localhost` — confirmado.
      - Red de Docker Compose: nombre real `hilo-conductor-redes-ataques_red-practica`
        (`red-practica` alcanza como filtro parcial) — ya reflejado en `step2.md`.
      - La app corre dockerizada; los pasos que antes hacían `grep` sobre
        `/root/crud-python/app.py` ahora usan `docker exec $(docker ps -qf "name=app") grep
        ... /app/app.py` (`crud-ataques-red` paso 3, `crud-sqli` paso 1) — confirmado que
        `docker ps -qf "name=app"` matchea un solo contenedor (no colisiona con
        `phpmyadmin`, a diferencia del bug de `mysqld-exporter` de la Etapa 6).

      **Hallazgo nuevo de esta sesión (2026-08-11), corregido en el contenido:** el `nmap
      -sV -p 8080,8888 localhost` original prometía que el puerto 8888 se identifica limpio
      como `Werkzeug/Python`. Probado en vivo (nmap 7.80), **no es así** — sale sin
      reconocer (`sun-answerbook?`, fingerprint sin match en la base de nmap). El puerto
      8080 (Apache) sí se identifica bien. `crud-ataques-red/steps/step1.md` se reescribió
      para explicar esto como una limitación real del reconocimiento por firma (no todos los
      servidores HTTP están en la base de nmap) y agregar un paso de confirmación manual con
      `curl -sI` — más honesto que prometer un resultado que no siempre se da, y es en sí
      mismo un concepto pedagógico válido (cuándo un escaneo automático no alcanza).

      **Probado en vivo contra el stack real (`docker compose up -d --build` desde la raíz,
      2026-08-11):**
      - `crud-ataques-red`: los 4 pasos completos — nmap (puertos 8080/8888/3306, con el
        hallazgo de arriba), `docker network inspect` sobre `red-practica`, acceso directo a
        MySQL con la credencial hardcodeada (`docker exec ... mysql -uroot -pmysecretpassword
        -e "SELECT * FROM alumnos.usuarios;"` devuelve `admin`/`admin123`, confirmado), y el
        `docker exec ... grep` de las credenciales.
      - `crud-sqli`: pasos 1-3 (grep de la consulta vulnerable vía `docker exec`, bypass
        manual con `curl --data-urlencode` — confirmado `200` con contraseña incorrecta y
        `302` con el payload `admin' -- `, y acceso post-bypass confirmado con la cookie).
      - `hydra` y `sqlmap` **no se habían probado en esta sesión** por no estar instalados en
        la máquina de desarrollo usada y no tener `sudo` para instalarlos — resuelto más
        abajo agregando un contenedor `toolbox` (ver la sección siguiente), que sí permitió
        probarlos.

## 2026-08-11 (segunda mitad de la sesión) — contenedor `toolbox`: nmap/hydra/sqlmap dockerizados

Surgió una pregunta razonable revisando el punto anterior: si `nmap`/`hydra`/`sqlmap`
tampoco están instalados en esta máquina de desarrollo, **¿por qué pedirle a cada alumno que
los instale a mano, distinto según el SO?** Es exactamente el mismo problema que ya se había
resuelto para la app (`Dockerfile` propio en vez de "instalá Python y las libs"). Se armó
`toolbox/Dockerfile`: una imagen Debian con `nmap`, `hydra` (ambos por `apt-get`, no hace
falta compilar) y `sqlmap` (clonado de su repo oficial — es Python puro, no tiene build),
más un cliente `mysql`. Se agregó como servicio `toolbox` al `docker-compose.yml` de la
raíz, en la misma red `red-practica`, sin exponer nada y sin correr nada por sí solo
(`sleep infinity`) — cada paso de la práctica le manda un comando puntual con `docker
compose exec toolbox <comando>`.

**Con esto, el requisito de "instalar nmap/hydra/sqlmap/mysql-client según tu SO" (la tabla
que se había agregado al README un rato antes) desapareció por completo** — el único
requisito real vuelve a ser tener Docker, igual que en Killercoda. Se sacó esa tabla del
README y se reemplazó por la explicación del contenedor `toolbox`.

**Bug real encontrado y corregido en el momento:** el `ARG`/`ENV` de proxy que se le había
agregado al `Dockerfile` de `app` (para el build) quedaba **persistido en runtime** — un
`curl` desde adentro de un contenedor con `http_proxy` seteado intenta salir por ese proxy
para *cualquier* pedido HTTP, incluidos los de la propia red interna. Probado en vivo: un
`curl -sI http://host.docker.internal:8888/login` desde `toolbox` devolvía un `503` del
proxy corporativo (`squid/4.6`) en vez de pegarle a la app. Se corrigió agregando `ENV
http_proxy="" https_proxy="" no_proxy=""` después de los pasos de build que sí necesitan
salir a internet, tanto en `toolbox/Dockerfile` como (por consistencia/seguridad, aunque no
lo disparaba) en el `Dockerfile` de `app`. Confirmado después del fix: el mismo `curl` le
pega directo a la app (`200 OK`, `Server: Werkzeug`).

**Cambios de contenido que trajo `toolbox` (targets):**
- `crud-ataques-red` Paso 1 (recon externo): el target pasa de `localhost` (cuando `nmap`
  corría en la propia terminal del alumno) a `host.docker.internal` (cómo un contenedor se
  refiere a la máquina que lo hostea) — sigue viendo exactamente lo mismo (8080/8888
  abiertos, 3306 cerrado), confirmado con el mismo hallazgo del nmap 7.93 que con el 7.80
  del host (puerto 8888 sin identificar por firma, hace falta el `curl -sI` manual).
- `crud-ataques-red` Paso 2/3 (recon interno + credenciales): como `toolbox` ya vive en la
  red interna, `mysql -h mysql ...` funciona directo por nombre de servicio — ya no hace
  falta la búsqueda manual de IP con `docker inspect` para conectarse (se dejó esa búsqueda
  en el Paso 2 como contenido, con una nota aclarando que también se podría usar el nombre
  de servicio directo, para no perder la lección de "cómo encontrar un target sin DNS").
- `crud-ataques-red` Paso 4 / `crud-sqli` Paso 2 y 4: los targets `127.0.0.1:8888` pasan a
  `app:8888` (nombre de servicio, ambos en la misma red que `toolbox`).
- Los archivos de estado intermedio (`wordlist.txt`, `cookies-sqli.txt`) se escriben dentro
  del propio `toolbox` (en `/tmp`), con `docker compose exec toolbox sh -c "cat > /tmp/..."
  << 'EOF'` — confirmado que el heredoc llega bien sin necesitar la flag `-i`/`-T`
  explícita (a diferencia del bug ya documentado de `docker exec` a secas con heredocs).

**Todo probado en vivo esta vez, incluidos `hydra` y `sqlmap` (lo que había quedado
pendiente):**
- `nmap` (recon externo e interno) — mismo comportamiento que antes de `toolbox`, confirmado.
- `mysql -h mysql` directo — confirmado, mismo resultado (`admin`/`admin123`).
- `hydra -l admin -P /tmp/wordlist.txt app -s 8888 http-post-form "..."` — confirmado,
  encuentra `admin123` en la wordlist, igual que documenta el contenido.
- `sqlmap ... --batch` (detección) — confirmado, detecta `usuario` inyectable por
  **time-based blind** (no boolean-based), exactamente como ya describía el contenido
  heredado de Killercoda.
- `sqlmap ... --dbs` — confirmado, ~4 minutos por el time-based blind (consistente con la
  advertencia que ya tiene el contenido), devuelve `alumnos`, `information_schema`, `mysql`,
  `performance_schema`, `sys`.
- `sqlmap ... --dump -D alumnos -T usuarios` — confirmado, ~1 minuto, vuelca exactamente
  `admin`/`admin123` como documenta el Paso 4.3 de `crud-sqli`.

**Con esto, los 4 pasos de `crud-ataques-red` y los 4 de `crud-sqli` quedaron confirmados en
vivo contra el stack real, sin ninguna excepción pendiente.**

      **Bug de infraestructura encontrado y corregido en esta sesión (no es de contenido,
      es del `Dockerfile`/`docker-compose.yml` de la raíz):** el build de la imagen `app`
      hace `apt-get install git` y clona `crud-python` desde GitHub — necesita salir a
      internet. En una máquina detrás de proxy corporativo (como la usada en esta sesión:
      `HTTP_PROXY=http://10.100.254.219:3128`, Rosario — ver `~/trabajos/docker_dev/README.md`
      en la máquina de Pablo para el detalle de esa red) el build fallaba en seco
      (`Temporary failure resolving 'deb.debian.org'`) porque ni el `Dockerfile` ni el
      `docker-compose.yml` pasaban el proxy al build. Se agregó `ARG`/`ENV`
      `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` al `Dockerfile` (mismo patrón que
      `~/trabajos/docker_dev/docker_lamp/php/php72/Dockerfile`) y `build.args` en el
      `docker-compose.yml`, con default vacío — no afecta a nadie que no esté detrás de un
      proxy (que va a ser el caso de la gran mayoría de los alumnos). Documentado en el
      `README.md` de la raíz. También se sacó la línea `version: '3'` del
      `docker-compose.yml` (obsoleta, generaba un warning en cada `up`).
- [x] Decidir visibilidad del repo: pasó a **público** el 2026-08-10 (no se consolidó
      dentro de `pablopedernera0.github.io` para que el `git clone` del alumno sea quirúrgico
      y no se traiga todo el sitio personal).
- [x] Actualizar `la-cajonera/CLAUDE.md`, `GUIA-DOCENTE-HILO-REDES.md` y
      `CRONOGRAMA-HILO-REDES-2C-2026.md` con la división de la Etapa 1 y el link a este repo.
      De paso se encontró y corrigió el mismo problema en la Etapa 6
      (`crud-monitoreo-prometheus-grafana`, todavía en Killercoda): también instalaba
      `apache2-utils` y corría `ab -n 2000 -c 50` para el panel en vivo — reemplazado por
      `curl`+`xargs` con los mismos números.
- [x] Responder a `security@killercoda.com` confirmando que se tomó nota de la
      restricción — enviado el 2026-08-10.

## Diferencias con la versión de Killercoda

- La app (`crud-python`, branch `feature-login`) corre **dockerizada** acá (`Dockerfile`
  propio), no como proceso Python suelto sobre una imagen `ubuntu` como en Killercoda —
  necesario porque la máquina del alumno es heterogénea (Windows/Mac/Linux), no se puede
  asumir `apt`/`pip` del sistema.
- MySQL apunta por **nombre de servicio** (`mysql`, resuelto por DNS interno de Docker
  Compose), no por IP hardcodeada + `sed` como en el flujo de Killercoda — más simple y no
  hace falta el paso de `docker inspect` para sacar la IP.
- Las tablas se siembran vía `docker-entrypoint-initdb.d` (mecanismo nativo de la imagen de
  MySQL), no vía `docker exec -i ... << EOSQL` como en los `setup.sh` de Killercoda.
