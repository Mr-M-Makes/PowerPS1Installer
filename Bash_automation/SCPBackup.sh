#!/bin/bash   #Required in every script to tell the system what interpreter to use

#Local folder to backup
SOURCE="/home/username/backup"

#SSh details
SSH_USER="username"
SSH_HOST="serverip"

#Remote backup location
DEST="/home/username/backup"

#perform Backup using scp
scp -r $SOURCE $SSH_USER@$SSH_HOST:$DEST

#Check if scp was successful
if [ $? -eq 0 ]; then
    echo "Backup Successful"
else
    echo "Backup Failed"
fi
