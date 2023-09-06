#!/bin/bash 
add_cron_job() {
# Define the cron job as a string
CRON_JOB="30 2 * * * /home/username/SCPBackup.sh"

  # Check if the cron job already exists
existing_cron=$(crontab -l | grep -F "$CRON_JOB")

if [ -z "$existing_cron" ]; then
# * * * * *  command_to_run  #Reminder of cron syntax
# - - - - -
# | | | | | 
# | | | | +---- Day of the week (0 - 7) [Both 0 and 7 represent Sunday]
# | | | +------ Month (1 - 12)
# | | +-------- Day of the month (1 - 31)
# | +---------- Hour (0 - 23)
# +------------ Minute (0 - 59)

crontab -1 > cronbak.txt #Backup current crontab to file

#Add new cron job to crontab
echo "30 5 * * * /home/username/SCPBackup.sh" >> cronbak.txt #Add new cron job to file everyday at 5:30am

#Install new cron file from backup
crontab cronbak.txt

#Clear backup file
rm cronbak.txt

echo "Cron job added."
  else
    echo "Cron job already exists. No action taken."
  fi
}
