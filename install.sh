#!/bin/bash
#a strange script to install v2ray-mu

yum install unzip -y
yum install crontabs -y
chkconfig --level 35 crond on
service crond start
yum install git -y
clear
mu_uri=$1
mu_key=$2
domain=$3
node_id=$4

echo '-------------------------------'
echo '|        Your Configure       |'
echo '-------------------------------'
echo 'Your Node ID:'
echo $node_id
echo 'Your Mu-api URI:'
echo $mu_uri
echo 'Your Mu-api KEY:'
echo $mu_key
echo 'Your Domain:'
echo $domain
echo 'Is it OK?(y/n)'
isok=n
read isok
if [ $isok != 'y' -a $isok != 'Y' ];
then 
	echo 'Quit Install'
	exit
fi


if [ $node_id ];
then
	echo '-------------------------------'
	echo '|        Installing V2RAY...  |'
	echo '-------------------------------'


	clear
	mkdir /usr/local/v2ray
	cd /usr/local/v2ray
	echo -e "\033[33m ____            _  __     __\n|  _ \ _ __ ___ (_) \ \   / /\n| |_) | '__/ _ \| |  \ \ / / \n|  __/| | | (_) | |   \ V /  \n|_|   |_|  \___// |    \_/ \033[5mInstaling...\033[0m\033[33m  \n              |__/          for Mu_api\n\033[0m"
	
	. <(curl -s -L https://git.io/v2ray.sh)
	v2ray del tcp
	v2ray add ws $domain
	v2ray stop

	mkdir log
	touch log/v2ray-mu.log
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/v2mctl
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/mu.conf
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/run.sh
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/stop.sh
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/cleanLogs.sh
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/catLogs.sh
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/status.sh
	wget https://raw.githubusercontent.com/ChenSee/NewV2rayMu/dev/update.sh
	sed -i "s;##mu_uri##;${mu_uri}/mu/v2;g" mu.conf
	sed -i "s;##mu_key##;$mu_key;g" mu.conf
	sed -i "s;##node_id##;$node_id;g" mu.conf
	sed -i "s;##domain##;$domain;g" mu.conf
	
	chmod +x *
	thisPath=$(readlink -f .)
	isCronRunsh=`grep "&& ./run.sh" /var/spool/cron/root|awk '{printf $7}'`
	isCronStatsh=`grep "&& ./status.sh" /var/spool/cron/root|awk '{printf $7}'`
	if [ "$isCronRunsh" != "$thisPath" ]; then
	    echo "30 4 * * * cd $(readlink -f .) && ./run.sh">> /var/spool/cron/root
	fi
	if [ "$isCronRunsh" != "$thisPath" ]; then
	    echo "* * * * * cd $(readlink -f .) && ./status.sh">> /var/spool/cron/root
	fi
	bash run.sh
	echo "cd /usr/local/v2ray && bash run.sh" >> /etc/rc.d/rc.local
fi

chmod +x /etc/rc.d/rc.local

service crond restart
echo '--------------------------------'
echo -e '|       \033[33mInstall finshed\033[0m        |'
echo '--------------------------------'
# echo -e '|\033[32mplease run this command to run\033[0m|'
# echo -e '-----------\033[33m V  V  V \033[0m------------'
# echo -e "\033[32mcd $(readlink -f .) && ./run.sh\033[0m"

