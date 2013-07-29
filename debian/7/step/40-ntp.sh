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

echo "${BLEU}########## Installation ntp ##########${RESETCOLOR}"

aptitude -y install ntp > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation ntp"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation ntp"
	exit 1
fi

exit 0