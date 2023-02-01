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
node_id=$4
ssr_node_id=$3


echo '-------------------------------'
echo '|  Configuring V2ray And SSR  |'
echo '-------------------------------'
if [ ! $node_id ];
then 
	echo 'Please enter your Node ID:'
	read node_id
fi
if [ ! $mu_uri ];
then 
	echo 'Please enter your Mu-api URI(eg:http://www.xxxx.com/mu/v2):'
	read mu_uri
fi
if [ ! $mu_key ];
then 
	echo 'Please enter your Mu-api KEY:'
	read mu_key
fi
echo '-------------------------------'
echo '|        Your Configure       |'
echo '-------------------------------'
echo 'Your Node ID:'
echo $node_id
echo 'Your Mu-api URI:'
echo $mu_uri
echo 'Your Mu-api KEY:'
echo $mu_key
echo 'Is it OK?(y/n)'
isok=n
read isok
if [ $isok != 'y' -a $isok != 'Y' ];
then 
	echo 'Quit Install'
	exit
fi

if [ $ssr_node_id ];
then
	echo '-------------------------------'
	echo '|        Installing SSR...    |'
	echo '-------------------------------'

	clear
	git clone https://github.com/ChenSee/shadowsocks-1.git "/usr/local/shadowsocks"
	cd /usr/local/shadowsocks
	curl -O https://bootstrap.pypa.io/get-pip.py
	python get-pip.py 
	pip install -r requirements.txt
	sed -i "s#https://zhaoj.in#${mu_uri}#" /usr/local/shadowsocks/userapiconfig.py
	sed -i "s#glzjinmod#modwebapi#" /usr/local/shadowsocks/userapiconfig.py
	sed -i "s#glzjin#${mu_key}#" /usr/local/shadowsocks/userapiconfig.py
	sed -i '2d' /usr/local/shadowsocks/userapiconfig.py
	sed -i "2a\NODE_ID = ${ssr_node_id}" /usr/local/shadowsocks/userapiconfig.py
	bash run.sh

	echo "* * * * * (if [ \"$(ps -eaf |grep server.py | grep -v grep | awk '{print $2}')\" == \"\" ]; then cd /usr/local/shadowsocks && bash run.sh; fi)">> /var/spool/cron/root
	echo "cd /usr/local/shadowsocks && bash run.sh" >> /etc/rc.d/rc.local
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
	echo 'Getting Latest Version...'
	v2Version=$(curl -s 'https://api.github.com/repos/v2fly/v2ray-core/releases/latest' -H 'Accept: application/vnd.github.v3+json' | grep 'tag_name' | cut -d\" -f4)
	if [ ! $v2Version ];
	then
		v2Version="v5.2.1"
	fi
	
	ctlVersion=`wget -q -O - https://api.github.com/repos/ChenSee/easy-v2ray-mu/releases/latest | grep '"tag_name":'| awk '{printf $2}'`
	ctlVersion=${ctlVersion%\"*}
	ctlVersion=${ctlVersion#\"*}
	shellsVersion=`wget -q -O - https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/version.txt | grep 'ver:'| awk '{printf $2}'`
	echo -e "\033[33m Shells Version:\033[32m $shellsVersion\033[0m"
	echo -e "\033[33m V2ray Version :\033[32m $v2Version\033[0m"
	echo -e "\033[33m Muctl Version :\033[32m $ctlVersion\033[0m"
	sleep 1
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	wget -O v2ray-linux-64.zip https://github.com/v2fly/v2ray-core/releases/download/$v2Version/v2ray-linux-64.zip
	unzip v2ray-linux-64.zip
	rm -rf v2ray-linux-64.zip
	mv v2ray-$v2Version-linux-64 v2ray-mu
	cd v2ray-mu
	mkdir log
	touch log/error.log
	touch log/access.log
	touch log/v2ray-mu.log
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/cfg.json
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/v2mctl
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/mu.conf
	sed -i "s;##mu_uri##;${mu_uri}/mu/v2;g" mu.conf
	sed -i "s;##mu_key##;$mu_key;g" mu.conf
	sed -i "s;##node_id##;$node_id;g" mu.conf
	sed -i "s;##ShVersion##;$shellsVersion;g" mu.conf
	sed -i "s;##V2Version##;$v2Version;g" mu.conf
	sed -i "s;##CtlVersion##;$ctlVersion;g" mu.conf
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/run.sh
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/stop.sh
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/cleanLogs.sh
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/catLogs.sh
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/status.sh
	wget https://raw.githubusercontent.com/ChenSee/easy-v2ray-mu/dev/update.sh
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

