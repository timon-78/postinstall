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
LISTE="iptables-persistent cron-apt fail2ban logwatch lsb-release nano snmpd"
# Liste des applications à supprimer: A adapter a vos besoins
RLISTE="isc-dhcp-client isc-dhcp-common"
# sortie du programmes (par defaut /dev/null)
OUTPUT="postinstall.log"
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

#################################### STEP 0

#========================= Information systeme ===============================
DISTRIB=$(cat /etc/*-release | grep PRETTY_NAME | cut -d= -f2)
HOSTNAME=$(hostname)
IP=$( ifconfig eth0 | grep "inet adr" | cut -d: -f2 | cut -d' ' -f1)
GW=$(/sbin/ip route | awk '/default/ { print $3 }')
NETMASK=$(ifconfig eth0 | grep Masque | cut -d':' -f4 | cut -d' ' -f1)
BROADCAST=$(ifconfig eth0 | grep Bcast | cut -d':' -f3 | cut -d' ' -f1)
NETWORK=$(/sbin/ip route | grep eth0 | grep link | cut -d'/' -f1)
ADM=$(cat /etc/passwd | grep 1000 | cut -d: -f1)
for line in $(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2); do NS="${NS}${line} "; done

echo "${BLEU}##### Informations systeme #####${RESETCOLOR}"
echo "                    Distribution : ${VERT}$DISTRIB${RESETCOLOR}"
echo "                        Hostname : ${VERT}$HOSTNAME${RESETCOLOR}"
echo "                              Ip : ${VERT}$IP${RESETCOLOR}"
echo "                          Masque : ${VERT}$NETMASK${RESETCOLOR}"
echo "                          Reseau : ${VERT}$NETWORK${RESETCOLOR}"
echo "                       Broadcast : ${VERT}$BROADCAST${RESETCOLOR}"
echo "                      Passerelle : ${VERT}$GW${RESETCOLOR}"
echo "                             Dns : ${VERT}$NS${RESETCOLOR}"
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
dpkg-reconfigure openssh-server >> $OUTPUT;
echo " - Generation clefs SSH : ${VERT}[OK]${RESETCOLOR}"

if [ ${#NEWIP} -eq 0 ]; 
then
	echo " - Mise a jour Reseaux : ${VERT}[NO]${RESETCOLOR}"
else
	sed -e 's/^allow-hotplug eth0/#allow-hotplug eth0/g' -e 's/^iface eth0 inet dhcp/#iface eth0 inet dhcp/g' -i /etc/network/interfaces
	sh -c "echo 'auto eth0' >> /etc/network/interfaces"
	sh -c "echo 'iface eth0 inet static' >> /etc/network/interfaces"
	sh -c "echo 'address $NEWIP' >> /etc/network/interfaces"
	sh -c "echo 'netmask $NETMASK' >> /etc/network/interfaces"
	sh -c "echo 'gateway $GATEWAY' >> /etc/network/interfaces"
	echo " - Mise a jour Reseaux : ${VERT}[OK]${RESETCOLOR}"
fi

#echo "nameserver $DNSSRVONE
#nameserver $DNSSRVTWO" > /etc/resolv.conf
#echo " - Mise a jour DNS : ${VERT}[OK]${RESETCOLOR}"

####################### TODO STOP AND REBOOT WITH STATE MEMORY

#################################### STEP 1
####TODO Update module vmware
ISVM=$(lspci | grep "Virtual Machine Communication")
if [ ${#ISVM} -eq 0 ]; 
then
	echo " - Kernel Standart : ${VERT}[OK]${RESETCOLOR}"
else	
	modprobe -r floppy
	echo " - Kernel VMWare : ${VERT}[OK]${RESETCOLOR}"
fi
exit 0;

#################################### STEP 2

# Update 
apt-get update >> $OUTPUT
echo " - Mise a jour des depots : ${VERT}[OK]${RESETCOLOR}"

# Upgrade
apt-get -y upgrade >> $OUTPUT
echo " - Mise a jour du systeme : ${VERT}[OK]${RESETCOLOR}"

#################################### STEP 3
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

#################################### STEP 4

echo "${BLEU}##### Securisation #####${RESETCOLOR}"
# fw
echo " - Configuration IPTABLES : ${VERT}[OK]${RESETCOLOR}";
# sshd
echo " - Configuration SSHD : ${VERT}[OK]${RESETCOLOR}";
# sudo
echo " - Configuration SUDO: ${VERT}[OK]${RESETCOLOR}";
# sysctl
echo " - Configuration SYSCTL : ${VERT}[OK]${RESETCOLOR}";


#################################### STEP 5
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