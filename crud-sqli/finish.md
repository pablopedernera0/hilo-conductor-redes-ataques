# ¡Escenario completado!

Explotaste una inyección SQL real en el login de la app, primero a mano y después con una herramienta automatizada.

## Lo que hiciste

- **Identificaste el problema** — una consulta armada con f-string en vez de parámetros, en la ruta `/login`
- **Bypass manual** — entraste sin conocer ninguna contraseña, con `admin' -- ` y con `' OR '1'='1' -- `
- **sqlmap** — detectaste automáticamente el parámetro inyectable y volcaste la tabla `usuarios` completa con `--dump`

## Comandos clave para recordar

`curl` y `sqlmap` corridos acá van con el prefijo `docker compose exec toolbox` — viven en ese contenedor, no en tu máquina.

| Comando | Para qué sirve |
|---------|----------------|
| `curl --data-urlencode "campo=valor"` | Enviar un payload con caracteres especiales correctamente codificado |
| `sqlmap -u <url> --data="..." -p <parámetro> --batch` | Detectar si un parámetro POST es inyectable |
| `sqlmap ... --dbs` | Listar las bases de datos accesibles |
| `sqlmap ... --dump -D <db> -T <tabla>` | Volcar el contenido de una tabla específica |

## Conceptos clave

**Inyección SQL** — insertar código SQL a través de un dato de entrada que la aplicación no trata como dato, sino que pega directamente en la consulta.

**Consulta parametrizada** — la forma correcta de construir queries con datos externos: el valor viaja separado de la estructura SQL, y el driver se encarga de escaparlo. Es lo que ya usaban `/nuevo`, `/editar` y `/eliminar` en esta misma app — el problema estaba únicamente en `/login`.

**Boolean-based blind SQLi** — técnica que infiere información comparando las respuestas de condiciones verdaderas y falsas, sin necesidad de que la aplicación devuelva el resultado de la consulta directamente.

## Cómo se arregla (sin tocarlo hoy)

El fix es una línea: reemplazar el f-string por una consulta parametrizada, igual que en el resto de la app:

```python
query = "SELECT id, usuario FROM usuarios WHERE usuario = %s AND password = %s"
cur.execute(query, (usuario, password))
```

Con eso, cualquier comilla o `--` que mandes queda tratado como texto literal, no como parte del SQL.

## Próximo paso

En la próxima práctica vamos a analizar, con herramientas de línea de comandos, qué evidencia dejaron en los logs cada uno de los ataques de estas dos últimas prácticas: el reconocimiento, la fuerza bruta y esta inyección SQL.

---

**← Anterior:** [Paso 4](steps/step4.md)
