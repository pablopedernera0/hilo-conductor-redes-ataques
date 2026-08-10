#!/bin/bash
# =============================================================================
#  setup.sh — crud-sqli
#  Prepara el entorno para la práctica de inyección SQL
#  Se ejecuta una sola vez al inicio del escenario
# =============================================================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() { echo -e "\n${CYAN}[$1]${NC} $2"; }
ok()     { echo -e "${GREEN}  ✓${NC} $1"; }
warn()   { echo -e "${YELLOW}  ⚠${NC} $1"; }

echo ""
echo "=============================================="
echo "  Preparando entorno — crud-sqli"
echo "=============================================="

# ── 1. Dependencias del sistema ────────────────────────────────────────────
banner "1/5" "Instalando dependencias del sistema..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    docker-compose \
    python3-pip \
    git \
    sqlmap
ok "Dependencias del sistema instaladas (incluye sqlmap)"

# ── 2. Dependencias Python ─────────────────────────────────────────────────
banner "2/5" "Instalando dependencias Python..."
pip3 install flask mysql-connector-python \
    --break-system-packages --ignore-installed --quiet
ok "flask y mysql-connector-python instalados"

# ── 3. Levantar MySQL + PhpMyAdmin + Nginx con Docker Compose ──────────────
banner "3/5" "Levantando servicios con Docker Compose..."

mkdir -p /root/crud-sqli

cat > /root/crud-sqli/docker-compose.yml << 'EOF'
version: '3'
services:

  mysql:
    image: mysql:latest
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: mysecretpassword
    networks:
      - mynetwork

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    restart: always
    ports:
      - 8080:80
    environment:
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: mysecretpassword
    depends_on:
      - mysql
    networks:
      - mynetwork

  web:
    image: nginx
    ports:
      - "80:80"
    networks:
      - mynetwork

networks:
  mynetwork:
EOF

cd /root/crud-sqli
docker-compose up -d
ok "Contenedores iniciados"

# ── 4. Esperar MySQL y crear las tablas ────────────────────────────────────
banner "4/5" "Esperando MySQL y creando las tablas..."

echo -n "  Esperando MySQL"
MYSQL_READY=0
for i in $(seq 1 30); do
    if docker exec "$(docker ps -qf "name=mysql")" \
        mysqladmin ping -h 127.0.0.1 -uroot -pmysecretpassword --silent 2>/dev/null; then
        echo ""
        ok "MySQL listo"
        MYSQL_READY=1
        break
    fi
    echo -n "."
    sleep 2
done

if [ "$MYSQL_READY" -eq 0 ]; then
    warn "MySQL tardó demasiado. Reintentando en 10 segundos..."
    sleep 10
fi

docker exec -i "$(docker ps -qf "name=mysql")" \
    mysql -h 127.0.0.1 -uroot -pmysecretpassword << 'EOSQL'
CREATE DATABASE IF NOT EXISTS alumnos;
USE alumnos;

CREATE TABLE IF NOT EXISTS alumnos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL
);
INSERT INTO alumnos (nombre, apellido, fecha_nacimiento) VALUES
  ('Juan', 'Perez', '2000-01-01'),
  ('Maria', 'Gomez', '1999-05-15'),
  ('Pedro', 'Lopez', '2001-10-20'),
  ('Ana', 'Martinez', '1998-03-08'),
  ('Luis', 'Rodriguez', '2002-07-12');

CREATE TABLE IF NOT EXISTS usuarios (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(50) NOT NULL
);
INSERT INTO usuarios (usuario, password) VALUES
  ('admin', 'admin123'),
  ('soporte', 'sopor23!');
EOSQL
ok "Base 'alumnos' con datos semilla y tabla 'usuarios' creadas"

# ── 5. Clonar el CRUD (branch feature-login) y levantarlo ─────────────────
banner "5/5" "Clonando la app Flask (con login vulnerable) y conectándola a MySQL..."

MYSQL_IP=$(docker inspect \
    "$(docker ps -qf "name=mysql")" \
    --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

cd /root
git clone --branch feature-login https://github.com/pablopedernera0/crud-python.git 2>/dev/null || true
sed -i "s/172.18.0.2/$MYSQL_IP/" /root/crud-python/app.py

cd /root/crud-python
nohup python3 app.py > /root/crud-python/app.log 2>&1 &

echo -n "  Esperando la app Flask"
for i in $(seq 1 20); do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8888/login 2>/dev/null || echo "000")
    if [ "$CODE" = "200" ]; then
        echo ""
        ok "App Flask lista en el puerto 8888"
        break
    fi
    echo -n "."
    sleep 2
done

# ── Resumen ──────────────────────────────────────────────────────────────────
echo ""
echo "=============================================="
echo -e "${GREEN}  Entorno listo. Podés continuar con el Paso 1.${NC}"
echo "=============================================="
echo ""
echo "  Servicios corriendo:"
echo "    MySQL       → red interna Docker"
echo "    PhpMyAdmin  → puerto 8080"
echo "    Nginx       → puerto 80"
echo "    CRUD Flask  → puerto 8888 (login vulnerable a SQLi)"
echo ""
echo "  Próximo paso: revisitar la consulta del login."
echo "=============================================="
echo ""
