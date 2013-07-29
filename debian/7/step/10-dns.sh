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

echo "${BLEU}########## Configuration DNS ##########${RESETCOLOR}"

echo > /etc/resolv.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Suppression configuration DHCP"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Suppression configuration DHCP"
	exit 1
fi

for line in $(/tmp/getinfo.sh NS); 
do 
	echo "nameserver $line" >> /etc/resolv.conf; 
	if [ $? -eq 0 ]; then
		echo "[ ${VERT}ok${RESETCOLOR} ] Ajout NS - $line"
	else
		echo "[ ${ROUGE}ko${RESETCOLOR} ] Ajout NS - $line"
		exit 1
	fi
done

exit 0