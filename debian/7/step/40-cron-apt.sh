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

echo "${BLEU}########## Installation cron-apt ##########${RESETCOLOR}"

aptitude -y install cron-apt > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation cron-apt"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation cron-apt"
	exit 1
fi

sed -i 's/# MAILTO="root"/MAILTO="'$(/tmp/getinfo.sh EMAIL)'"/g' /etc/cron-apt/config
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration cron-apt - Mail"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration cron-apt - Mail"
	exit 1
fi

exit 0