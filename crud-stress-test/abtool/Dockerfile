FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends apache2-utils \
    && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
