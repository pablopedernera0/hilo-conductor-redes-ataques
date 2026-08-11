# Paso 3 — Credenciales expuestas en el código

Saber que MySQL está abierto no sirve de mucho sin una credencial. Pero ya tenemos el código fuente de la app clonado en el disco — es lo primero que revisa cualquiera que quiera atacar una aplicación de la que puede conseguir el repositorio.

## 3.1 — Buscar credenciales en el código

La app corre dockerizada, así que el código fuente está dentro del contenedor `app`, no en tu propio disco:

```bash
docker exec $(docker ps -qf "name=app") grep -n -i "password" /app/app.py
```

Ahí está: `DB_CONFIG` tiene el usuario `root` y la contraseña de MySQL en texto plano, en el archivo que subimos a un repositorio **público** de GitHub.

## 3.2 — Conectarse directo a MySQL con esa credencial

El cliente de `mysql` tampoco hace falta instalarlo en tu máquina — está en `toolbox`, en la misma red que el contenedor de MySQL, así que le llega directo por nombre de servicio:

```bash
docker compose exec toolbox mysql -h mysql -uroot -pmysecretpassword -e "SHOW DATABASES;"
```

Acceso total al servidor, sin haber roto nada — solo leímos el código.

## 3.3 — ¿Qué se puede sacar?

```bash
docker compose exec toolbox mysql -h mysql -uroot -pmysecretpassword -e "SELECT * FROM alumnos.usuarios;"
```

Con la contraseña de MySQL en la mano, la tabla `usuarios` —contraseñas en texto plano incluidas— queda totalmente expuesta. Ni siquiera hizo falta pasar por el login de la app.

## 3.4 — La lección

Un secreto hardcodeado en el código es un secreto que viaja con cada `git clone`, cada fork, cada backup del repositorio. No importa cuán "interno" parezca el servicio que protege: si la credencial es pública, el servicio también lo es.

> Ya tenemos acceso directo a la base. En el Paso 4 vamos a atacar el login de la app en sí, sin pasar por MySQL, usando fuerza bruta.
