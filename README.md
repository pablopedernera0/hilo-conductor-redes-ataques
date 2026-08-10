# Ataques de red y SQLi — entorno local

Infraestructura para las prácticas de ataques del hilo conductor de redes: la misma app
CRUD (MySQL + Flask, con login) que se usó en las prácticas anteriores, para correr **en tu
propia computadora** con Docker — no en Killercoda.

> Todo lo que vas a hacer en estas prácticas es contra tu propia infraestructura, corriendo
> en tu propia computadora. Las mismas técnicas contra un sistema que no es tuyo, sin
> autorización explícita, son un delito.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose instalados (Docker Desktop
  en Windows/Mac ya los trae juntos).
- `git`.

## Cómo arrancar

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

- `docker-compose.yml` — MySQL + PhpMyAdmin + la app (se construye desde `Dockerfile`)
- `Dockerfile` — clona `crud-python` (branch `feature-login`) y la deja lista para correr
- `init.sql` — crea y siembra las tablas `alumnos` y `usuarios` la primera vez que arranca MySQL
- `crud-ataques-red/`, `crud-sqli/` — contenido de las prácticas (reconocimiento con nmap,
  fuerza bruta con hydra, inyección SQL manual y con sqlmap). **Nota:** estos pasos todavía
  están escritos en formato Killercoda (asumen `/root/setup.sh` y rutas de ese entorno) —
  falta adaptarlos a "correlos en tu propia terminal, contra `localhost`" en vez de la
  sandbox de Killercoda. Los comandos de `nmap`/`hydra`/`sqlmap`/`curl` en sí no cambian,
  cambian las rutas y el paso de "preparar el entorno" (ya lo hace este `docker-compose`).
