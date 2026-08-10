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
- [ ] Adaptar el contenido de `crud-ataques-red/steps/*.md` y `crud-sqli/steps/*.md`: hoy
      están en formato Killercoda (asumen rutas como `/root/setup.sh`, el flujo de
      "Traffic/Ports" para ver puertos, etc.) — hay que reescribirlos para "tu propia
      terminal, contra `localhost`". Los comandos de `nmap`/`hydra`/`sqlmap` en sí mismos no
      cambian. (`crud-stress-test/steps/` ya está adaptado, sirve de referencia.)
- [ ] Decidir visibilidad del repo: **decidido que sí, pasa a público** (no se consolida
      dentro de `pablopedernera0.github.io` para que el `git clone` del alumno sea quirúrgico
      y no se traiga todo el sitio personal) — pendiente que Pablo lo cambie en GitHub
      (Settings → Danger Zone → Change visibility → Make public).
- [x] Actualizar `la-cajonera/CLAUDE.md`, `GUIA-DOCENTE-HILO-REDES.md` y
      `CRONOGRAMA-HILO-REDES-2C-2026.md` con la división de la Etapa 1 y el link a este repo.
      De paso se encontró y corrigió el mismo problema en la Etapa 6
      (`crud-monitoreo-prometheus-grafana`, todavía en Killercoda): también instalaba
      `apache2-utils` y corría `ab -n 2000 -c 50` para el panel en vivo — reemplazado por
      `curl`+`xargs` con los mismos números.
- [ ] Responder a `security@killercoda.com` confirmando que se tomó nota de la restricción —
      pendiente de redactar y enviar.

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
