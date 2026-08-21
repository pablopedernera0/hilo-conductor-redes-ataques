# Etapa 1 — Stress testing (versión realista)

Versión completa de la Etapa 1 del hilo conductor de redes: carga real con `ab` (Apache
Bench) contra la app CRUD, comparando el servidor de desarrollo de Flask contra Gunicorn.

> **Por qué está acá y no en Killercoda:** el mail de Killercoda que desbloqueó la cuenta
> prohíbe explícitamente "network stress tools" como categoría — no por intensidad, así que
> no alcanza con moderar la carga. De hecho fue esta etapa, corriendo `ab`, la que disparó
> el bloqueo original (ver `NOTAS-DOCENTE.md`). La versión que sigue en Killercoda
> (`la-cajonera/crud-stress-test`) mide con un loop de `curl` — enseña los mismos conceptos
> sin invocar una herramienta que Killercoda nombra por categoría.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose.
- `git`.
- Python 3 con `pip`.

`ab` (Apache Bench) **no** hace falta instalarlo en tu máquina — viene en el contenedor
`abtool` (se levanta solo con el resto del `docker compose up`), igual que `nmap`/`hydra`/
`sqlmap` en las prácticas de ataques. Los comandos de `ab` de esta guía van con el prefijo
`docker compose exec abtool ab ...`, apuntando a `host.docker.internal` (así es como un
contenedor se refiere a la máquina que lo hostea) en vez de `127.0.0.1`, porque la app corre
suelta en tu máquina, no en un contenedor.

## 1. Levantar MySQL y PhpMyAdmin

```bash
git clone https://github.com/pablopedernera0/hilo-conductor-redes-ataques.git
cd hilo-conductor-redes-ataques/crud-stress-test
docker compose up -d
```

Esto crea la base `alumnos` con 5 registros semilla y deja PhpMyAdmin en
http://localhost:8080. A diferencia del resto del repo, acá MySQL sí se expone al host
(`localhost:3306`) — la app de esta etapa corre como **proceso suelto en tu máquina**, no
dockerizada, porque el ejercicio depende de poder matarla y reiniciarla con otro servidor
WSGI sin tocar contenedores.

> **No dejes `entorno-ataques/` (Etapas 3 y 4) corriendo al mismo tiempo que esto.** Los dos
> entornos usan el puerto 8888, y ese también usa el 3306 (MySQL). Si ambos están arriba a la
> vez, el tráfico de esta etapa puede terminar pegándole a la app equivocada sin ningún error
> visible — si venís de la otra práctica, corré `docker compose down` en `entorno-ataques/`
> antes de seguir.

## 2. Levantar la app CRUD

```bash
cd ..
git clone --branch main --depth 1 https://github.com/pablopedernera0/crud-python.git
sed -i.bak 's/172.18.0.2/127.0.0.1/' crud-python/app.py
pip3 install flask mysql-connector-python
cd crud-python
python3 app.py
```

Dejá esa terminal abierta y verificá en otra:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8888/
```

Debería devolver `200`.

## 3. Guía paso a paso

Seguí `steps/step1.md` a `steps/step5.md` en orden.

---

**Siguiente →** [Paso 1](steps/step1.md)
