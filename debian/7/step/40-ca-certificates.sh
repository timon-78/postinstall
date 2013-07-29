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

echo "${BLEU}########## Installation ca-certificates ##########${RESETCOLOR}"

aptitude -y install ca-certificates > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation ca-certificates"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation ca-certificates"
	exit 1
fi

exit 0