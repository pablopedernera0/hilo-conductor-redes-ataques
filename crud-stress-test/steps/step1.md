# Paso 1 — Conceptos de stress testing

Antes de generar tráfico, conviene tener claro qué vamos a medir. `ab` (y cualquier otra herramienta de carga) reporta básicamente cuatro cosas.

## 1.1 — Throughput

Es la cantidad de peticiones que el servidor logra atender por segundo (**Requests per second**). Es la métrica más directa de capacidad: cuánto tráfico aguanta la infraestructura tal como está configurada hoy.

## 1.2 — Latencia

Es el tiempo que tarda cada petición individual en resolverse (**Time per request**). Una app puede tener buen throughput y aun así tener picos de latencia que arruinan la experiencia de algunos usuarios — por eso interesa mirar no solo el promedio, sino los percentiles (p50, p95, p99).

## 1.3 — Concurrencia

Es la cantidad de peticiones que se disparan **al mismo tiempo**. No es lo mismo mandar 500 peticiones de a una que mandar 500 con 50 en simultáneo — la segunda forma es la que realmente pone a prueba el servidor.

## 1.4 — Tasa de error

Peticiones que fallan, dan timeout o devuelven un código de error. Un servidor puede seguir "funcionando" mientras descarta cada vez más peticiones — la tasa de error es la señal de que ya llegó a su límite.

## 1.5 — Qué vamos a usar

Vamos a usar **Apache Bench (`ab`)**, una herramienta de línea de comandos simple pero muy usada para pruebas de carga rápidas. Confirmá que la tenés instalada (ver `README.md` de esta carpeta si no):

```bash
ab -V
```

> Con estos cuatro conceptos en mente (throughput, latencia, concurrencia, tasa de error), pasá al Paso 2 para generar la primera carga real.
