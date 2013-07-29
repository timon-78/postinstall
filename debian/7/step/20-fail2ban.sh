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

echo "${BLEU}########## Installation fail2ban ##########${RESETCOLOR}"

aptitude -y install fail2ban > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation fail2ban"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation fail2ban"
	exit 1
fi

sed -i 's/destemail = root@localhost/destemail = '$(/tmp/getinfo.sh EMAIL)'/g' /etc/fail2ban/jail.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration fail2ban - Mail"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration fail2ban - Mail"
	exit 1
fi

exit 0