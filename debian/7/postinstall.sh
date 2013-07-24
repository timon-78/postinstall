#!/bin/bash
# Mon script de post installation serveur Debian 7.x
#
# Timon - 07/2013
# GPL
#
# Syntaxe: # su - -c "./squeezeserverpostinstall.sh"
# Syntaxe: or # sudo ./squeezeserverpostinstall.sh
VERSION="0.0.1"

#========================= Parametrage =======================================
# Liste des applications à installer: A adapter a vos besoins
LISTE="git iptables-persistent cron-apt fail2ban logwatch lsb-release vim snmpd"
# Liste des applications à supprimer: A adapter a vos besoins
RLISTE="snmpd"
# sortie du programmes (par defaut /dev/null)
OUTPUT="toto.log"
#=============================================================================

#========================= Variables de mise en forme ========================
#+ Mode normal
RESETCOLOR="$(tput sgr0)"
# "Surligné" (bold)
SURLIGNE=$(tput smso)
# "Non-Surligné" (offbold)
NONSURLIGNE=$(tput rmso)
 
# Couleurs (gras)
#+ Rouge
ROUGE="$(tput bold ; tput setaf 1)"
#+ Vert
VERT="$(tput bold ; tput setaf 2)"
#+ Jaune
JAUNE="$(tput bold ; tput setaf 3)"
#+ Bleu
BLEU="$(tput bold ; tput setaf 4)"
#+ Cyan
CYAN="$(tput bold ; tput setaf 6)"
#=============================================================================


# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

#========================= Information systeme ===============================
DISTRIB=$(cat /etc/*-release | grep PRETTY_NAME | cut -d= -f2)
HOSTNAME=$(hostname)
IP=$( ifconfig eth0 | grep "inet adr" | cut -d: -f2 | cut -d' ' -f1)
ADM=$(cat /etc/passwd | grep 1000 | cut -d: -f1)

echo "${BLEU}##### Informations systeme #####${RESETCOLOR}"
echo "                    Distribution : ${VERT}$DISTRIB${RESETCOLOR}"
echo "                        Hostname : ${VERT}$HOSTNAME${RESETCOLOR}"
echo "                              Ip : ${VERT}$IP${RESETCOLOR}"
#=============================================================================

#========================= Parametrage initial ===============================

echo "${BLEU}##### Parametres #####${RESETCOLOR}"
echo -n "     Administrateur ${JAUNE}[$ADM]${RESETCOLOR} : "
read NEWADM
echo -n "           Hostname ${JAUNE}[$HOSTNAME]${RESETCOLOR} : "
read NEWHOSTNAME
echo -n "                 Ip ${JAUNE}[$IP]${RESETCOLOR} : "
read NEWIP
echo -n "         Programmes ${JAUNE}[$LISTE]${RESETCOLOR} : "
read NEWLISTE
echo -n "${ROUGE}/!\ ${RESETCOLOR} Etes-vous sur ${ROUGE}/!\ ${RESETCOLOR} ? "
read ISOK
#=============================================================================

echo "${BLEU}##### Configuration de base #####${RESETCOLOR}"

# Change Hostname
if [ ${#NEWHOSTNAME} -eq 0 ]; 
then
	echo " - Mise a jour hostname : ${VERT}[NO]${RESETCOLOR}"
else	
	hostname "$NEWHOSTNAME"
	echo "$NEWHOSTNAME" > /etc/hostname

	# Change Hosts
	cat /etc/hosts | sed s/"$HOSTNAME"/"$NEWHOSTNAME"/g > /tmp/newhosts
	mv /tmp/newhosts /etc/hosts
	echo " - Mise a jour hostname : ${VERT}[OK]${RESETCOLOR}"
fi        

# Regeneration SSHKey
/bin/rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
echo " - Generation clefs SSH : ${VERT}[OK]${RESETCOLOR}"
# Update 
apt-get update >> $OUTPUT
echo " - Mise a jour des depots : ${VERT}[OK]${RESETCOLOR}"

# Upgrade
apt-get -y upgrade >> $OUTPUT
echo " - Mise a jour du systeme : ${VERT}[OK]${RESETCOLOR}"

# Configuration systeme
# hostname
echo " - Mise a jour ip : ${VERT}[OK]${RESETCOLOR}"

echo "${BLEU}##### Mise a jour des logiciels par defaut #####${RESETCOLOR}"
for i in $LISTE; 
do 
apt-get -y install $i >> $OUTPUT;
echo " - Installation de $i : ${VERT}[OK]${RESETCOLOR}";
done

for i in $RLISTE; 
do 
apt-get -y --purge remove $i >> $OUTPUT;
echo " - Desinstallation de $i : ${VERT}[OK]${RESETCOLOR}";
done

apt-get clean >> $OUTPUT
echo " - Nettoyage cache APT : ${VERT}[OK]${RESETCOLOR}";


echo "${BLEU}##### Securisation #####${RESETCOLOR}"
# fw
echo " - Configuration IPTABLES : ${VERT}[OK]${RESETCOLOR}";
# sshd
echo " - Configuration SSHD : ${VERT}[OK]${RESETCOLOR}";
# sudo
echo " - Configuration SUDO: ${VERT}[OK]${RESETCOLOR}";
# sysctl
echo " - Configuration SYSCTL : ${VERT}[OK]${RESETCOLOR}";


echo "${BLEU}##### Configuration applications #####${RESETCOLOR}"
# bashrc
echo " - Configuration bash : ${VERT}[OK]${RESETCOLOR}";
# Configuration
#--------------

#echo -n "Adresse mail pour les rapports de securite: "
#read MAIL 
# cron-apt
#sed -i 's/# MAILTO="root"/MAILTO="'$MAIL'"/g' /etc/cron-apt/config
# fail2ban
#sed -i 's/destemail = root@localhost/destemail = '$MAIL'/g' /etc/fail2ban/jail.conf
# logwatch
#sed -i 's/logwatch --output mail/logwatch --output mail --mailto '$MAIL' --detail high/g' /etc/cron.daily/00logwatch


# Fin du script