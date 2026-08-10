# Paso 2 — Apache Bench contra un endpoint de lectura

Vamos a arrancar por lo más simple: medir cuánto aguanta el endpoint que lista los alumnos (`GET /`), que solo hace una consulta `SELECT` a MySQL.

## 2.1 — Verificar que la app responde

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8888/
```

Debería devolver `200`.

## 2.2 — Primera carga

```bash
ab -n 500 -c 20 http://127.0.0.1:8888/
```

Esto envía **500 peticiones** con una concurrencia de **20** simultáneas.

## 2.3 — Leer el resultado

`ab` imprime un resumen. Estos son los campos más importantes:

| Campo | Qué significa |
|-------|----------------|
| `Requests per second` | Throughput: peticiones atendidas por segundo |
| `Time per request` (primer valor) | Latencia promedio por petición |
| `Time per request` (segundo valor, "across all concurrent requests") | Latencia promedio ajustada por concurrencia |
| `Failed requests` | Peticiones que fallaron |
| `Percentage of the requests served within a certain time` | Percentiles de latencia (50%, 95%, 99%) |

## 2.4 — Guardar el resultado para comparar

```bash
ab -n 500 -c 20 http://127.0.0.1:8888/ | tee resultado-lectura.txt | grep -E "Requests per second|Failed requests|Time per request"
```

Anotá (o dejá este archivo guardado) el valor de `Requests per second` y `Failed requests` — lo vamos a comparar contra los próximos pasos.

> Si `Failed requests` dio `0`, la app soportó esta carga sin problema. Vamos a subir la vara en los próximos pasos.
