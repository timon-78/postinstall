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

echo "${BLEU}########## Configuration IP ##########${RESETCOLOR}"
sed -e 's/^allow-hotplug eth0/#allow-hotplug eth0/g' -e 's/^iface eth0 inet dhcp/#iface eth0 inet dhcp/g' -i /etc/network/interfaces
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Suppression config DHCP"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Suppression config DHCP"
	exit 1
fi

echo "auto eth0
iface eth0 inet static
address $(/tmp/getinfo.sh IP)
netmask $(/tmp/getinfo.sh NETMASK)
network $(/tmp/getinfo.sh NETWORK)
broadcast $(/tmp/getinfo.sh BROADCAST)
gateway $(/tmp/getinfo.sh GW)
" >> /etc/network/interfaces
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration Eth0 static"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration Eth0 static"
	exit 1
fi

exit 0