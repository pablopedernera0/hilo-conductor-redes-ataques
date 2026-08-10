# Paso 4 — Explotación automatizada con sqlmap

Encontrar el payload a mano funciona, pero en una aplicación real con muchos parámetros no es práctico probar variante por variante. `sqlmap` automatiza tanto la detección como la explotación.

## 4.1 — Detectar la inyección

```bash
sqlmap -u "http://127.0.0.1:8888/login" \
  --data="usuario=admin&password=test" \
  -p usuario --batch
```

- `--data` describe el body del POST que sqlmap va a mandar, con valores de ejemplo
- `-p usuario` le dice que enfoque las pruebas en ese parámetro (si no lo indicás, prueba todos)
- `--batch` responde automáticamente a las preguntas interactivas con los valores por defecto

`sqlmap` va a reportar que el parámetro `usuario` es inyectable. Puede detectarlo con distintas técnicas según el momento: **boolean-based blind** (manda condiciones verdaderas y falsas, y distingue el resultado por la diferencia entre un `302` redirect y un `200` con error — lo mismo que veníamos observando a mano) o **time-based blind** (manda un payload con `SLEEP(...)` y mide cuánto tarda en responder). Esta segunda es más lenta porque cada verificación implica esperar varios segundos — prestá atención si el comando tarda más de lo normal, es esperable.

Te va a preguntar varias cosas por consola (seguir con los redirects, extender los tests a otras técnicas, etc.) — como usamos `--batch`, responde automáticamente con la opción por defecto sin que tengas que intervenir.

## 4.2 — Listar las bases de datos

```bash
sqlmap -u "http://127.0.0.1:8888/login" \
  --data="usuario=admin&password=test" \
  -p usuario --batch --dbs
```

## 4.3 — Volcar la tabla de usuarios

```bash
sqlmap -u "http://127.0.0.1:8888/login" \
  --data="usuario=admin&password=test" \
  -p usuario --batch \
  --dump -D alumnos -T usuarios
```

`sqlmap` arma una tabla con el contenido completo de `usuarios`, incluidas las contraseñas en texto plano — sin haber escrito un solo payload manual. Si detectó la inyección por time-based blind, este paso puede tardar varios minutos (cada carácter que extrae implica varias peticiones con `SLEEP`); es normal, dejalo correr.

## 4.4 — Comparar con el Paso 2 y 3

| Método | Qué necesitás saber de antemano | Qué obtenés |
|--------|----------------------------------|-------------|
| Bypass manual (`curl`/navegador) | La sintaxis de un payload | Acceso a la sesión con un usuario |
| `sqlmap --dump` | Nada — sqlmap detecta y explota solo | El contenido completo de la tabla, todos los usuarios y contraseñas |

> Con reconocimiento, fuerza bruta e inyección SQL (manual y automatizada) ya cubriste las técnicas de ataque más comunes contra una aplicación web. En la próxima práctica vamos a mirar todo esto desde el otro lado: qué queda registrado en los logs de cada uno de estos ataques.
