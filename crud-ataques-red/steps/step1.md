# Paso 1 — Reconocimiento con nmap

Antes de atacar cualquier cosa, un atacante (o un pentester autorizado) empieza por mapear qué hay expuesto. Eso es **reconocimiento**.

## 1.1 — Escaneo básico de puertos

```bash
nmap localhost
```

Vas a ver una lista de puertos abiertos. `nmap` sin flags escanea los ~1000 puertos más comunes.

## 1.2 — Identificar los servicios

El puerto solo no dice mucho. Pidámosle a `nmap` que identifique versiones de servicio:

```bash
nmap -sV -p 8080,8888 localhost
```

El puerto 8080 debería identificarse limpio como `Apache httpd` (el servidor que trae la imagen de PhpMyAdmin). El 8888 es más interesante: según la base de fingerprints de tu versión de `nmap`, puede aparecer **sin identificar** (algo como `sun-answerbook?`, con un bloque largo de "unrecognized fingerprint") en vez de decir directamente "Werkzeug". No es que el puerto esté mal configurado — es una limitación real del reconocimiento por firma: nmap no tiene en su base todos los servidores HTTP posibles, y el servidor de desarrollo de Flask es uno de los que suele fallar.

## 1.3 — Confirmar a mano lo que nmap no identificó

Cuando el escaneo por firma no alcanza, se confirma directamente con una petición HTTP:

```bash
curl -sI http://127.0.0.1:8888/login | head -3
```

Ahí sí aparece sin ambigüedad: `Server: Werkzeug/... Python/...` — el servidor de desarrollo de Flask, no pensado para producción (la misma limitación que viste en la práctica de stress testing).

> Guardate esta lección junto con la del puerto 3306 que sigue: un escaneo automático (por firma o por puerto publicado) no siempre alcanza — a veces hace falta un paso manual para confirmar.

## 1.4 — ¿Y el puerto 3306 de MySQL?

```bash
nmap -p 3306 localhost
```

Va a aparecer como `closed`. Repasá el `docker-compose.yml` (en la raíz del repo, un nivel arriba de esta carpeta):

```bash
cat ../docker-compose.yml
```

Fijate que el servicio `mysql` no tiene una sección `ports:` — nunca se publicó al host. Desde `localhost`, MySQL es invisible.

> Un escaneo desde afuera del host solo ve lo que está publicado. En el Paso 2 vamos a movernos un nivel más adentro: la red interna de Docker.
