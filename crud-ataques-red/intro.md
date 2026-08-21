# Reconocimiento y fuerza bruta contra la infraestructura CRUD

En las últimas dos prácticas construimos y medimos una infraestructura real: MySQL, PhpMyAdmin y una app Flask con login. Ahora nos ponemos del otro lado: vamos a atacarla, con las mismas herramientas que se usan en un test de penetración autorizado.

> Todo lo que vas a hacer en esta práctica es contra tu propia infraestructura, en tu propia computadora. Las mismas técnicas contra sistemas que no son tuyos y sin autorización son ilegales.

## ¿Qué vamos a hacer?

Al finalizar esta práctica vas a haber:

- Escaneado los puertos publicados al host con **nmap**
- Descubierto que hay un servicio (MySQL) que no está publicado al host, pero sí accesible desde la red interna de Docker
- Encontrado la contraseña de MySQL hardcodeada en el código fuente y usado para conectarte directo a la base
- Ejecutado un ataque de **fuerza bruta** con **hydra** contra el login de la app, hasta dar con la contraseña correcta

## Preparar el entorno

Si todavía no lo hiciste, levantá la infraestructura siguiendo el `README.md` de la raíz de este repo: `docker compose up -d --build` desde `hilo-conductor-redes-ataques/entorno-ataques/`. **Corré todos los comandos de esta práctica desde esa carpeta** (`entorno-ataques/`), no hace falta moverte a esta.

`nmap` y `hydra` no hace falta instalarlos en tu máquina — vienen en un contenedor aparte (`toolbox`) que ya se levantó con el resto del `docker compose up`. Todo comando de estas dos prácticas que use alguna de estas herramientas va con el prefijo `docker compose exec toolbox <comando>`.

Verificá que la app responde antes de seguir:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8888/login
```

Debería devolver `200`. Con eso, continuá con el **Paso 1**.

---

**Siguiente →** [Paso 1](steps/step1.md)
