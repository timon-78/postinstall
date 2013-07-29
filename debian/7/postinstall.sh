#!/bin/bash
# Mon script de post installation serveur Debian 7.x
#
# Timon - 07/2013
# GPL
#
# Syntaxe: # su - -c "./squeezeserverpostinstall.sh"
# Syntaxe: or # sudo ./squeezeserverpostinstall.sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin
VERSION="0.0.1"

#=============================================================================

#========================= Variables de mise en forme ========================
#+ Mode normal
RESETCOLOR="$(tput sgr0)"

 
# Couleurs (gras)
#+ Rouge
ROUGE="$(tput setaf 1)"
#+ Vert
VERT="$(tput setaf 2)"
#+ Bleu
BLEU="$(tput setaf 4)"
#=============================================================================


# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # su - -c $0" 1>&2
  exit 1
fi

#################################### STEP 0

if [ ! -e /tmp/config.txt ];
then
	NEWCONFIG="1"
	HOSTNAME=$(hostname)
	echo "HOSTNAME=$HOSTNAME" > /tmp/config.txt
	IP=$( ifconfig eth0 | grep "inet adr" | cut -d: -f2 | cut -d' ' -f1)
	echo "IP=$IP" >> /tmp/config.txt
	GW=$(/sbin/ip route | awk '/default/ { print $3 }')
	echo "GW=$GW" >> /tmp/config.txt
	NETMASK=$(ifconfig eth0 | grep Masque | cut -d':' -f4 | cut -d' ' -f1)
	echo "NETMASK=$NETMASK" >> /tmp/config.txt
	BROADCAST=$(ifconfig eth0 | grep Bcast | cut -d':' -f3 | cut -d' ' -f1)
	echo "BROADCAST=$BROADCAST" >> /tmp/config.txt
	NETWORK=$(/sbin/ip route | grep eth0 | grep link | cut -d'/' -f1)
	echo "NETWORK=$NETWORK" >> /tmp/config.txt
	ADM=$(cat /etc/passwd | grep 1000 | cut -d: -f1)
	echo "ADM=$ADM" >> /tmp/config.txt
	for line in $(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2); do NS="${NS}${line} "; done
	echo "NS=$NS" >> /tmp/config.txt
else	
	NEWCONFIG="0"

	HOSTNAME=$(hostname)
	echo "HOSTNAME=$HOSTNAME" > /tmp/config.txt

	NEWNAME=$(/tmp/getinfo.sh NEWNAME)
	if [ ${#NEWNAME} -eq 0 ]; 
	then
		echo -n "NEWNAME : "
		read NEWNAME
		echo "NEWNAME=$NEWNAME" >> /tmp/config.txt		
	fi

	IP=$(/tmp/getinfo.sh IP)
	if [ ${#IP} -eq 0 ]; 
	then
		echo -n "IP : "
		read IP
		echo "IP=$IP" >> /tmp/config.txt		
	fi

	GW=$(/tmp/getinfo.sh GW)
	if [ ${#GW} -eq 0 ]; 
	then
		echo -n "GW : "
		read GW
		echo "GW=$GW" >> /tmp/config.txt		
	fi

	NETMASK=$(/tmp/getinfo.sh NETMASK)
	if [ ${#NETMASK} -eq 0 ]; 
	then
		echo -n "NETMASK : "
		read NETMASK
		echo "NETMASK=$NETMASK" >> /tmp/config.txt		
	fi

	BROADCAST=$(/tmp/getinfo.sh BROADCAST)
	if [ ${#BROADCAST} -eq 0 ]; 
	then
		echo -n "BROADCAST : "
		read BROADCAST
		echo "BROADCAST=$BROADCAST" >> /tmp/config.txt		
	fi

	NETWORK=$(/tmp/getinfo.sh NETWORK)
	if [ ${#NETWORK} -eq 0 ]; 
	then
		echo -n "NETWORK : "
		read NETWORK
		echo "NETWORK=$NETWORK" >> /tmp/config.txt		
	fi

	ADM=$(/tmp/getinfo.sh ADM)
	if [ ${#ADM} -eq 0 ]; 
	then
		echo -n "ADM : "
		read ADM
		echo "ADM=$ADM" >> /tmp/config.txt		
	fi

	NS=$(/tmp/getinfo.sh NS)
	if [ ${#NS} -eq 0 ]; 
	then
		echo -n "NS : "
		read NS
		echo "NS=$NS" >> /tmp/config.txt		
	fi

	EMAIL=$(/tmp/getinfo.sh EMAIL)
	if [ ${#EMAIL} -eq 0 ]; 
	then
		echo -n "EMAIL : "
		read EMAIL
		echo "EMAIL=$EMAIL" >> /tmp/config.txt		
	fi
fi



#========================= Information systeme ===============================

echo "${SURLIGNE}${UNDERLIGNE}${BLEU}##### Informations systeme #####${RESETCOLOR}"
echo "                        Hostname : $(/tmp/getinfo.sh HOSTNAME)"
echo "                         Newname : $(/tmp/getinfo.sh NEWNAME)"
echo "                              Ip : $(/tmp/getinfo.sh IP)"
echo "                          Masque : $(/tmp/getinfo.sh NETMASK)"
echo "                          Reseau : $(/tmp/getinfo.sh NETWORK)"
echo "                       Broadcast : $(/tmp/getinfo.sh BROADCAST)"
echo "                      Passerelle : $(/tmp/getinfo.sh GW)"
echo "                             Dns : $(/tmp/getinfo.sh NS)"
echo "                  Administrateur : $(/tmp/getinfo.sh ADM)"
echo "                           Email : $(/tmp/getinfo.sh MAIL)"
#=============================================================================

if [ "$NEWCONFIG" = "0" ];
then
	echo -n "${SURLIGNE}${ROUGE}/!\ ${RESETCOLOR} Etes-vous sur [y/N] ?${SURLIGNE}${ROUGE}/!\ ${RESETCOLOR} ? "
	read ISOK
else
	echo -n "NEWNAME : "
	read NEWNAME
	sed -i 's/NEWNAME/#NEWNAME/' /tmp/config.txt
	echo "NEWNAME=$NEWNAME" >> /tmp/config.txt		

	echo -n "IP : "
	read IP
	sed -i 's/IP/#IP/' /tmp/config.txt
	echo "IP=$IP" >> /tmp/config.txt		

	echo -n "EMAIL : "
	read EMAIL
	sed -i 's/EMAIL/#EMAIL/' /tmp/config.txt
	echo "EMAIL=$EMAIL" >> /tmp/config.txt		
	
	echo -n "${SURLIGNE}${ROUGE}/!\ ${RESETCOLOR} Etes-vous sur [y/N] ?${SURLIGNE}${ROUGE}/!\ ${RESETCOLOR} ? "
	read ISOK
fi

#=============================================================================
if [ "$ISOK" = "y" ];then
	for line in $(ls /tmp/step/*.sh);
	do
		$line
	done;
else
	exit 0
fi
# Fin du script