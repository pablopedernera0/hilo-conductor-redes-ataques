FROM debian:bookworm-slim

# Solo se usan si se pasan como build-args (ver docker-compose.yml) -- en blanco no
# afectan nada. Hacen falta detrás de un proxy corporativo para que apt/git/pip salgan
# a internet durante el build.
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV no_proxy=$NO_PROXY

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        nmap \
        hydra \
        git \
        python3 \
        curl \
        default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# sqlmap es Python puro -- no hace falta compilar nada, alcanza con clonar el repo.
RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap \
    && printf '#!/bin/sh\nexec python3 /opt/sqlmap/sqlmap.py "$@"\n' > /usr/local/bin/sqlmap \
    && chmod +x /usr/local/bin/sqlmap

# El proxy de arriba es solo para bajar paquetes/clonar durante el build. Si quedara
# activo en runtime, curl/sqlmap/hydra intentarían salir por el proxy corporativo para
# atacar host.docker.internal/mysql/app -- objetivos locales que el proxy no sabe rutear
# (bug real, encontrado probando curl contra host.docker.internal: devolvía un 503 del
# proxy en vez de pegarle a la app). Se limpia acá, antes de que el contenedor quede vivo.
ENV http_proxy=""
ENV https_proxy=""
ENV no_proxy=""

# Este contenedor no corre nada por sí solo -- se queda vivo para que los pasos de la
# práctica le manden comandos con "docker compose exec toolbox <comando>".
CMD ["sleep", "infinity"]
