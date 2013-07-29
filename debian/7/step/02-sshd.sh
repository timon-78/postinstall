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

echo "${BLEU}########## Configuration SSH Server ##########${RESETCOLOR}"

sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Interdire connection Root"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Interdire connection Root"
	exit 1
fi

sed -i 's/LoginGraceTime 120/LoginGraceTime 30/' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Passage a 30s pour se connecter au lieu de 120s"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Passage a 30s pour se connecter au lieu de 120s"
	exit 1
fi

echo "# ClientAliveCountMax - Ceci indique le nombre total de messages checkalive envoyé par le serveur ssh, sans obtenir de réponse du client ssh. Par défaut est 3.
# ClientAliveInterval - Ceci indique le délai d'attente en secondes. Après un nombre x de secondes, le serveur ssh va envoyer un message au client demandant la réponse. Deafult est 0 (serveur n'enverra pas de message au client de vérifier.
ClientAliveInterval 600
ClientAliveCountMax 0" >> /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Deconnection automatique au bout de 10mn inactif"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Deconnection automatique au bout de 10mn inactif"
	exit 1
fi

echo "AllowUsers $(/tmp/getinfo.sh ADM)" >> /etc/ssh/sshd_config
fi
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Authoriser seulement l administrateur"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Authoriser seulement l administrateur"
	exit 1
fi

# Regeneration SSHKey
rm /etc/ssh/ssh_host_*
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Suppression clef SSH"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Suppression clef SSH"
	exit 1
fi
dpkg-reconfigure openssh-server > /dev/null;
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Generation clef SSH"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Generation clef SSH"
	exit 1
fi
echo "[ ${VERT}ok${RESETCOLOR} ] Generation clefs SSH"

service ssh restart
exit $?