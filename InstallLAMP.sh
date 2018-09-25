#!/bin/bash
#install LAMP server and configure firewall
apt-get install dialog sshpass openssh-server --yes;
# open fd
exec 3>&1
# Store data to $VALUES variable
VALUES=$(dialog --ok-label "Install" \
	  --backtitle "Install LAMP server" \
	  --title "Install LAMP" \
	  --form "Install LAMP" \
	15 50 0 \
	"ServerIP:" 1 1	"$ServerIP" 	1 10 30 0 \
	"ServerUser:"    2 1	"root"  	2 10 30 0 \
	"ServerPass:"    3 1	"$ServerPass"  	3 10 30 0 \
	2>&1 1>&3)
res=$?
# close fd
exec 3>&-

if [ "$res" = "0" ]
then
	echo "Start Instal Server"
	arr=()
	while read -r line; do
	arr+=("$line")
	done <<< "$VALUES"
	ServerIP="${arr[0]}"
	ServerUser="${arr[1]}"
	ServerPass="${arr[2]}"

#start instalation

echo LAMP_SERVER ansible_ssh_host=$ServerIP ansible_ssh_user=$ServerUser ansible_ssh_pass=$ServerPass remote_tmp=/tmp/.ansible-${USER}/tmp> /tmp/LAMP_Ansible_Conf.con
#install aptitude
ansible all -m apt -a "name=aptitude" -i /tmp/LAMP_Ansible_Conf.con > /tmp/LAMP_Ansible_Log.log
#update repo
ansible all -m apt -a "upgrade=yes update_cache=yes cache_valid_time=86400" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
#install apache
ansible all -m apt -a "name=apache2" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
#install mysql
ansible all -m apt -a "name=mysql-server" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
#install php
ansible all -m apt -a "name=php" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
ansible all -m apt -a "name=libapache2-mod-php" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
ansible all -m apt -a "name=php-mcrypt" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
ansible all -m apt -a "name=php-mysql" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
#install iptables
ansible all -m apt -a "name=iptables" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
#configure iptables
# Accept traffic from loopback interface (localhost)
ansible all -m iptables -a "chain=INPUT in_interface=lo jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
# Accept SSH traffic (for administration)
ansible all -m iptables -a "chain=INPUT protocol=tcp destination_port=ssh jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
# Accept port traffic on ports 22, 25, 80, 443 (SSH, SMTP, Apache http/https)
ansible all -m iptables -a "chain=INPUT protocol=tcp destination_port=22 jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
ansible all -m iptables -a "chain=INPUT protocol=tcp destination_port=25 jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
ansible all -m iptables -a "chain=INPUT protocol=tcp destination_port=80 jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
ansible all -m iptables -a "chain=INPUT protocol=tcp destination_port=443 jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
# Accept icmp ping requests
ansible all -m iptables -a "chain=INPUT protocol=icmp jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log
# Allow established connections:
ansible all -m iptables -a "chain=INPUT ctstate=ESTABLISHED,RELATED jump=ACCEPT" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log

else
#ну що тут скажеш передумав так передумав нічого неробимо юпі)))
               echo "Instalation canceled"
fi
