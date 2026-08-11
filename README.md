# Stress test, ataques de red y SQLi — entorno local

Infraestructura para las prácticas del hilo conductor de redes que Killercoda no permite
correr en su plataforma (stress testing, escaneo, fuerza bruta, inyección SQL automatizada),
para correr **en tu propia computadora** con Docker — no en Killercoda.

> Todo lo que vas a hacer en estas prácticas es contra tu propia infraestructura, corriendo
> en tu propia computadora. Las mismas técnicas contra un sistema que no es tuyo, sin
> autorización explícita, son un delito.

Este repo tiene **dos entornos independientes**, uno por cada etapa que Killercoda no
permite:

| Etapa | Carpeta | Por qué está acá |
|---|---|---|
| 1 — Stress test | [`crud-stress-test/`](crud-stress-test/) | `ab` (network stress tool) |
| 3 — Reconocimiento y fuerza bruta | `crud-ataques-red/` | `nmap` (security scanner), `hydra` (bruteforce) |
| 4 — SQLi | `crud-sqli/` | `sqlmap` (hacker-tool) |

Las Etapas 3 y 4 comparten la infraestructura de la raíz de este repo (`docker-compose.yml`
+ `Dockerfile`, más abajo). La Etapa 1 tiene su propio entorno en `crud-stress-test/` —
ver el `README.md` de esa carpeta — porque usa una rama distinta de la app (`main`, sin
login) y la corre como proceso suelto en vez de dockerizada.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose instalados (Docker Desktop
  en Windows/Mac ya los trae juntos).
- `git`.

Nada más. `nmap`, `hydra`, `sqlmap` y un cliente de `mysql` **no** hace falta instalarlos en
tu máquina — vienen empaquetados en el contenedor `toolbox` (ver más abajo), que se levanta
solo con el resto del `docker-compose up`.

Si estás detrás de un proxy corporativo, exportá `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` antes
de levantar el entorno (o ponelos en un archivo `.env` en la raíz de este repo, `docker
compose` los toma solo) — los `Dockerfile` de `app` y `toolbox` los usan para poder salir a
internet (clonar código, `apt-get`) durante el build. No quedan activos en los contenedores
ya corriendo, así que no interfieren con los ataques en sí.

## Atacar desde el contenedor `toolbox`

Las Etapas 3 y 4 necesitan herramientas que Killercoda prohíbe por categoría (ver el
incidente al principio de este README) y que tampoco tiene sentido pedirle a cada alumno que
instale a mano, distinto según el sistema operativo. Por eso viven en un contenedor aparte,
`toolbox` (`nmap`, `hydra`, `sqlmap`, cliente `mysql`, `curl`), conectado a la misma red
interna que `app`/`mysql`/`phpmyadmin`. Se levanta con el resto del `docker-compose up` y se
queda esperando (no expone nada, no hace falta entrar a una terminal interactiva) — cada paso
de la práctica le manda un comando puntual con:

```bash
docker compose exec toolbox <comando>
```

corrido desde la raíz de este repo. Por ejemplo, para escanear los puertos publicados al
host: `docker compose exec toolbox nmap -sV -p 8080,8888 host.docker.internal`
(`host.docker.internal` es cómo un contenedor se refiere a la máquina que lo hostea).

## Cómo arrancar (Etapas 3 y 4)

```bash
git clone https://github.com/pablopedernera0/hilo-conductor-redes-ataques.git
cd hilo-conductor-redes-ataques
docker-compose up -d
```

La primera vez tarda un par de minutos (baja las imágenes y arma la app). Cuando termine,
vas a tener:

| Servicio | Dónde | Para qué |
|---|---|---|
| App CRUD (con login) | http://localhost:8888 | La aplicación que vamos a atacar |
| PhpMyAdmin | http://localhost:8080 | Administrar la base de datos directamente |
| MySQL | interno (no expuesto al host) | Motor de base de datos |

**Verificar que levantó todo:**

```bash
docker-compose ps
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8888/login
```

Si el `curl` devuelve `200`, está todo listo.

## Credenciales de referencia

| Qué | Usuario | Contraseña |
|---|---|---|
| App (login) | `admin` | `admin123` |
| MySQL / PhpMyAdmin | `root` | `mysecretpassword` |

(Estas mismas credenciales están hardcodeadas en el código de la app — parte del punto de
las prácticas es encontrarlas ahí.)

## Apagar el entorno

```bash
docker-compose down       # apaga los contenedores, conserva los datos
docker-compose down -v    # apaga y borra los datos (para arrancar de cero)
```

## Qué hay acá

- `docker-compose.yml` — MySQL + PhpMyAdmin + la app (se construye desde `Dockerfile`) +
  `toolbox` (nmap/hydra/sqlmap/mysql, se construye desde `toolbox/Dockerfile`), para las
  Etapas 3 y 4.
- `Dockerfile` — clona `crud-python` (branch `feature-login`) y la deja lista para correr.
- `toolbox/Dockerfile` — imagen con `nmap`, `hydra`, `sqlmap` (clonado del repo oficial,
  es Python puro) y cliente `mysql`, conectada a la misma red interna. Se queda corriendo
  en espera (`sleep infinity`); los pasos de la práctica le mandan comandos con `docker
  compose exec toolbox <comando>`.
- `init.sql` — crea y siembra las tablas `alumnos` y `usuarios` la primera vez que arranca MySQL
- `crud-ataques-red/`, `crud-sqli/` — contenido de las prácticas (reconocimiento con nmap,
  fuerza bruta con hydra, inyección SQL manual y con sqlmap), adaptado para correrse contra
  este stack (no en formato Killercoda) usando `toolbox` en vez de herramientas instaladas
  en la máquina del alumno. Todos los pasos, incluidos `hydra` y `sqlmap`, se probaron en
  vivo contra el stack real — ver `NOTAS-DOCENTE.md` para el detalle.
- `crud-stress-test/` — entorno y contenido de la Etapa 1 (carga real con `ab`, dev server
  vs. Gunicorn), ya adaptado a "tu propia terminal contra `localhost`" — ver su propio
  `README.md` para arrancarlo, es independiente del `docker-compose.yml` de acá arriba. No
  usa `toolbox`: `ab` corre en la terminal del alumno, no dentro de un contenedor.
