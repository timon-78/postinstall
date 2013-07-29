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

echo "${BLEU}########## Installation sudo ##########${RESETCOLOR}"

aptitude -y install sudo > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation sudo"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation sudo"
	exit 1
fi

useradd $(/tmp/getinfo.sh ADM) sudo
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration sudo - $(/tmp/getinfo.sh ADM)"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration sudo - $(/tmp/getinfo.sh ADM)"
	exit 1
fi

passwd -l root > /dev/null;
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Desactivation root"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Desactivation root"
	exit 1
fi

exit 0