# Paso 5 — Gunicorn: un servidor apto para producción

**Gunicorn** es un servidor WSGI para aplicaciones Python pensado para producción: en vez de un único proceso atendiendo todo, reparte las peticiones entre varios **workers** que corren en paralelo.

## 5.1 — Instalar Gunicorn

```bash
pip3 install gunicorn
```

## 5.2 — Levantar la misma app con Gunicorn

Cortá la app anterior (`Ctrl+C` en la terminal donde corre `python3 app.py`, o matá el proceso) y, sin tocar una línea del código, arrancala con 4 workers en otro puerto:

```bash
cd crud-python
gunicorn -w 4 -b 0.0.0.0:8889 app:app
```

Dejá esta terminal abierta y abrí otra para seguir.

## 5.3 — Verificar que responde

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8889/
```

## 5.4 — Repetir la prueba que rompió la app en el Paso 4

```bash
ab -n 3000 -c 200 -s 5 http://127.0.0.1:8889/
```

## 5.5 — Comparar

| | Flask dev server (8888) | Gunicorn 4 workers (8889) |
|---|---|---|
| Requests per second | (el que anotaste en el Paso 4) | |
| Failed requests | (el que anotaste en el Paso 4) | |

Completá la columna de Gunicorn con el resultado que acabás de obtener. La diferencia no es magia: son 4 procesos atendiendo en paralelo en vez de 1.

## 5.6 — Confirmá los procesos

```bash
ps aux | grep gunicorn | grep -v grep
```

Vas a ver varios procesos `gunicorn` — el master y los 4 workers.

> Con esto cerramos la parte de performance. La misma infraestructura (mismas credenciales, mismos puertos expuestos) que acabás de medir es la que vamos a atacar en la próxima práctica — ver `crud-ataques-red/` en la raíz de este repo.

---

**← Anterior:** [Paso 4](step4.md) | **Siguiente escenario →** [crud-ataques-red](../crud-ataques-red/intro.md)
