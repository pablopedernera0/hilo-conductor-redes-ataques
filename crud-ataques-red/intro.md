# Reconocimiento y fuerza bruta contra la infraestructura CRUD

En las últimas dos prácticas construimos y medimos una infraestructura real: Nginx, MySQL, PhpMyAdmin y una app Flask con login. Ahora nos ponemos del otro lado: vamos a atacarla, con las mismas herramientas que se usan en un test de penetración autorizado.

> Todo lo que vas a hacer en esta práctica es contra tu propia infraestructura, dentro de tu propio sandbox. Las mismas técnicas contra sistemas que no son tuyos y sin autorización son ilegales.

## ¿Qué vamos a hacer?

Al finalizar esta práctica vas a haber:

- Escaneado los puertos publicados al host con **nmap**
- Descubierto que hay un servicio (MySQL) que no está publicado al host, pero sí accesible desde la red interna de Docker
- Encontrado la contraseña de MySQL hardcodeada en el código fuente y usado para conectarte directo a la base
- Ejecutado un ataque de **fuerza bruta** con **hydra** contra el login de la app, hasta dar con la contraseña correcta

## Preparar el entorno

Antes de continuar con el Paso 1, ejecutá este comando para levantar toda la infraestructura (la misma de las prácticas anteriores, con login incluido):

```bash
bash /root/setup.sh
```

El script instala, además de lo de siempre, `nmap` y `hydra`. Puede tardar un par de minutos.

Cuando termine, vas a ver un resumen con los servicios disponibles. Si todo está bien, continuá con el **Paso 1**.
