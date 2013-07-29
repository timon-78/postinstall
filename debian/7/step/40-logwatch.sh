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

echo "${BLEU}########## Installation logwatch ##########${RESETCOLOR}"

aptitude -y install logwatch > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation logwatch"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation logwatch"
	exit 1
fi

sed -i 's/logwatch --output mail/logwatch --output mail --mailto '$(/tmp/getinfo.sh EMAIL)' --detail high/g' /etc/cron.daily/00logwatch
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration logwatch - Mail"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration logwatch - Mail"
	exit 1
fi

exit 0