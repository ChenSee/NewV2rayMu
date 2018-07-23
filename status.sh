#!/bin/bash
update_pid=$(ps ux | grep "./update.sh" | grep -v grep | awk '{print $2}')
v2ray_pid=$(ps ux | grep "$(readlink -f v2ray)" | grep -v grep | awk '{print $2}')
v2muctl_pid=$(ps ux | grep "$(readlink -f v2mctl)" | grep -v grep | awk '{print $2}')
if [ $update_pid ]; then
    echo "`date`: Updating" >> log/auto_restart.log
    exit
fi
source ./mu.conf
if [ ! $v2ray_pid -o ! $v2muctl_pid ]
then
	./run.sh
	echo "`date`: Auto Restart/Start V2ray Service" >> log/auto_restart.log
	exit
fi
status=`curl $MU_URI\/nodes\/$NodeId\/status -s`
if [ "$status" == "Offline" ]
then
	./run.sh
	echo "`date`: Auto Restart/Start V2ray Service" >> log/auto_restart.log
	exit
fi
./update.sh
exit