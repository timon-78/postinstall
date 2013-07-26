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
LISTE="ca-certificates cron-apt fail2ban logwatch lsb-release nano snmpd htop iftop ntp"
# Liste des applications à supprimer: A adapter a vos besoins
RLISTE="isc-dhcp-common tasksel tasksel-data dmidecode laptop-detect nfs-common ispell"
# sortie du programmes (par defaut /dev/null)
OUTPUT="postinstall.log"
#=============================================================================

#========================= Variables de mise en forme ========================
#+ Mode normal
RESETCOLOR="$(tput sgr0)"
# "Surligné" (bold)
SURLIGNE=$(tput bold)
# "Non-Surligné" (offbold)
NONSURLIGNE=$(tput rmso)
# "Sous-ligné"
$UNDERLIGNE=$(tput sgr 0 1)    

 
# Couleurs (gras)
#+ Rouge
ROUGE="$(tput setaf 1)"
#+ Vert
VERT="$(tput setaf 2)"
#+ Jaune
JAUNE="$(tput setaf 3)"
#+ Bleu
BLEU="$(tput setaf 4)"
#+ Cyan
VIOLET="$(tput setaf 5)"
#+ Cyan
CYAN="$(tput setaf 6)"
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

echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Informations systeme #####${RESETCOLOR}"
echo "                    Distribution : ${SURLIGNE}$DISTRIB${RESETCOLOR}"
echo "                        Hostname : ${SURLIGNE}$HOSTNAME${RESETCOLOR}"
echo "                              Ip : ${SURLIGNE}$IP${RESETCOLOR}"
echo "                          Masque : ${SURLIGNE}$NETMASK${RESETCOLOR}"
echo "                          Reseau : ${SURLIGNE}$NETWORK${RESETCOLOR}"
echo "                       Broadcast : ${SURLIGNE}$BROADCAST${RESETCOLOR}"
echo "                      Passerelle : ${SURLIGNE}$GW${RESETCOLOR}"
echo "                             Dns : ${SURLIGNE}$NS${RESETCOLOR}"
echo "                  Administrateur : ${SURLIGNE}$ADM${RESETCOLOR}"
#=============================================================================

#========================= Parametrage initial ===============================
echo ""
echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Parametres #####${RESETCOLOR}"
echo -n "Hostname ${SURLIGNE}${JAUNE}[$HOSTNAME]${RESETCOLOR} : "
read NEWHOSTNAME
echo -n "Ip ${SURLIGNE}${JAUNE}[$IP]${RESETCOLOR} : "
read NEWIP
echo -n "Mail ${SURLIGNE}${JAUNE}[root]]${RESETCOLOR} : "
read MAIL
echo -n "${SURLIGNE}${ROUGE}/!\ ${RESETCOLOR} Etes-vous sur [y/N] ?${SURLIGNE}${ROUGE}/!\ ${RESETCOLOR} ? "
read ISOK
#=============================================================================
if [ "$ISOK" = "y" ];then
	echo ""
	echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Configuration de base #####${RESETCOLOR}"

	# Change Hostname
	if [ ${#NEWHOSTNAME} -eq 0 ]; 
	then
		echo "[ ${JAUNE}nc${RESETCOLOR} ] Mise a jour hostname"
	else	
		hostname "$NEWHOSTNAME"
		echo "$NEWHOSTNAME" > /etc/hostname

		# Change Hosts
		cat /etc/hosts | sed s/"$HOSTNAME"/"$NEWHOSTNAME"/g > /tmp/newhosts
		mv /tmp/newhosts /etc/hosts
		echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour hostname"
	fi        

	# Regeneration SSHKey
	/bin/rm /etc/ssh/ssh_host_*
	dpkg-reconfigure openssh-server >> $OUTPUT;
	echo "[ ${VERT}ok${RESETCOLOR} ] Generation clefs SSH"

	if [ ${#NEWIP} -eq 0 ]; 
	then
		sed -e 's/^allow-hotplug eth0/#allow-hotplug eth0/g' -e 's/^iface eth0 inet dhcp/#iface eth0 inet dhcp/g' -i /etc/network/interfaces
		sh -c "echo 'auto eth0' >> /etc/network/interfaces"
		sh -c "echo 'iface eth0 inet static' >> /etc/network/interfaces"
		sh -c "echo 'address $IP' >> /etc/network/interfaces"
		sh -c "echo 'netmask $NETMASK' >> /etc/network/interfaces"
		sh -c "echo 'gateway $GW' >> /etc/network/interfaces"
		echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour Reseaux "
	else
		sed -e 's/^allow-hotplug eth0/#allow-hotplug eth0/g' -e 's/^iface eth0 inet dhcp/#iface eth0 inet dhcp/g' -i /etc/network/interfaces
		sh -c "echo 'auto eth0' >> /etc/network/interfaces"
		sh -c "echo 'iface eth0 inet static' >> /etc/network/interfaces"
		sh -c "echo 'address $NEWIP' >> /etc/network/interfaces"
		sh -c "echo 'netmask $NETMASK' >> /etc/network/interfaces"
		sh -c "echo 'gateway $GW' >> /etc/network/interfaces"
		echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour Reseaux "
	fi

	echo > /etc/resolv.conf
	for line in $NS; 
	do 
		echo "nameserver $line" >> /etc/resolv.conf; 
	done
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour DNS"

#=>	############################################ FIREWALL #######################################################
	/tmp/00-firewall.sh
#=> ############################################ FIREWALL #######################################################
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation Firewall"

#=> ############################################ SSHD ###########################################################
	/tmp/01-sshd.sh $ADM
#=> ############################################ SSHD ###########################################################	
	echo "[ ${VERT}ok${RESETCOLOR} ] Creation Firewall"

	#################################### STEP 1
	####TODO Update module vmware
	ISVM=$(lspci | grep "Virtual Machine Communication")
	if [ ${#ISVM} -eq 0 ]; 
	then
		echo "[ ${JAUNE}nc${RESETCOLOR} ] Kernel Standart"
	else	
		modprobe -r floppy
		echo "[ ${VERT}ok${RESETCOLOR} ] Kernel VMWare"
	fi

	#################################### STEP 2

	# Update 
	aptitude update >> $OUTPUT
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour des depots"

	# Upgrade
	aptitude -y upgrade >> $OUTPUT
	echo "[ ${VERT}ok${RESETCOLOR} ] Mise a jour du systeme"

	#################################### STEP 3
	echo ""
	echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Mise a jour des logiciels par defaut #####${RESETCOLOR}"
	for i in $LISTE; 
	do 
	aptitude -y install $i >> $OUTPUT;
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation de $i";
	done

	for i in $RLISTE; 
	do 
	aptitude -y --purge remove $i >> $OUTPUT;
	echo "[ ${VERT}ok${RESETCOLOR} ] Desinstallation de $i";
	done

	aptitude clean >> $OUTPUT
	echo "[ ${VERT}ok${RESETCOLOR} ] Nettoyage cache APT";

	#################################### STEP 4
	echo ""
	echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Securisation #####${RESETCOLOR}"
	# sudo
	aptitude install -y sudo >> $OUTPUT;
	adduser $ADM sudo >> $OUTPUT;
	passwd -l root >> $OUTPUT;
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration SUDO";


	#################################### STEP 5
	echo ""
	echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Configuration applications #####${RESETCOLOR}"
	# bashrc
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration BASH";
	# Configuration
	#--------------

	# cron-apt
	sed -i 's/# MAILTO="root"/MAILTO="'$MAIL'"/g' /etc/cron-apt/config
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration CRON-APT";

	# fail2ban
	sed -i 's/destemail = root@localhost/destemail = '$MAIL'/g' /etc/fail2ban/jail.conf
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration FAIL2BAN";
	# logwatch
	sed -i 's/logwatch --output mail/logwatch --output mail --mailto '$MAIL' --detail high/g' /etc/cron.daily/00logwatch
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration LOGWATCH";

	echo ""
	echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Configuration sauvegarde #####${RESETCOLOR}"

	echo ""
	echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Finalisation #####${RESETCOLOR}"
	
	aptitude clean >> $OUTPUT
	echo "[ ${VERT}ok${RESETCOLOR} ] Nettoyage Apt cache";
	rm /tmp/*.sh
	echo "[ ${VERT}ok${RESETCOLOR} ] Suppression script";
	echo ""
	echo "${SURLIGNE}${ROUGE}END, reboot needed${RESETCOLOR}"
else
	exit 0
fi
# Fin du script