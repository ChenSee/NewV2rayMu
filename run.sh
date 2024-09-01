#!/bin/bash
v2ray_realpath=/usr/local/bin/xray
v2ray_confpath=/usr/local/etc/xray
v2muctl_realpath=$(readlink -f v2mctl)
v2ray_pid=$(ps ux | grep $v2ray_realpath | grep -v grep | awk '{print $2}')
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
rm -rf v2ray.log
touch v2ray.log
rm -rf v2ray-mu.log
touch v2ray-mu.log
cd ..
echo "All Logs Clear!"
source ./mu.conf
export MU_URI=$MU_URI
export MU_TOKEN=$MU_TOKEN
export MU_NODE_ID=$NodeId
export SYNC_TIME=$SYNC_TIME
export V2RAY_ADDR=$V2RAY_ADDR
export V2RAY_TAG=$V2RAY_TAG

if [ $(grep -c "api" $v2ray_confpath/*.json) == "0" ]; then
    sed -i 's/\/\/.*//g' $v2ray_confpath/*.json
    sed -i ":a;N;s/\n//g;ta" $v2ray_confpath/*.json
    sed -i "s/ //g" $v2ray_confpath/*.json
    sed -i 's/"inbounds":\[/"inbounds":[{"listen":"127.0.0.1","port":8301,"protocol":"dokodemo-door","settings":{"address":"0.0.0.0"},"tag":"api"},/' $v2ray_confpath/*.json
    sed -i 's/"inbounds":\[/"policy":{"levels":{"2":{"handshake":4,"connIdle":300,"uplinkOnly":5,"downlinkOnly":30,"statsUserUplink":true,"statsUserDownlink":true,"bufferSize":50},"0":{"handshake":4,"connIdle":300,"uplinkOnly":5,"downlinkOnly":30,"statsUserUplink":true,"statsUserDownlink":true,"bufferSize":50}}},"stats":{},"api":{"services":["HandlerService","StatsService"],"tag":"api"},"inbounds":[/' $v2ray_confpath/*.json
    sed -i 's/"rules":\[/"rules":[{"inboundTag":["api"],"outboundTag":"api","type":"field"},/' $v2ray_confpath/*.json
    # sed -i 's/"clients":.*"streamSettings/"clients":[]},"streamSettings/' $v2ray_confpath/*.json
fi

# nohup /usr/bin/env xray.ray.buffer.size=1 $v2ray_realpath run -config $v2ray_confpath/*.json >> log/v2ray.log &
sing-box restart
echo 'Preparing...'
sleep 3
nohup $(readlink -f v2mctl) >>/dev/null 2>&1 &
sleep 1

v2ray_pid=$(ps ux | grep $v2ray_realpath | grep -v grep | awk '{print $2}')
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
