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
- Para las Etapas 3 y 4 hace falta además `nmap`, `hydra`, `sqlmap` y un cliente de `mysql`
  instalados **en tu propia máquina** (no dentro de Docker — atacan la infraestructura desde
  afuera, como haría un atacante real):

  | Herramienta | Linux (Debian/Ubuntu) | macOS (Homebrew) |
  |---|---|---|
  | `nmap` | `sudo apt install nmap` | `brew install nmap` |
  | `hydra` | `sudo apt install hydra` | `brew install hydra` |
  | `sqlmap` | `sudo apt install sqlmap` | `brew install sqlmap` |
  | cliente `mysql` | `sudo apt install mysql-client` (o `default-mysql-client`) | `brew install mysql-client` |

  En Windows, la forma más simple es correr estas prácticas desde WSL2 (que ya trae `apt`).

- Si estás detrás de un proxy corporativo, exportá `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY`
  antes de levantar el entorno (o ponelos en un archivo `.env` en la raíz de este repo,
  `docker compose` los toma solo) — el `Dockerfile` de la app los usa para poder clonar el
  código y bajar dependencias durante el build.

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

- `docker-compose.yml` — MySQL + PhpMyAdmin + la app (se construye desde `Dockerfile`), para
  las Etapas 3 y 4
- `Dockerfile` — clona `crud-python` (branch `feature-login`) y la deja lista para correr
- `init.sql` — crea y siembra las tablas `alumnos` y `usuarios` la primera vez que arranca MySQL
- `crud-ataques-red/`, `crud-sqli/` — contenido de las prácticas (reconocimiento con nmap,
  fuerza bruta con hydra, inyección SQL manual y con sqlmap), adaptado para correrse en tu
  propia terminal contra `localhost` (no en formato Killercoda). Los pasos de reconocimiento
  y bypass manual fueron probados en vivo contra el stack real; los de `hydra`/`sqlmap`
  en sí (los comandos no cambiaron respecto a la versión de Killercoda) no se re-probaron acá
  por no tener esas herramientas instaladas en esta máquina de desarrollo — ver
  `NOTAS-DOCENTE.md`.
- `crud-stress-test/` — entorno y contenido de la Etapa 1 (carga real con `ab`, dev server
  vs. Gunicorn), ya adaptado a "tu propia terminal contra `localhost`" — ver su propio
  `README.md` para arrancarlo, es independiente del `docker-compose.yml` de acá arriba.
