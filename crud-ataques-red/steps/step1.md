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

Deberías ver algo así:

| Puerto | Servicio esperado |
|--------|--------------------|
| 8080 | `Apache httpd` (el servidor que trae la imagen de PhpMyAdmin) |
| 8888 | `Werkzeug`/Python — el servidor de desarrollo de Flask |

## 1.3 — ¿Y el puerto 3306 de MySQL?

```bash
nmap -p 3306 localhost
```

Va a aparecer como `closed`. Repasá el `docker-compose.yml` (en la raíz del repo, un nivel arriba de esta carpeta):

```bash
cat ../docker-compose.yml
```

Fijate que el servicio `mysql` no tiene una sección `ports:` — nunca se publicó al host. Desde `localhost`, MySQL es invisible.

> Un escaneo desde afuera del host solo ve lo que está publicado. En el Paso 2 vamos a movernos un nivel más adentro: la red interna de Docker.
