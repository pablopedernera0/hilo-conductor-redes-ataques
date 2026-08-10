# Paso 3 — Bypass desde el navegador y otras variantes

## 3.1 — Acceder desde el navegador

Hacé click en el ícono **hamburger** (≡) arriba a la derecha, seleccioná **"Traffic / Ports"**, escribí `8888` en **Custom Ports** y hacé click en **Access**. Vas a caer en la pantalla de login.

## 3.2 — Probar el mismo payload

En el campo **Usuario** escribí:

```
admin' --
```

Dejá **Contraseña** con cualquier cosa (o vacío) y hacé click en **Ingresar**. Deberías entrar directo al listado de alumnos.

## 3.3 — Una variante que no necesita saber el nombre de usuario

Cerrá sesión (**Salir**) y probá esta otra combinación en el campo **Usuario**:

```
' OR '1'='1' --
```

La consulta resultante es:

```sql
SELECT id, usuario FROM usuarios WHERE usuario = '' OR '1'='1' -- ' AND password = '...'
```

`'1'='1'` es siempre verdadero, así que la condición completa se cumple para **cualquier** fila de la tabla — sin necesidad de conocer ningún nombre de usuario real.

## 3.4 — Por qué esto es peor que la fuerza bruta de la práctica anterior

Con `hydra` (práctica anterior) tuvimos que probar contraseñas una por una hasta acertar, y necesitábamos saber que el usuario se llamaba `admin`. Con esta inyección:

- No hace falta conocer ningún usuario ni contraseña válidos
- Es instantáneo: un solo intento, no una wordlist
- Funciona aunque el sistema tenga bloqueo de cuenta tras varios intentos fallidos, porque técnicamente es **un único intento exitoso**

> En el Paso 4 vamos a automatizar todo esto con una herramienta hecha específicamente para encontrar y explotar este tipo de vulnerabilidades: `sqlmap`.
