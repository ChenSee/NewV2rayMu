#!/bin/bash
v2ray_realpath=/etc/v2ray/bin/v2ray
v2muctl_realpath=$(readlink -f v2mctl)
v2ray_pid=$(ps ux | grep "/etc/v2ray/bin/v2ray" | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps ux | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')
if [ ! $v2ray_pid ]; then
    echo 'Starting V2Ray'
else
    echo 'Restarting V2Ray (pid:'$v2ray_pid')'
    kill -9 $v2ray_pid
fi

if [ ! $v2muctl_pid ]; then
    echo 'Starting V2Ray-mu Manager'
else
    echo 'Retarting V2Ray-mu Manager (pid:'$v2muctl_pid')'
    kill -9 $v2muctl_pid
fi

cd log
rm -rf v2ray-mu.log
touch v2ray-mu.log
cd ..
echo "All Logs Clear!"

if [ $(grep -c "api" /etc/v2ray/conf/*.json) == "0" ]; then
    sed -i 's/\] \} \} \] \}/] } } ,{ "listen": "127.0.0.1", "port": 8301, "protocol": "dokodemo-door", "settings": { "address": "0.0.0.0" }, "tag": "api" }],"api": { "services": [ "HandlerService", "StatsService" ], "tag": "api" },"outbounds": [ { "tag": "direct", "protocol": "freedom", "settings": { } } ], "routing": { "settings": { "rules": [ { "inboundTag": [ "api" ], "outboundTag": "api", "type": "field" } ] }, "strategy": "rules" } }/' /etc/v2ray/conf/*.json
fi

nohup v2ray bin run -config /etc/v2ray/conf/*.json >>/dev/null 2>&1 &
echo 'Preparing...'
sleep 3
nohup $(readlink -f v2mctl) >>/dev/null 2>&1 &
sleep 1

v2ray_pid=$(ps ux | grep "/etc/v2ray/bin/v2ray" | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps ux | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')

if [ ! $v2ray_pid ]; then
    echo -e "\033[31m***Fail to start V2Ray***\033[0m"
else
    echo -e "\033[32mSuccess to start V2Ray (pid:'$v2ray_pid')\033[0m"
fi

if [ ! $v2muctl_pid ]; then
    echo -e "\033[31m***Fail to start V2Ray-mu Manager***\033[0m"
else
    echo -e "\033[32mSuccess to start V2Ray-mu Manager (pid:'$v2muctl_pid')\033[0m"
fi
