# Stress test, ataques de red y SQLi — entorno local

Infraestructura para las prácticas del hilo conductor de redes que Killercoda no permite
correr en su plataforma (stress testing, escaneo, fuerza bruta, inyección SQL automatizada),
para correr **en tu propia computadora** con Docker — no en Killercoda.

> Todo lo que vas a hacer en estas prácticas es contra tu propia infraestructura, corriendo
> en tu propia computadora. Las mismas técnicas contra un sistema que no es tuyo, sin
> autorización explícita, son un delito.

Este repo tiene **dos entornos independientes**, cada uno autocontenido en su propia carpeta
con su propio `README.md` — no corras los dos al mismo tiempo, comparten el puerto 8888:

| Etapa | Carpeta | Entorno | Por qué está acá |
|---|---|---|---|
| 1 — Stress test | [`crud-stress-test/`](crud-stress-test/) | [su propio `README.md`](crud-stress-test/README.md) | `ab` (network stress tool) |
| 3 — Reconocimiento y fuerza bruta | [`crud-ataques-red/`](crud-ataques-red/) | [`entorno-ataques/`](entorno-ataques/README.md) | `nmap` (security scanner), `hydra` (bruteforce) |
| 4 — SQLi | [`crud-sqli/`](crud-sqli/) | [`entorno-ataques/`](entorno-ataques/README.md) | `sqlmap` (hacker-tool) |

## ¿Por dónde empiezo?

Si es tu primera práctica de este repo, andá directo al `README.md` de la etapa que te
corresponda (tabla de arriba) — cada uno tiene sus propios requisitos y su guía de arranque.
Las Etapas 3 y 4 comparten infraestructura (`entorno-ataques/`); la Etapa 1 tiene la suya
propia, completamente separada.

## Qué hay acá

- [`crud-stress-test/`](crud-stress-test/) — entorno (proceso suelto + Docker Compose propio,
  `ab` dockerizado) y contenido (carga real con `ab`, dev server vs. Gunicorn) de la Etapa 1.
- [`entorno-ataques/`](entorno-ataques/) — infraestructura compartida de las Etapas 3 y 4
  (MySQL, PhpMyAdmin, app con login, contenedor `toolbox` con nmap/hydra/sqlmap/mysql).
- [`crud-ataques-red/`](crud-ataques-red/), [`crud-sqli/`](crud-sqli/) — contenido de las
  Etapas 3 y 4 (reconocimiento, credenciales filtradas, fuerza bruta, inyección SQL manual y
  automatizada), corren contra `entorno-ataques/`. Todos los pasos, incluidos `hydra` y
  `sqlmap`, se probaron en vivo contra el stack real — ver `NOTAS-DOCENTE.md` para el detalle.

## Credenciales de referencia (Etapas 3 y 4)

| Qué | Usuario | Contraseña |
|---|---|---|
| App (login) | `admin` | `admin123` |
| MySQL / PhpMyAdmin | `root` | `mysecretpassword` |

(Estas mismas credenciales están hardcodeadas en el código de la app — parte del punto de
las prácticas es encontrarlas ahí.)
