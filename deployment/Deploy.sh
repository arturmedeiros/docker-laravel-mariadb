#!/bin/bash
clear
echo "=================================================
                LARAVEL 10 PROJECT
-------------------------------------------------
                   Open Source
        Author: ARJOS (https://arjos.eu)
================================================="
echo "🏗️ Iniciando a instalação do seu projeto..."

docker info > /dev/null 2>&1

# Ensure that Docker is running...
if [ $? -ne 0 ]; then
    echo "O Docker não está rodando no seu servidor... Instalação não realizada!"
    exit 1
fi

# DEFAULT
IP=''
APP_PORT=9001
PMA_HOST=database
PMA_PORT=9999
DB_PORT=3306
DB_HOST=database
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
CACHE_DRIVER=redis

echo "⚙️  Configurando opções da aplicação..."
# IP
read -p "⚠️  Qual o endereço de IP do seu servodor? (Ex: 192.168.15.0) " resposta_ip
resposta_lower_ip=$(echo "$resposta_ip" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_ip ]]; then
    IP="$resposta_lower_ip"
else
    echo "$IP"
fi

# APP_PORT
read -p "⚠️  Qual a porta que deseja rodar o seu projeto? (Ex: 80) " resposta_port
resposta_lower_port=$(echo "$resposta_port" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_port ]]; then
    APP_PORT="$resposta_lower_port"
else
    echo "$APP_PORT"
fi

# PMA_HOST
read -p "⚠️  Qual a porta que deseja rodar o PHPMyAdmin? (Ex: 9000) " resposta_port_pma
resposta_lower_port_pma=$(echo "$resposta_port_pma" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_port_pma ]]; then
    PMA_PORT="$resposta_lower_port_pma"
else
    echo "$PMA_PORT"
fi

# DB_PORT
read -p "⚠️  Qual a porta que deseja rodar o seu Banco de Dados MySQL? (Ex: 3306) " resposta_port_db
resposta_lower_port_db=$(echo "$resposta_port_db" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_port_db ]]; then
    DB_PORT="$resposta_lower_port_db"
else
    echo "$DB_PORT"
fi

# DB_DATABASE
read -p "⚠️  Qual ao nome do seu banco de dados? (Ex: laravel) " resposta_db
resposta_lower_db=$(echo "$resposta_db" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_db ]]; then
    DB_DATABASE="$resposta_lower_db"
else
    echo "$DB_DATABASE"
fi

# DB_USERNAME
read -p "⚠️  Qual o nome de usuário do seu banco de dados? (Ex: laravel) " resposta_db_user
resposta_lower_db_user=$(echo "$resposta_db_user" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_db_user ]]; then
    DB_USERNAME="$resposta_lower_db_user"
else
    echo "$DB_USERNAME"
fi

# DB_PASSWORD
read -p "⚠️  Qual a senha do seu banco de dados? (Ex: laravel_pwd) " resposta_db_pwd
resposta_lower_db_pwd=$(echo "$resposta_db_pwd" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_db_pwd ]]; then
    DB_PASSWORD="$resposta_lower_db_pwd"
else
    echo "$DB_PASSWORD"
fi

# Baixa Repo
echo "📦  Baixando repositório..."
git clone https://github.com/arturmedeiros/docker-laravel-mariadb.git
echo "✅  Etapa concluída!"

## Permissão na pasta
echo "🔒 Concedendo permissões..."
chmod +x docker-laravel-mariadb
sudo chmod 777 -R docker-laravel-mariadb/backend/
echo "✅  Etapa concluída!"

# Cria o .env do projeto Laravel
echo "🔥  Configurando projeto..."

if [ -f "docker-laravel-mariadb/.env" ]; then
    rm -R docker-laravel-mariadb/.env
fi

# Adiciona variáveis no novo arquivo .env.example
echo "
APP_PORT=${APP_PORT}
PMA_HOST=${PMA_HOST}
PMA_PORT=${PMA_PORT}
DB_PORT=${DB_PORT}
DB_HOST=${DB_HOST}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
#CACHE_DRIVER=${CACHE_DRIVER}

WWWUSER=1000
WWWGROUP=1000
VITE_PORT=
TZ=${CACHE_DRIVER-'America/Sao_Paulo'}
" >> docker-laravel-mariadb/.env

# Copia a base padrão do .env do Laravel
cp docker-laravel-mariadb/.env docker-laravel-mariadb/backend/.env

# Cria Docker Compose Padrão
if [ -f "docker-laravel-mariadb/docker-compose.yaml" ]; then
    rm -R docker-laravel-mariadb/docker-compose.yaml
fi

echo "# docker-compose.yml
# Cria a rede
networks:
  sail:
    driver: bridge

# Inicializa os Containers
services:
  # Laravel APP
  backend:
    container_name: backend
    build:
      context: ./backend/vendor/laravel/sail/runtimes/8.2
      dockerfile: Dockerfile
      args:
        WWWGROUP: '${WWWGROUP}'
    image: ms-arjos/laravel-sail-8.2
    extra_hosts:
      - 'host.docker.internal:host-gateway'
    ports:
      - ${APP_PORT:-80}:80
      - '${VITE_PORT:-5173}:${VITE_PORT:-5173}'
    environment:
      WWWUSER: '${WWWUSER}'
      LARAVEL_SAIL: 1
      XDEBUG_MODE: '${SAIL_XDEBUG_MODE:-off}'
      XDEBUG_CONFIG: '${SAIL_XDEBUG_CONFIG:-client_host=host.docker.internal}'
      IGNITION_LOCAL_SITES_PATH: '${PWD}'
    volumes:
      - './backend/:/var/www/html'
      - '.env:/var/www/html/.env'
    working_dir: /var/www/html
    networks:
      - sail

  # Nginx
  #proxy:
  #  image: nginx:1.25
  #  container_name: proxy
  #  ports:
  #    - "${APP_PORT-9000}:80"
  #  volumes:
  #    - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
  #  depends_on:
  #    - backend
  #  networks:
  #    - sail

  # DB MySQL
  database:
    image: mariadb
    container_name: database
    restart: unless-stopped
    environment:
      MYSQL_USER: ${DB_USERNAME-laravel_vault}
      MYSQL_PASSWORD: ${DB_PASSWORD-laravel_vault_pwd}
      MYSQL_DATABASE: ${DB_DATABASE-laravel_vault}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD-laravel_vault_pwd}
    volumes:
      - ./database/mysql:/var/lib/mysql
    networks:
      - sail

  # PHPMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    restart: always
    depends_on:
      - database
    environment:
      PMA_HOST: database
      PMA_PORT: ${DB_PORT-3306}
      PMA_ARBITRARY: 1
      PMA_CONTROLHOST: database
      PMA_CONTROLPORT: ${DB_PORT-3306}
    volumes:
      - ./docker/php/custom.ini:/usr/local/etc/php/conf.d/uploads.ini
    ports:
      - ${PMA_PORT-8888}:80
    networks:
      - sail

  # Optional Installations
  # Redis (OPTIONAL)
  cache:
    image: redis:7
    container_name: cache
    networks:
      - sail
" > docker-laravel-mariadb/docker-compose.yml
echo "✅  Etapa concluída!"


# Colocar de forma mais permanente
echo "🚀  Inicializando aplicações..."
cd docker-laravel-mariadb/ && docker-compose --env-file .env up -d
docker exec backend sh -c "composer install && php artisan key:generate --force && php artisan jwt:secret && php artisan migrate --seed --force && php artisan storage:link"
echo "✅  Etapa concluída!"

echo "
=======================================================
  ACESSE SUA APLICAÇÃO!
-------------------------------------------------------
  Sua aplicação: http://${IP}:${APP_PORT}
  PHPMyAdmin: http://${IP}:${PMA_PORT}
=======================================================
"

# Steps:
# 1) nano Deploy.sh
# 2) chmod +x Deploy.sh
# 3) bash ./Deploy.sh

# Automático
# curl -s "https://raw.githubusercontent.com/arturmedeiros/docker-laravel-mariadb/master/deployment/Deploy.sh" | bash

# Personalizado
# bash <(curl -s "https://raw.githubusercontent.com/arturmedeiros/docker-laravel-mariadb/master/deployment/Deploy.sh")
