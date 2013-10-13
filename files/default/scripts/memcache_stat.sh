#!/bin/bash
# Скрипт взят отсюда http://wiki.enchtex.info/howto/zabbix/zabbix_memcache_monitoring и немного переделан
export PATH='/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin'
##### OPTIONS VERIFICATION #####
if [[ -z "$1" || -z "$2" ]]; then
    exit 1
fi
##### PARAMETERS #####
RESERVED="$1"
METRIC="$2"
TTLCACHE="55"
FILECACHE="/tmp/zabbix.memcache.cache"
TIMENOW=$(date '+%s')
##### RUN #####
if [ -s "$FILECACHE" ]; then
    TIMECACHE=$(stat -c"%Z" "$FILECACHE")
else
    TIMECACHE=0
fi
 
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$TTLCACHE" ]; then
    echo "" >> $FILECACHE # !!!
    DATACACHE=$(echo -e "stats\nquit" | nc -q2 127.0.0.1 11211) || exit 1
    echo "$DATACACHE" > $FILECACHE # !!!
fi
#
cat $FILECACHE | grep -i "STAT $METRIC " | awk '{print $3}'
#
exit 0
