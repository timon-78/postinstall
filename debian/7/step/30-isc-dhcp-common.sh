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

echo "${BLEU}########## Desinstallation isc-dhcp-common ##########${RESETCOLOR}"

aptitude -y --purge remove isc-dhcp-common > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Suppression isc-dhcp-common"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Suppression isc-dhcp-common"
	exit 1
fi

exit 0