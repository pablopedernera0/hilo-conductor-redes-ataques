FROM python:3.11-slim

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

EXPOSE 8888

CMD ["python", "app.py"]
