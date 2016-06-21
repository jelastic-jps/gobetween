#!/bin/bash

GB_CONFIG="/usr/local/etc/haproxy/haproxy.cfg";
GB_BIN="/usr/bin/gobetween";

echo "$@" >> /var/log/lb_manager.log

function add_hosts(){
for host in ${hosts}
    do
        grep -q "${host}:[0-9]* " $GB_CONFIG && return 0;
        count=$(cat $GB_CONFIG | grep -o "webserver[0-9]*" | sed 's/webserver//g' | sort -n | tail -n1);
        let "count+=1";
        sed -i "/backend bk_http ###HOSTS/a\server webserver${count} ${host}:80 #webserver${count}" $GB_CONFIG;
    done
    kill -9 $GB_BIN > /dev/null 2>&1
    $GB_BIN -c "$GB_CONFIG"
}



function remove_host(){
    sed -i '/.*#webserver.*'${host}'/d' $GB_CONFIG;
    kill -9 $GB_BIN > /dev/null 2>&1
    $GB_BIN -c "$GB_CONFIG"
}

while [ "$1" != "" ];
   do
    case $1 in

    --addhosts )                    shift;
                                    hosts="$@";
                                    add_hosts;
                                    ;;
    --removehost )                  shift;
                                    host="$1";
                                    remove_host;
                                    ;;
    esac
    shift
  done
