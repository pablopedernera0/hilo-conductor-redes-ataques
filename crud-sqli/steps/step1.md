# Paso 1 — La consulta vulnerable, revisitada

En la práctica de login ya leíste esta ruta, pero sin prestarle atención al problema. Volvamos a mirarla con ojo de atacante.

## 1.1 — Ver la consulta

La app corre dockerizada, así que el código fuente está dentro del contenedor `app`, no en tu propio disco:

```bash
docker exec $(docker ps -qf "name=app") grep -n -A 3 "SELECT id, usuario FROM usuarios" /app/app.py
```

Deberías ver algo así:

```python
query = f"SELECT id, usuario FROM usuarios WHERE usuario = '{usuario}' AND password = '{password}'"
cur.execute(query)
```

## 1.2 — ¿Dónde está el problema?

`usuario` y `password` vienen directo de `request.form`, sin validar, y se insertan con un f-string dentro de la consulta. Compará con las rutas del CRUD (`/nuevo`, `/editar`), que sí son seguras:

```bash
docker exec $(docker ps -qf "name=app") grep -n -A 2 "INSERT INTO alumnos" /app/app.py
```

Ahí los valores van como parámetros separados (`%s` + una tupla) — la librería de MySQL los escapa antes de armar la consulta real. En `/login`, en cambio, el texto que mandás se convierte literalmente en parte del SQL.

## 1.3 — Pensarlo como texto plano

Si mandás como usuario el texto:

```
admin' --
```

la consulta que termina ejecutando MySQL es:

```sql
SELECT id, usuario FROM usuarios WHERE usuario = 'admin' -- ' AND password = 'lo-que-sea'
```

En SQL, `--` (seguido de un espacio) inicia un comentario: todo lo que sigue en la línea se ignora. La verificación de la contraseña directamente **desaparece** de la consulta.

> Con la teoría clara, pasá al Paso 2 para probarlo en la práctica.
