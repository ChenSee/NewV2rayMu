#!/bin/bash
v2ray_realpath=/usr/local/bin/xray
v2ray_pid=$(ps -ef | grep $v2ray_realpath | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps -ef | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')

if [ ! $v2ray_pid ];
then
echo 'V2ray is not running, nothing to do.'
else
echo 'Stopping V2Ray (pid:'$v2ray_pid')'
kill -9 $v2ray_pid
echo 'V2Ray is DOWN'
fi

if [ ! $v2muctl_pid ];
then
echo 'V2ray-Mu Manager is not running, nothing to do.'
else
echo 'Stopping V2Ray-Mu Manager (pid:'$v2muctl_pid')'
kill -9 $v2muctl_pid
echo 'V2Ray-Mu Manager is DOWN'
fi
