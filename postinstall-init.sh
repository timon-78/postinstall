#!/bin/bash
# Mon script de post installation serveur Debian 7.x
#
# Timon - 07/2013
# GPL
#
# Syntaxe: # su - -c "./squeezeserverpostinstall.sh"
# Syntaxe: or # sudo ./squeezeserverpostinstall.sh
VERSION="0.0.1"

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
echo "Distribution : ${VERT}$DISTRIB${RESETCOLOR}"

case $DISTRIB in 
	"\"Debian GNU/Linux 7 (wheezy)\"") 
		wget https://raw.github.com/timon-78/postinstall/master/debian/7/postinstall.sh;;
	"\"Debian GNU/Linux 6 (lenny)\"") 
		wget https://raw.github.com/timon-78/postinstall/master/debian/6/postinstall.sh ;;
esac

if [ ! -e "postinstall.sh" ]; then
	echo "postinstall.sh n'existe pas"
	exit 1
elif [ -f "postinstall.sh" ]; then
	chmod +x postinstall.sh
	./postinstall.sh

# Fin du script