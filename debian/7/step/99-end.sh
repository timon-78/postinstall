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

echo "${BLEU}########## Nettoyage final ##########${RESETCOLOR}"

aptitude clean /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Nettoyage cache aptitude"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Nettoyage cache aptitude"
	exit 1
fi

echo "${ROUGE}END, reboot needed${RESETCOLOR}"

exit 0