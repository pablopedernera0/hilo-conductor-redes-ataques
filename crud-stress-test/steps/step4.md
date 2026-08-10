# Paso 4 — Encontrando el límite del servidor

Hasta ahora la app respondió sin errores. Vamos a subir la concurrencia hasta encontrar el punto en el que empieza a fallar.

## 4.1 — Subir la apuesta

```bash
ab -n 2000 -c 100 http://127.0.0.1:8888/
```

Prestá atención a `Failed requests` y a si el comando tarda mucho más de lo esperado en terminar.

## 4.2 — Si no falló todavía, subí más

```bash
ab -n 3000 -c 200 -s 5 http://127.0.0.1:8888/
```

El flag `-s 5` le pone un timeout de 5 segundos por petición — a esta concurrencia es esperable ver `Failed requests` mayor a `0` o directamente errores de conexión.

## 4.3 — ¿Por qué se rompe?

Mirá cómo arranca la app Flask (en la terminal donde la dejaste corriendo con `python3 app.py`, o directamente):

```bash
tail -n 5 crud-python/app.py
```

La última línea es:

```python
app.run(host="0.0.0.0", port=8888, debug=False)
```

`app.run()` sin más parámetros levanta el **servidor de desarrollo** de Flask (Werkzeug), que por defecto es **single-threaded**: atiende una petición a la vez. Mientras una petición espera la respuesta de MySQL, todas las demás quedan haciendo cola. Por eso el throughput se desploma (y aparecen fallos) apenas la concurrencia supera lo que ese único hilo puede procesar en serie.

## 4.4 — Confirmá con los procesos

```bash
ps aux | grep "app.py" | grep -v grep
```

Vas a ver un único proceso Python atendiendo todo el tráfico.

> Este es exactamente el motivo por el que ningún framework recomienda `app.run()` en producción. En el Paso 5 vamos a levantar la misma app con un servidor que sí está pensado para esto.
