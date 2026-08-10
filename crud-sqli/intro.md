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

Antes de continuar con el Paso 1, ejecutá este comando para levantar la infraestructura (la misma de las prácticas anteriores):

```bash
bash /root/setup.sh
```

El script instala, además de lo de siempre, `sqlmap`. Puede tardar un par de minutos.

Cuando termine, vas a ver un resumen con los servicios disponibles. Si todo está bien, continuá con el **Paso 1**.
