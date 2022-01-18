# plex_backup

This scrip automatically backups PLEX on a synology (DSM6 and DSM7). 

the script first terminates any active streams with a message "PLEX_Backup_Process_In_Progress" to any active users that a backup is happening. 
Note, if a different message is desrired, ensure it has no spaces or it will not work. 

the script then shuts down plex (it a good idea to always shut down an app when backing up data base files to prevent the database being written to in the middle of a copy)

makes a .tar file of the directory

moves the .tar to a final archiving directory of your choosing

restarts plex

send an email with logs of the entire process

the primary user controllable variables are:

#plex variables
plex_backup_dir="/volume1/Server2/Backups/Plex"
PMS_IP='192.168.1.200'
plex_installed_volume="volume1"
log_file_location="/volume1/web/logging/notifications/plex_docker_backup.txt"

"plex_backup_dir" is where the .tar backup file will be copied to for starage
"PMS_IP" is the IP address of used to access PLEX
"plex_installed_volume" what volume on the synology NAS is plex installed on
"log_file_location" where on the system would you like the log file stored

to install, copy the file to a desired location on the system and use Task Scheduler under the control panel to set the script to run when desired. ensure the script runs as root. 
