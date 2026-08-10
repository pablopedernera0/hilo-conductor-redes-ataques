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
- Apache Bench (`ab`): paquete `apache2-utils` en Debian/Ubuntu, `httpd` en macOS
  (`brew install httpd`).
- Python 3 con `pip`.

## 1. Levantar MySQL y PhpMyAdmin

```bash
git clone https://github.com/pablopedernera0/hilo-conductor-redes-ataques.git
cd hilo-conductor-redes-ataques/crud-stress-test
docker-compose up -d
```

Esto crea la base `alumnos` con 5 registros semilla y deja PhpMyAdmin en
http://localhost:8080. A diferencia del resto del repo, acá MySQL sí se expone al host
(`localhost:3306`) — la app de esta etapa corre como **proceso suelto en tu máquina**, no
dockerizada, porque el ejercicio depende de poder matarla y reiniciarla con otro servidor
WSGI sin tocar contenedores.

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
