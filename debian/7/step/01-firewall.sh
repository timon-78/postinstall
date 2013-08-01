#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin

#+ Mode normal
RESETCOLOR="$(tput sgr0)"
#+ Rouge
ROUGE="$(tput setaf 1)"
#+ Vert
VERT="$(tput setaf 2)"
#+ Bleu
BLEU="$(tput setaf 4)"

echo "${BLEU}########## Configuration du Firewall ##########${RESETCOLOR}"

aptitude -y install iptables-persistent > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation iptables-persistent"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation iptables-persistent"
	exit 1
fi


if ! [ -x /etc/firewall ]; then
	mkdir /etc/firewall
fi
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation dossier /etc/firewall"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Creation dossier /etc/firewall"
	exit 1
fi

echo "# Logging	
	iptables -A INPUT -m limit --limit 5/m --limit-burst 7  -j LOG --log-prefix \"IPTables : \" 
	iptables -A OUTPUT -m limit --limit 5/m --limit-burst 7  -j LOG --log-prefix \"IPTables : \" 
	iptables -A FORWARD -m limit --limit 5/m --limit-burst 7  -j LOG --log-prefix \"IPTables : \" " > /etc/firewall/log
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation fichier /etc/firewall/log"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Creation fichier /etc/firewall/log"
	exit 1
fi


echo "	# Ne pas casser les connexions etablies
	iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

	# Autoriser loopback
	iptables -t filter -A INPUT -i lo -j ACCEPT
	iptables -t filter -A OUTPUT -o lo -j ACCEPT

	# ICMP (Ping)
	iptables -t filter -A INPUT -p icmp -j ACCEPT
	iptables -t filter -A OUTPUT -p icmp -j ACCEPT

	# ---

	# SSH In
	iptables -t filter -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
	# SSH Out
	iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT

	# DNS In/Out
	iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
	iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT

	# NTP Out
	iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT

	# HTTP + HTTPS Out
	iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
	iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT" > /etc/firewall/rules
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation fichier /etc/firewall/rules"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Creation fichier /etc/firewall/rules"
	exit 1
fi

echo "# Other network protections
	# (some will only work with some kernel versions)
	echo 1 > /proc/sys/net/ipv4/tcp_syncookies
	echo 0 > /proc/sys/net/ipv4/ip_forward
	echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
	echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
	echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
	echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
	echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
	echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route" > /etc/firewall/sysctl
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation fichier /etc/firewall/sysctl"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Creation fichier /etc/firewall/sysctl"
	exit 1
fi

echo "#!/bin/sh
#
# Simple Firewall configuration.
#
# Author: Timon
#
# description: Activates/Deactivates the firewall at boot time
#
### BEGIN INIT INFO
# Provides:          firewall.sh
# Required-Start:    $syslog $network
# Required-Stop:     $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start firewall daemon at boot time
# Description:       Custom Firewall scrip.
### END INIT INFO
 
PATH=/bin:/sbin:/usr/bin:/usr/sbin

if ! [ -x /sbin/iptables ]; then
 exit 0
fi
 
#+ Mode normal
RESETCOLOR=\"\$(tput sgr0)\"
#+ Vert
VERT=\"\$(tput setaf 2)\"
#+ Rouge
ROUGE=\"\$(tput setaf 1)\"

##########################
# Start the Firewall rules
##########################
 
fw_start () {
	# ---

	/etc/firewall/rules

	# ---

	/etc/firewall/log

	# ---

	/etc/firewall/sysctl
}

 
##########################
# Stop the Firewall rules
##########################
 
fw_stop () {
	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X

	# Interdire toute connexion entrante et sortante
	iptables -t filter -P INPUT DROP
	iptables -t filter -P FORWARD DROP
	iptables -t filter -P OUTPUT DROP

	ip6tables -F
	ip6tables -X
	ip6tables -Z
	ip6tables -P INPUT DROP
	ip6tables -P OUTPUT DROP
	ip6tables -P FORWARD DROP
}


##########################
# Clear the Firewall rules
##########################
 
fw_clear () {
	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X

	# Interdire toute connexion entrante et sortante
	iptables -t filter -P INPUT ACCEPT
	iptables -t filter -P FORWARD ACCEPT
	iptables -t filter -P OUTPUT ACCEPT

	ip6tables -F
	ip6tables -X
	ip6tables -Z
	ip6tables -P INPUT ACCEPT
	ip6tables -P OUTPUT ACCEPT
	ip6tables -P FORWARD ACCEPT
}

##########################
# Test the Firewall rules
##########################
 
fw_save () {
	/sbin/iptables-save > /etc/firewall/backup.fw
}
 
fw_restore () {
	if [ -e /etc/firewall/backup.fw ]; then
	 	/sbin/iptables-restore < /etc/firewall/backup.fw
	fi
}
 
fw_test () {
	if [ \${#1} -eq 0 ]; 
	then
		echo \"[ \${ROUGE}ko\${RESETCOLOR} ] Config file not specified\"
		exit 1
	else		

		if ! [ -x \$1 ]; then
		 echo \"[ \${ROUGE}ko\${RESETCOLOR} ] Config file not found\"
		 echo \"file not found\"
		 exit 1
		fi

		fw_save
		fw_stop
		\$1
		/etc/firewall/log
		echo \"[ \${VERT}ok\${RESETCOLOR} ] Test rules applied\"
		sleep 30 && fw_restore
		fw_stop
		fw_start
		echo \"[ \${VERT}ok\${RESETCOLOR} ] Original rules restored\"
	fi
}
 
case \"\$1\" in
start|restart)
 fw_stop
 echo \"[ \${VERT}ok\${RESETCOLOR} ] Firewall stopped\"
 fw_start 
 echo \"[ \${VERT}ok\${RESETCOLOR} ] Firewall started\"
 ;;
stop)
 fw_stop
 echo \"[ \${VERT}ok\${RESETCOLOR} ] Firewall stopped\"
 ;;
clear)
 fw_clear
 echo \"[ \${VERT}ok\${RESETCOLOR} ] Firewall cleared\"
 ;;
test)
 fw_test $2
 ;;
*)
 echo \"Usage: $0 {start|stop|restart|clear|test}\"
 echo \"Be aware that stop drop all incoming/outgoing traffic !!!\"
 exit 1
 ;;
esac
exit 0
" > /etc/init.d/firewall
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation fichier /etc/init.d/firewall"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Creation fichier /etc/init.d/firewall"
	exit 1
fi

echo ":msg, contains, \"IPTables : \" -/var/log/firewall.log 
& ~" > /etc/rsyslog.d/firewall.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration RSyslog"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration RSyslog"
	exit 1
fi

echo "/var/log/firewall.log
{
	rotate 7
	daily
	missingok
	notifempty
	delaycompress
	compress
	postrotate
		invoke-rc.d rsyslog reload > /dev/null
	endscript
}" > /etc/logrotate.d/firewall 
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration Logrotate"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration Logrotate"
	exit 1
fi

chmod 700 /etc/init.d/firewall
chmod -R 600 /etc/firewall/
chmod 700 /etc/firewall/log
chmod 700 /etc/firewall/rules
chmod 700 /etc/firewall/sysctl

service rsyslog restart
service firewall restart

update-rc.d firewall defaults
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation init.d"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation init.d"
	exit 1
fi

exit 0
