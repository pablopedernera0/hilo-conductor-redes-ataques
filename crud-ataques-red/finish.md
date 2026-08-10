# ¡Escenario completado!

Atacaste la infraestructura CRUD que veníamos desplegando y midiendo, usando técnicas reales de reconocimiento y fuerza bruta.

## Lo que hiciste

- **Reconocimiento externo** — escaneaste con `nmap` los puertos publicados al host (80, 8080, 8888) e identificaste los servicios
- **Reconocimiento interno** — inspeccionaste la red de Docker y encontraste que MySQL, aunque no está publicado al host, es visible dentro de la red interna
- **Credenciales expuestas** — encontraste la contraseña de MySQL hardcodeada en el código fuente público y la usaste para acceder directo a la base
- **Fuerza bruta** — usaste `hydra` para probar una wordlist contra el login de la app hasta dar con la contraseña correcta

## Comandos clave para recordar

| Comando | Para qué sirve |
|---------|----------------|
| `nmap -sV -p <puertos> <host>` | Escanear puertos específicos e identificar el servicio/versión |
| `docker network inspect <red>` | Ver qué contenedores están conectados a una red y sus IPs |
| `grep -n -i "password" <archivo>` | Buscar credenciales hardcodeadas en código fuente |
| `hydra -l <usuario> -P <wordlist> <host> -s <puerto> http-post-form "..."` | Fuerza bruta contra un formulario de login web |

## Conceptos clave

**Reconocimiento** — la etapa de mapear qué servicios y versiones están expuestos, antes de intentar explotar nada.

**Superficie de ataque interna vs. externa** — un servicio no publicado al host puede seguir siendo alcanzable desde dentro de la misma red.

**Secretos hardcodeados** — una credencial en el código viaja con cada copia del repositorio; si el repo es público (o se filtra), la credencial también lo es.

**Fuerza bruta** — probar sistemáticamente combinaciones de credenciales contra un servicio, hasta encontrar una válida. Se frena con rate-limiting, bloqueo de cuenta, CAPTCHA o tokens anti-CSRF.

## Próximo paso

En la próxima práctica vamos a explotar una vulnerabilidad puntual en la forma en que `/login` arma su consulta SQL: **inyección SQL**, manual y con `sqlmap`. A diferencia de la fuerza bruta, no va a hacer falta adivinar ninguna contraseña.
