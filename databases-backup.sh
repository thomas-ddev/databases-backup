#!/bin/bash

# Paramètres pour l'envoi des alertes mail
EMAIL=""
EMAILPASSWORD=""
MAILSERVER=""
MAILSUBJECT="[ALERTE] Un fichier de sauvegarde vide a été détecté !"
MAILMESSAGE="Une vérification de l'état du serveur s'impose : un fichier de sauvegarde corrompu/invalide (0 bytes) a été détecté. La sauvegarde de ce jour a été abandonnée par sécurité."

# Paramètres MySQL
MYSQLUSER=""
MYSQLPASSWORD=""

# Recuperer la date du jour
TIMESTAMP=$(date +%F)

# Repertoire contenant la backup temporaire
TMPBACKUP="/var/www/backups/databases"

# Si le repertoire temporaire des backup existe pas, le creer
if [ ! -d "$TMPBACKUP" ]; then
        mkdir -p $TMPBACKUP
fi

# Vérifier si d'anciennes backups corrompues sont présentes
if test $(find "$TMPBACKUP" -type f -size 0 | wc -c) -ne 0
     then
          swaks -t $EMAIL -s $MAILSERVER -tls -au $EMAIL --ap $EMAILPASSWORD -f $EMAIL --h-Subject $MAILSUBJECT --body $MAILMESSAGE
     exit
fi

# Supprimer les BDD de plus de 5j
find $TMPBACKUP -mtime +5 -exec rm {} \;

# Creer une backup de toutes les BDD en local
for DB in $(mysql -u $MYSQLUSER -p$MYSQLPASSWORD -e 'show databases' -s --skip-column-names); do
    mysqldump --skip-lock-tables -f -u $MYSQLUSER -p$MYSQLPASSWORD $DB > "$TMPBACKUP$DB-$TIMESTAMP.sql";
done

