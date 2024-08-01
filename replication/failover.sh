#!/bin/bash

# failover.sh
# Скрипт для автоматического переключения на новый мастер при отказе текущего мастера

# Аргументы
FAILED_NODE_ID=$1
NEW_MASTER_NODE_ID=$2
FAILED_HOST=$3
NEW_MASTER_HOST=$4
FAILED_PORT=$5
NEW_MASTER_PORT=$6
OLD_MASTER_NODE_ID=$7

# Настройки подключения
PGUSER="postgres"
PGPASSWORD="pass"
PGDATABASE="postgres"

# Логи
LOGFILE="/var/log/pgpool/failover.log"

# Логирование
echo "$(date) - Failover triggered: Failed node: $FAILED_NODE_ID, New master: $NEW_MASTER_NODE_ID" >> $LOGFILE

# Функция для выполнения команд psql на удаленном хосте
exec_psql() {
  local host=$1
  local port=$2
  local query=$3
  PGPASSWORD=$PGPASSWORD psql -U $PGUSER -h $host -p $port -d $PGDATABASE -c "$query" >> $LOGFILE 2>&1
}

# Продвижение новой ноды в мастера
promote_new_master() {
  echo "$(date) - Promoting new master on host $NEW_MASTER_HOST" >> $LOGFILE
  exec_psql $NEW_MASTER_HOST $NEW_MASTER_PORT "SELECT pg_promote();"
}

# Проверка на то, что новая нода является мастером
check_new_master() {
  local master=$(PGPASSWORD=$PGPASSWORD psql -U $PGUSER -h $NEW_MASTER_HOST -p $NEW_MASTER_PORT -d $PGDATABASE -t -c "SELECT pg_is_in_recovery();" | tr -d '[:space:]')
  if [ "$master" = "f" ]; then
    echo "$(date) - New master promotion successful on host $NEW_MASTER_HOST" >> $LOGFILE
  else
    echo "$(date) - New master promotion failed on host $NEW_MASTER_HOST" >> $LOGFILE
    exit 1
  fi
}

# Основная логика
if [ $FAILED_NODE_ID -eq $OLD_MASTER_NODE_ID ]; then
  promote_new_master
  sleep 5
  check_new_master
else
  echo "$(date) - The failed node is not the master. No action required." >> $LOGFILE
fi

echo "$(date) - Failover process completed." >> $LOGFILE
exit 0
