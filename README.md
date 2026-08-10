# Hilo conductor de redes — etapas de ataque (pausadas)

Contenido de las etapas 3 (`crud-ataques-red`) y 4 (`crud-sqli`) del hilo conductor de
redes, sacadas de `la-cajonera` (el repo linkeado a Killercoda) el 2026-08-10.

## Por qué está acá y no en Killercoda

Al correr `ab` (Apache Bench, en la Etapa 1) la cuenta de Killercoda quedó bloqueada por
"illegal activity... cryptominers, security scanners, bruteforce or hacker-tools". Estas
dos etapas instalan y ejecutan `nmap` (security scanner), `hydra` (bruteforce) y `sqlmap`
(hacker-tool) — exactamente las categorías que Killercoda prohíbe explícitamente. Hipótesis
sin confirmar: el bloqueo pudo depender del contenido del repo completo (estos `setup.sh`
ya estaban pusheados en `la-cajonera`), no solo de lo que se ejecutó en la sesión activa —
por eso se sacó el contenido del repo linkeado, en vez de solo dejar de usarlo.

## Estado

- [ ] Confirmar si sacar este contenido de `la-cajonera` destraba la cuenta
- [ ] Definir destino final: migrar a una VM local (VirtualBox, TP N°5 del programa de
      Infraestructura de Redes) en vez de Killercoda
- [ ] Etapa 1 (`crud-stress-test`, sigue en `la-cajonera`) — evaluar si reemplazar `ab` por
      un loop de `curl` reduce el riesgo, o si el problema era este contenido y `ab` nunca
      fue el disparador real

## Contenido

- `crud-ataques-red/` — reconocimiento con nmap, credenciales hardcodeadas, fuerza bruta con hydra
- `crud-sqli/` — bypass manual y sqlmap contra la inyección SQL de `crud-auth-login`

Ambas etapas asumen la misma infraestructura (MySQL + `crud-python`, branch `feature-login`)
documentada en `la-cajonera/CLAUDE.md` y `la-cajonera/hilo-conductor-redes/GUIA-DOCENTE-HILO-REDES.md`.
