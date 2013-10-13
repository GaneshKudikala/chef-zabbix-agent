#!/bin/bash
### Автор скрипта - sirkonst@gmail.com
### Сайт поддержки - http://wiki.enchtex.info/howto/zabbix/nginx_monitoring

### СКРИПТ ДОРАБОТАН И ОТЛИЧАЕТСЯ ОТ ТОГО, ЧТО ПО ССЫЛКЕ
### СПИСОК ИЗМЕНЕНИЙ:
# 1. Добавлены переменные для команд, различных в Linux и FreeBSD
# 2. Из вывода убираются лишние пробелы
 
### DESCRIPTION
# $1 - имя узла сети в zabbix'е (не используется)
# $2 - измеряемая метрика
# $3 - http-сслыка на страницу nginx-stats
export PATH='/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin' 
### OPTIONS VERIFICATION
if [[ -z "$1" || -z "$2" ]]; then
    exit 1
 fi
 
if [[ "$3" = "none" ]]; then
    exit 1
fi
 
### PARAMETERS
METRIC="$2"  # измеряемая метрика
STATURL="$3" # адрес nginx статистики
 
CURL=curl

case $(uname) in
    FreeBSD)
        MD5SUM='md5'
        STAT_TIME='stat -f%m'
        ;;
    Linux)
        MD5SUM='md5sum'
        STAT_TIME='stat -c%Z'
        ;;
    *)
        MD5SUM='md5sum'
        STAT_TIME='stat -c%Z'
        ;;
esac
 
CACHETTL="55" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/nginx-stats-$(echo $STATURL | ${MD5SUM} | cut -d" " -f1).cache"
 
### RUN
## Проверка кеша:
# время создание кеша (или 0 есть файл кеша отсутствует или имеет нулевой размер)
if [ -s "$CACHE" ]; then
    TIMECACHE=$(${STAT_TIME} "${CACHE}")
else
    TIMECACHE=0
fi

# текущее время
TIMENOW=$(date '+%s')
# Если кеш неактуален, то обновить его (выход при ошибке)
if [ "$((${TIMENOW}-${TIMECACHE}))" -gt "${CACHETTL}" ]; then
    $CURL -s --insecure "$STATURL" > $CACHE || echo 0
fi
  
## Извлечение метрики:
if [ "$METRIC" = "active" ]; then
    cat $CACHE | grep "Active connections" | cut -d':' -f2 | tr -d ' '
 fi
if [ "$METRIC" = "accepts" ]; then
    cat $CACHE | sed -n '3p' | cut -d" " -f2 | tr -d ' '
 fi
if [ "$METRIC" = "handled" ]; then
    cat $CACHE | sed -n '3p' | cut -d" " -f3 | tr -d ' '
 fi
if [ "$METRIC" = "requests" ]; then
    cat $CACHE | sed -n '3p' | cut -d" " -f4 | tr -d ' '
 fi
if [ "$METRIC" = "reading" ]; then
    cat $CACHE | grep "Reading" | cut -d':' -f2 | cut -d' ' -f2 | tr -d ' '
 fi
if [ "$METRIC" = "writing" ]; then
    cat $CACHE | grep "Writing" | cut -d':' -f3 | cut -d' ' -f2 | tr -d ' '
 fi
if [ "$METRIC" = "waiting" ]; then
    cat $CACHE | grep "Waiting" | cut -d':' -f4 | cut -d' ' -f2 | tr -d ' '
 fi
 
exit 0
