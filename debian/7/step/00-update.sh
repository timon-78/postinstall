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

echo "${BLEU}########## Mise a jour ##########${RESETCOLOR}"

# Update 
aptitude update > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour des depots"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Mise a jour des depots"
	exit 1
fi

# Upgrade
aptitude -y upgrade > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour du systeme"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Mise a jour du systeme"
	exit 1
fi

exit 0