#!/bin/bash
v2ray_realpath=/usr/local/bin/xray
update_pid=$(ps -ef | grep "./update.sh" | grep -v grep | awk '{print $2}')
v2ray_pid=$(ps -ef | grep $v2ray_realpath | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps -ef | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')
if [ $update_pid ]; then
    echo "`date`: Updating, skip status check." >> log/auto_restart.log
    exit
fi
source ./mu.conf
if [ ! $v2ray_pid ]
then
	./run.sh
	echo "`date`: Auto Restart/Start V2ray Service" >> log/auto_restart.log
	exit
fi
if [ ! $v2muctl_pid ]
then
	./run.sh
	echo "`date`: Auto Restart/Start V2muctl Service" >> log/auto_restart.log
	exit
fi
status=`curl $MU_URI\/nodes\/$MU_NODE_ID\/status -s`
if [ "$status" == "Offline" ]
then
	./run.sh
	echo "`date`: Auto Restart/Start V2ray Service" >> log/auto_restart.log
	exit
fi
./update.sh
exit