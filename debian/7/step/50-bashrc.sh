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

echo "${BLEU}########## Configuration Systeme ##########${RESETCOLOR}"

ADM=$(/tmp/getinfo.sh ADM)

sed -i 's/#alias/alias/' /home/${ADM}/.bashrc
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration BashRC - Alias"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration BashRC - Alias"
	exit 1
fi

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /home/${ADM}/.bashrc
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration BashRC - Color"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration BashRC - Color"
	exit 1
fi

cp /home/${ADM}/.bashrc /root/.bashrc
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration BashRC - Root"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration BashRC - Root"
	exit 1
fi


exit 0