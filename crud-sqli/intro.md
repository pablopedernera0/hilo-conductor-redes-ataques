# Inyección SQL manual y automatizada con sqlmap

En la práctica anterior comprometimos esta infraestructura con reconocimiento, credenciales filtradas y fuerza bruta. Hoy vamos por una vulnerabilidad puntual: la forma en que `/login` arma su consulta SQL permite entrar **sin conocer ninguna contraseña**.

> Todo lo que vas a hacer en esta práctica es contra tu propia infraestructura, dentro de tu propio sandbox. Las mismas técnicas contra sistemas que no son tuyos y sin autorización son ilegales.

## ¿Qué es una inyección SQL?

Ocurre cuando una aplicación arma una consulta SQL pegando directamente texto que viene del usuario, en lugar de tratarlo como un dato separado (lo que se conoce como **consulta parametrizada**). Si el texto que mandás incluye comillas o palabras clave de SQL, podés cambiar el significado de la consulta.

## ¿Qué vamos a hacer?

Al finalizar esta práctica vas a haber:

- Revisado exactamente dónde está el problema en el código de `/login`
- Entrado a la app sin contraseña, con un payload manual, usando `curl` y el navegador
- Usado **sqlmap** para detectar y explotar la inyección de forma automática
- Volcado el contenido completo de la tabla `usuarios` con `sqlmap --dump`

## Preparar el entorno

Si todavía no lo hiciste, levantá la infraestructura siguiendo el `README.md` de la raíz de este repo: `docker-compose up -d --build` desde `hilo-conductor-redes-ataques/`. **Corré todos los comandos de esta práctica desde ahí** (la raíz del repo) — es la misma infraestructura de la práctica anterior, incluido el contenedor `toolbox`, que ya trae `sqlmap` (no hace falta instalarlo en tu máquina).

Verificá que la app responde antes de seguir:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8888/login
```

Debería devolver `200`. Con eso, continuá con el **Paso 1**.
