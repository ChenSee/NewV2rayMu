#!/bin/bash
v2ray_realpath=$(readlink -f v2ray)
cfg_realpath=$(readlink -f cfg.json)
v2muctl_realpath=$(readlink -f v2mctl)
v2ray_pid=$(ps ux | grep "$(readlink -f v2ray)" | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps ux | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')
if [ ! $v2ray_pid ];
then
    echo 'Starting V2Ray'
else
    echo 'Restarting V2Ray (pid:'$v2ray_pid')'
    kill -9 $v2ray_pid
fi

if [ ! $v2muctl_pid ];
then
echo 'Starting V2Ray-mu Manager'
else
echo 'Retarting V2Ray-mu Manager (pid:'$v2muctl_pid')'
kill -9 $v2muctl_pid
fi

cd log
rm -rf access.log
touch access.log
rm -rf error.log
touch error.log
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

sed -i "11c \ \ \ \ \"port\": $NodePort," cfg.json
sed -i "17c \ \ \ \ \ \ \"network\": \"$NetWork\"," cfg.json
sed -i "19c \ \ \ \ \ \ \"security\": \"$SecuritySetting\"," cfg.json
sed -i "21c \ \ \ \ \ \ \ \ \"serverName\": \"$Domain\"," cfg.json
sed -i "22c \ \ \ \ \ \ \ \ \"allowInsecure\": $AllowInsecure," cfg.json
sed -i "29c \ \ \ \ \ \ \ \ \ \ \ \ \"certificateFile\": \"$CertificateFile\"," cfg.json
sed -i "30c \ \ \ \ \ \ \ \ \ \ \ \ \"keyFile\": \"$KeyFile\"" cfg.json
sed -i "44c \ \ \ \ \ \ \ \ \ \ \"type\": \"$ObfsType\"" cfg.json
sed -i "48c \ \ \ \ \ \ \ \ \"path\": \"$WsPath\"" cfg.json

nohup env v2ray.vmess.aead.forced=false $(readlink -f v2ray) run -c $(readlink -f cfg.json)>> /dev/null 2>&1 &
echo 'Preparing...'
sleep 3
nohup $(readlink -f v2mctl)>> /dev/null 2>&1 &
sleep 1

v2ray_pid=$(ps ux | grep "$(readlink -f v2ray)" | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps ux | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')

if [ ! $v2ray_pid ];
then
    echo -e "\033[31m***Fail to start V2Ray***\033[0m"
else
    echo -e "\033[32mSuccess to start V2Ray (pid:'$v2ray_pid')\033[0m"
fi

if [ ! $v2muctl_pid ];
then
echo -e "\033[31m***Fail to start V2Ray-mu Manager***\033[0m"
else
echo -e "\033[32mSuccess to start V2Ray-mu Manager (pid:'$v2muctl_pid')\033[0m"
fi
