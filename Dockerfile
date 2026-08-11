FROM python:3.11-slim

# Solo se usan si se pasan como build-args (ver docker-compose.yml) -- en blanco no
# afectan nada. Hacen falta detrás de un proxy corporativo para que git/apt/pip salgan
# a internet durante el build; el contenedor en runtime no los necesita (no sale a
# internet, solo habla con el servicio "mysql" de la red interna).
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV no_proxy=$NO_PROXY

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir flask mysql-connector-python

RUN git clone --branch feature-login --depth 1 \
    https://github.com/pablopedernera0/crud-python.git /app

WORKDIR /app

# La app trae hardcodeada la IP de MySQL de un docker-compose distinto (la de las
# prácticas de Killercoda). Acá la apuntamos al nombre del servicio "mysql" -- Docker
# Compose resuelve ese nombre por DNS interno, no hace falta conocer ninguna IP.
RUN sed -i "s/172.18.0.2/mysql/" app.py

# El proxy de arriba es solo para el build (git/pip) -- se limpia para que no quede
# activo en runtime, aunque hoy esta app no haga llamadas HTTP salientes (ver el mismo
# bug real, encontrado y corregido en toolbox/Dockerfile).
ENV http_proxy=""
ENV https_proxy=""
ENV no_proxy=""

EXPOSE 8888

CMD ["python", "app.py"]
