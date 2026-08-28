# Etapas 3 y 4 — Entorno de ataques

Infraestructura compartida para las Etapas 3 (`crud-ataques-red/`, reconocimiento y fuerza
bruta) y 4 (`crud-sqli/`, inyección SQL) del hilo conductor de redes: MySQL, PhpMyAdmin, la
app CRUD con login y un contenedor `toolbox` con las herramientas de ataque.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose instalados (Docker Desktop
  en Windows/Mac ya los trae juntos).
- `git`.

Nada más. `nmap`, `hydra`, `sqlmap` y un cliente de `mysql` **no** hace falta instalarlos en
tu máquina — vienen empaquetados en el contenedor `toolbox` (ver más abajo), que se levanta
solo con el resto del `docker compose up`.

> **No dejes `crud-stress-test/` corriendo al mismo tiempo.** Los dos entornos usan el mismo
> puerto 8888 (y `crud-stress-test/` también expone MySQL en el 3306). Si ambos están arriba
> a la vez, el tráfico de uno puede terminar pegándole a la app del otro sin ningún error
> visible — antes de arrancar esto, andá a `crud-stress-test/` y corré `docker compose down`.

Si estás detrás de un proxy corporativo, exportá `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` antes
de levantar el entorno (o ponelos en un archivo `.env` acá mismo, `docker compose` los toma
solo) — los `Dockerfile` de `app` y `toolbox` los usan para poder salir a internet (clonar
código, `apt-get`) durante el build. No quedan activos en los contenedores ya corriendo, así
que no interfieren con los ataques en sí.

## Atacar desde el contenedor `toolbox`

Las Etapas 3 y 4 necesitan herramientas que Killercoda prohíbe por categoría (ver el
incidente en el `README.md` de la raíz del repo) y que tampoco tiene sentido pedirle a cada
alumno que instale a mano, distinto según el sistema operativo. Por eso viven en un
contenedor aparte, `toolbox` (`nmap`, `hydra`, `sqlmap`, cliente `mysql`, `curl`), conectado
a la misma red interna que `app`/`mysql`/`phpmyadmin`. Se levanta con el resto del
`docker compose up` y se queda esperando (no expone nada, no hace falta entrar a una terminal
interactiva) — cada paso de la práctica le manda un comando puntual con:

```bash
docker compose exec toolbox <comando>
```

corrido desde esta carpeta. Por ejemplo, para escanear los puertos publicados al host:
`docker compose exec toolbox nmap -sV -p 8080,8888 host.docker.internal`
(`host.docker.internal` es cómo un contenedor se refiere a la máquina que lo hostea).

## Cómo arrancar

```bash
git clone https://github.com/pablopedernera0/hilo-conductor-redes-ataques.git
cd hilo-conductor-redes-ataques/entorno-ataques
docker compose up -d
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
docker compose ps
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8888/login
```

Si el `curl` devuelve `200`, está todo listo. Con eso, arrancá con la Etapa 3 en
[`crud-ataques-red/intro.md`](../crud-ataques-red/intro.md).

## Alternativa: GitHub Codespaces

Si no tenés PC propia con Docker, podés correr este entorno en una Codespace en vez de tu
máquina — no hace falta instalar nada, ni siquiera Docker: **Code → pestaña Codespaces →
Create codespace on main**, directo desde este repo en GitHub. Una vez que termine de
armarse (unos minutos la primera vez), corré en la terminal:

```bash
cd entorno-ataques
docker compose up -d
```

El resto (verificación con `docker compose ps` y el `curl`, los ataques con `docker compose
exec toolbox <comando>`) es exactamente igual que en tu propia PC. Confirmado funcionando de
punta a punta: `nmap`, `hydra` y `sqlmap` corren sin ningún corte ni aviso de la plataforma —
Codespaces ya trae Docker instalado por defecto, no hace falta ninguna configuración extra.

## Credenciales de referencia

| Qué | Usuario | Contraseña |
|---|---|---|
| App (login) | `admin` | `admin123` |
| MySQL / PhpMyAdmin | `root` | `mysecretpassword` |

(Estas mismas credenciales están hardcodeadas en el código de la app — parte del punto de
las prácticas es encontrarlas ahí.)

## Apagar el entorno

```bash
docker compose down       # apaga los contenedores, conserva los datos
docker compose down -v    # apaga y borra los datos (para arrancar de cero)
```

## Qué hay acá

- `docker-compose.yml` — MySQL + PhpMyAdmin + la app (se construye desde `Dockerfile`) +
  `toolbox` (nmap/hydra/sqlmap/mysql, se construye desde `toolbox/Dockerfile`).
- `Dockerfile` — clona `crud-python` (branch `feature-login`) y la deja lista para correr.
- `toolbox/Dockerfile` — imagen con `nmap`, `hydra`, `sqlmap` (clonado del repo oficial, es
  Python puro) y cliente `mysql`, conectada a la misma red interna. Se queda corriendo en
  espera (`sleep infinity`); los pasos de la práctica le mandan comandos con `docker compose
  exec toolbox <comando>`.
- `init.sql` — crea y siembra las tablas `alumnos` y `usuarios` la primera vez que arranca
  MySQL.

---

**Siguiente →** [Etapa 3 — Reconocimiento y fuerza bruta](../crud-ataques-red/intro.md)
