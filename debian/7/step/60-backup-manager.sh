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

echo "${BLEU}########## Installation backup-manager ##########${RESETCOLOR}"

aptitude -y install backup-manager bzip2 > /dev/null
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Installation backup-manager"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Installation backup-manager"
	exit 1
fi

# Configuration duree de vie des archives de 5 jours à 90 jours
sed -i 's/export BM_ARCHIVE_TTL="5"/export BM_ARCHIVE_TTL="90"/g' /etc/backup-manager.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration backup-manager - TTL"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration backup-manager - TTL"
	exit 1
fi

# Configuration type de sauvegarde tarball a tarball incremental
sed -i 's/export BM_ARCHIVE_METHOD="tarball"/export BM_ARCHIVE_METHOD="tarball-incremental"/g' /etc/backup-manager.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration backup-manager - Incremental"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration backup-manager - Incremental"
	exit 1
fi

# Configuration type d archive tar a tar.bz2
sed -i 's/export BM_TARBALL_FILETYPE="tar.gz"/export BM_TARBALL_FILETYPE="tar.bz2"/g' /etc/backup-manager.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration backup-manager - BZ2"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration backup-manager - BZ2"
	exit 1
fi

# Configuration dossier a sauvegarder
sed -i 's/export BM_TARBALL_DIRECTORIES="\/etc \/home"/export BM_TARBALL_DIRECTORIES="\/etc \/var\/log"/g' /etc/backup-manager.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration backup-manager - Folder"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration backup-manager - Folder"
	exit 1
fi

# Desactivation SCP
sed -i 's/export BM_UPLOAD_METHOD="scp"/export BM_UPLOAD_METHOD="none"/g' /etc/backup-manager.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration backup-manager - Folder"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration backup-manager - Folder"
	exit 1
fi

# Desactivation BURNING
sed -i 's/export BM_BURNING_METHOD="CDRW"/export BM_BURNING_METHOD="none"/g' /etc/backup-manager.conf
if [ $? -eq 0 ]; then
	echo "[ ${VERT}ok${RESETCOLOR} ] Configuration backup-manager - Folder"
else
	echo "[ ${ROUGE}ko${RESETCOLOR} ] Configuration backup-manager - Folder"
	exit 1
fi

echo "#!/bin/sh
# cron script for backup-manager
/usr/sbin/backup-manager" > /etc/cron.daily/backup-manager
chmod 751 /etc/cron.daily/backup-manager

/etc/init.d/cron reload

/usr/sbin/backup-manager

exit 0