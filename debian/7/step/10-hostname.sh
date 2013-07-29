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

HOSTNAME=$(/tmp/getinfo.sh HOSTNAME)
NEWHOSTNAME=$(/tmp/getinfo.sh NEWNAME)

echo "${BLEU}########## Configuration Hostname ##########${RESETCOLOR}"

hostname "$NEWHOSTNAME"
echo "$NEWHOSTNAME" > /etc/hostname
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour /etc/hostname"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Mise a jour /etc/hostname"
	exit 1
fi

# Change Hosts
cat /etc/hosts | sed s/"$HOSTNAME"/"$NEWHOSTNAME"/g > /tmp/newhosts
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour /etc/hosts"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Mise a jour /etc/hosts"
	exit 1
fi
mv /tmp/newhosts /etc/hosts

exit $?