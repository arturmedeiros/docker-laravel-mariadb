# Desenvolvimento
### Inicializar localmente primeira vez
```shell
cd .. && bash <(curl -s "https://raw.githubusercontent.com/arturmedeiros/docker-laravel-mariadb/master/deployment/Deploy.sh") && docker exec -it backend sh -c 'composer install && php artisan migrate'
```

### Iniciar projeto
````shell
docker-compose --env-file .env up -d
````

### Acessar bash do container do Laravel
```shell
docker exec -it backend sh
```
