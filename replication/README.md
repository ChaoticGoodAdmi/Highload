# Инструкция по запуску приложения с репликацией данных с использованием pgpool-II

## Предварительные требования

Для запуска данного приложения вам понадобятся следующие инструменты:

- Git
- Docker
- Docker Compose



## 1. Клонируйте основной репозиторий вместе с подмодулями:
```
git clone --recurse-submodules https://github.com/ChaoticGoodAdmi/OtusHub.git
```

Для корректной работы приложения переменные среды уже заданы, но их можно изменить по желанию.

## 2. Перейдите в директорию replication, если вы еще не там:
```
    cd Highload/replication
```

## 3. Соберите и запустите Docker-контейнеры:
```
    docker network create otus-network
    docker-compose up --build
```

Эта команда выполнит следующие шаги:

- Соберет контейнеры для всех сервисов (backend, frontend, postgres).
- Запустит контейнеры в соответствии с конфигурацией, указанной в `docker-compose.yml`.

## 4. Добавьте следующие настройки в postgresql.conf контейнера postgres-master:
```
ssl = off
wal_level = replica
max_wal_senders = 4
```
## 5. Создайте пользователя для репликации:
```sql
docker exec -it postgres-master su - postgres -c psql
create role replicator with login replication password 'pass';
exit
```
## 6. Добавьте запись в postgres-master/pg_hba.conf, заменив __SUBNET__ на адрес подсети otus_network
```
host    replication     replicator       __SUBNET__          md5
```
## 7. Добавьте записи в postgresslaveone и postgresslavetwo postgresql.conf
```
primary_conninfo = 'host=postgres-master port=5432 user=replicator password=pass application_name=postgresslaveone'
primary_conninfo = 'host=postgres-master port=5432 user=replicator password=pass application_name=postgresslavetwo'
```
## 8. Чтобы включить синхронную репликацию добавьте в файл postgres-master/postgresql.conf

```
synchronous_commit = on
synchronous_standby_names = 'FIRST 1 (postgresslaveone, postgresslavetwo)'
```
