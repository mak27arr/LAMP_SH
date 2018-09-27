#!/bin/bash
#jast for
#install LAMP server and configure firewall
#apt-get install dialog openssh-server --yes;

#install package
DIALOG=$(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo -e "${YELLOW}Installing dialog${NC}"
    apt-get install dialog --yes;
    elif [ $(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}dialog is installed!${NC}"
  fi

OPENSSHSERVER=$(dpkg-query -W -f='${Status}' openssh-server 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' openssh-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo -e "${YELLOW}Installing openssh-server${NC}"
    apt-get install openssh-server --yes;
    elif [ $(dpkg-query -W -f='${Status}' openssh-server 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}openssh-server is installed!${NC}"
  fi

OPENSSHCLIENT=$(dpkg-query -W -f='${Status}' openssh-client 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' openssh-client 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    echo -e "${YELLOW}Installing openssh-client${NC}"
    apt-get install openssh-client --yes;
    elif [ $(dpkg-query -W -f='${Status}' openssh-client 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}openssh-client is installed!${NC}"
  fi

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
	arr=()
	while read -r line; do
	arr+=("$line")
	done <<< "$VALUES"
	ServerIP="${arr[0]}"
	ServerUser="${arr[1]}"
	ServerPass="${arr[2]}"

#start instalation
#List of comand to excecute
declare -A ComandList
ComandList[0]="echo LAMP_SERVER ansible_ssh_host=$ServerIP ansible_ssh_user=$ServerUser ansible_ssh_pass=$ServerPass remote_tmp=/tmp/.ansible-${USER}/tmp> /tmp/LAMP_Ansible_Conf.con"
ComandMsg[0]="Create config file"
ComandList[1]="ansible all -m apt -a \"name=aptitude\" -i /tmp/LAMP_Ansible_Conf.con > /tmp/LAMP_Ansible_Log.log"
ComandMsg[1]="Install aptitude"
ComandLine[2]="ansible all -m apt -a \"upgrade=yes update_cache=yes cache_valid_time=86400\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[2]="Update and upgrade server" 
ComandLine[3]="ansible all -m apt -a \"name=apache2\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log" 
ComandMsg[3]="Install Apache" 
ComandLine[4]="ansible all -m apt -a \"name=mysql-server\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log" 
ComandMsg[4]="Install mysql-server" 
ComandLine[5]="ansible all -m apt -a \"name=php\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log" 
ComandMsg[5]="Install php" 
ComandLine[6]="ansible all -m apt -a \"name=libapache2-mod-php\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log" 
ComandMsg[6]="Install libapache2-mod-php" 
ComandLine[7]="ansible all -m apt -a \"name=php-mcrypt\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log" 
ComandMsg[7]="Install php-mcrypt" 
ComandLine[8]="ansible all -m apt -a \"name=php-mysql\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log" 
ComandMsg[8]="Install php-mysql" 
ComandLine[9]="ansible all -m apt -a \"name=iptables\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[9]="Install iptables"
ComandLine[10]="ansible all -m iptables -a \"chain=INPUT in_interface=lo jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[10]="Configure iptables"
ComandLine[11]="ansible all -m iptables -a \"chain=INPUT protocol=tcp destination_port=ssh jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[11]="Configure iptables"
ComandLine[12]="ansible all -m iptables -a \"chain=INPUT protocol=tcp destination_port=22 jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[12]="Configure iptables"
ComandLine[13]="ansible all -m iptables -a \"chain=INPUT protocol=tcp destination_port=25 jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[13]="Configure iptables"
ComandLine[14]="ansible all -m iptables -a \"chain=INPUT protocol=tcp destination_port=80 jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[14]="Configure iptables"
ComandLine[15]="ansible all -m iptables -a \"chain=INPUT protocol=tcp destination_port=443 jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[15]="Configure iptables"
ComandLine[16]="ansible all -m iptables -a \"chain=INPUT protocol=icmp jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[16]="Configure iptables"
ComandLine[17]="ansible all -m iptables -a \"chain=INPUT ctstate=ESTABLISHED,RELATED jump=ACCEPT\" -i /tmp/LAMP_Ansible_Conf.con >>  /tmp/LAMP_Ansible_Log.log"
ComandMsg[17]="Configure iptables"
#
# Show a progress bar
# ---------------------------------
# Redirect dialog commands input using substitution
#
ComCount=${#ComandLine[@]}

dialog --title "Install LAMP" --gauge "Install LAMP..." 10 75 < <( 
   # set counter
   i=0

while [ $i -lt $ComCount ]
do
# update dialog box 
Com=$(( 100/ComCount*i ))
Mes=${ComandMsg[$i]}
cat <<EOF
XXX
$Com
$Mes
XXX
EOF
bash -c "${ComandLine[$i]}"
i=$[$i+1]
done

cat <<EOF
XXX
100
"Finish"
XXX
EOF

)

echo $Com
else
#ну що тут скажеш передумав так передумав нічого неробимо юпі)))
               echo "Instalation canceled"
fi
