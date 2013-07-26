#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin

aptitude install -y openssh-server > /dev/null

sed -e 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config > /tmp/sshd_config.1

sed -e 's/LoginGraceTime 120/LoginGraceTime 30/' /tmp/sshd_config.1 > /tmp/sshd_config.2

echo "# ClientAliveCountMax - Ceci indique le nombre total de messages checkalive envoyé par le serveur ssh, sans obtenir de réponse du client ssh. Par défaut est 3.
# ClientAliveInterval - Ceci indique le délai d'attente en secondes. Après un nombre x de secondes, le serveur ssh va envoyer un message au client demandant la réponse. Deafult est 0 (serveur n'enverra pas de message au client de vérifier.
ClientAliveInterval 600
ClientAliveCountMax 0" >> /tmp/sshd_config.2

if [ ${#1} -eq 0 ]; 
then
	echo "no user specified, continue"
else
	echo "AllowUsers $1" >> /tmp/sshd_config.2
fi
mv /tmp/sshd_config.2 /etc/ssh/sshd_config
rm /tmp/sshd*
service ssh restart > /dev/null