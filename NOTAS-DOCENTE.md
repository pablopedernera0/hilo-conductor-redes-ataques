# Notas para el docente (no es material para el alumno)

## Por qué existe este repo

Etapas 3 (`crud-ataques-red`) y 4 (`crud-sqli`) del hilo conductor de redes, originalmente
escritas para Killercoda. El 2026-08-10, corriendo `ab` (Apache Bench, Etapa 1) la cuenta de
Killercoda `pablop22` quedó bloqueada por "illegal activity... cryptominers, security
scanners, bruteforce or hacker-tools". Estas dos etapas instalan y ejecutan `nmap`
(security scanner), `hydra` (bruteforce) y `sqlmap` (hacker-tool) — exactamente esas
categorías. Sin confirmar el mecanismo exacto de detección (¿por comportamiento en tiempo
de ejecución, o por escaneo del contenido del repo linkeado?), se sacó todo este contenido
de `la-cajonera` (el repo linkeado a Killercoda) como precaución, y se armó este entorno
con `docker-compose` para que cada alumno lo corra en su propia máquina — sin depender de
ninguna plataforma de terceros con detección de abuso.

## Estado

- [x] Entorno base (`docker-compose.yml`, `Dockerfile`, `init.sql`) — probado end-to-end localmente
- [ ] Adaptar el contenido de `crud-ataques-red/steps/*.md` y `crud-sqli/steps/*.md`: hoy
      están en formato Killercoda (asumen rutas como `/root/setup.sh`, el flujo de
      "Traffic/Ports" para ver puertos, etc.) — hay que reescribirlos para "tu propia
      terminal, contra `localhost`". Los comandos de `nmap`/`hydra`/`sqlmap` en sí mismos no
      cambian.
- [ ] Decidir visibilidad del repo: hoy es privado, tiene que ser público (o accesible a
      todo el curso) para que los alumnos lo puedan clonar.
- [ ] Actualizar `la-cajonera/CLAUDE.md` y `la-cajonera/hilo-conductor-redes/GUIA-DOCENTE-HILO-REDES.md`
      cuando el contenido adaptado esté listo, con el link a este repo en vez del link a
      Killercoda para las etapas 3 y 4.
- [ ] Ver si la Etapa 1 (`crud-stress-test`, que sigue en Killercoda) necesita el mismo
      tratamiento — usa `ab`, que aparentemente disparó el bloqueo original.
- [ ] Respuesta de `security@killercoda.com` sobre el bloqueo de la cuenta — pendiente.

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
