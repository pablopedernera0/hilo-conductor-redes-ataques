# Paso 2 — Más allá del host: la red interna de Docker

MySQL no está publicado al host, pero sí vive en la misma red Docker que `toolbox` — el contenedor que venimos usando para atacar. Los comandos de `docker network` de esta sección corren en tu propia terminal (son del Docker del host, no de adentro de ningún contenedor); el escaneo en sí lo hacemos, como siempre, con `docker compose exec toolbox`.

## 2.1 — Encontrar la red

```bash
docker network ls --filter "name=red-practica"
```

## 2.2 — Ver quién está conectado

```bash
docker network inspect $(docker network ls --filter "name=red-practica" -q) \
  --format '{{range $k, $v := .Containers}}{{$v.Name}} -> {{$v.IPv4Address}}{{"\n"}}{{end}}'
```

Vas a ver los tres contenedores (`mysql`, `phpmyadmin`, `app`) con su IP interna.

## 2.3 — Escanear el contenedor de MySQL directamente

Guardá la IP de MySQL:

```bash
MYSQL_IP=$(docker inspect $(docker ps -qf "name=mysql") --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "MySQL está en $MYSQL_IP"
```

Y escaneala:

```bash
docker compose exec toolbox nmap -sV -p 3306 $MYSQL_IP
```

Esta vez sí aparece **abierto**, con el servicio identificado como `mysql`.

> Como `toolbox` está en la misma red que MySQL, también podrías haber escaneado directo por nombre de servicio (`docker compose exec toolbox nmap -sV -p 3306 mysql`), sin pasar por la IP. Vale la pena conocer las dos formas: la resolución por nombre no siempre está disponible (por ejemplo, si el atacante llegó a la red por otro medio que no sea Docker Compose), y ahí la única forma de llegar al servicio es por IP.

## 2.4 — La lección

Que un puerto no esté publicado al host **no es lo mismo** que estar protegido. Si un atacante logra ejecutar comandos dentro de la misma red (por ejemplo, comprometiendo cualquiera de los otros contenedores, o —como en nuestro caso— con acceso a la terminal del host), el servicio "interno" queda tan expuesto como cualquier otro.

> Ya sabemos que MySQL está ahí y qué versión corre. En el Paso 3 vamos a ver si podemos entrar.

---

**← Anterior:** [Paso 1](step1.md) | **Siguiente →** [Paso 3](step3.md)
