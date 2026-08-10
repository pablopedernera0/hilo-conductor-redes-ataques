# Paso 3 — Carga sobre un endpoint de escritura

Leer datos (`SELECT`) es barato. Escribir datos (`INSERT`) implica un lock más costoso en la base y, en este caso, un commit por cada petición. Vamos a comprobarlo generando carga sobre `POST /nuevo`, el endpoint que da de alta un alumno.

## 3.1 — Preparar el body de la petición

`ab` necesita el body en un archivo aparte para peticiones `POST`:

```bash
printf 'nombre=Carga&apellido=DeTest&fecha_nacimiento=2000-01-01' > post-data.txt
```

## 3.2 — Contar los alumnos antes de la prueba

```bash
docker-compose exec mysql mysql -uroot -pmysecretpassword -N -e "SELECT COUNT(*) FROM alumnos.alumnos;"
```

(Corré este comando desde `hilo-conductor-redes-ataques/crud-stress-test/`, donde está el `docker-compose.yml` de esta etapa.)

## 3.3 — Generar la carga de escritura

```bash
ab -n 200 -c 10 -p post-data.txt -T application/x-www-form-urlencoded \
  http://127.0.0.1:8888/nuevo
```

Usamos menos peticiones y menos concurrencia que en el Paso 2 a propósito — ya vas a ver por qué.

## 3.4 — Contar los alumnos después

```bash
docker-compose exec mysql mysql -uroot -pmysecretpassword -N -e "SELECT COUNT(*) FROM alumnos.alumnos;"
```

El número debería haber crecido en 200 (o cerca, si hubo alguna petición fallida).

## 3.5 — Comparar contra el Paso 2

Compará el `Requests per second` de esta corrida contra el de `resultado-lectura.txt`. Vas a ver un throughput bastante menor: cada escritura le suma a la app el costo de un `INSERT` y un `commit` contra MySQL, mientras que la lectura solo hace un `SELECT`.

> Guardate mentalmente esta diferencia — en el Paso 4 vamos a llevar la app a su límite real.
