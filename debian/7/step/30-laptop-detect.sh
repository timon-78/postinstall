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

echo "${BLEU}########## Desinstallation laptop-detect ##########${RESETCOLOR}"

aptitude -y --purge remove laptop-detect > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Suppression laptop-detect"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Suppression laptop-detect"
	exit 1
fi

exit 0