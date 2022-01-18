#!/bin/bash

#plex variables
plex_backup_dir="/volume1/Server2/Backups/Plex"
PMS_IP='192.168.1.200'
plex_installed_volume="volume1"
log_file_location="/volume1/web/logging/notifications/plex_backup.txt"
lock_file_location="/volume1/web/logging/notifications/plex_backup.lock"

#create a lock file in the ramdisk directory to prevent more than one instance of this script from executing  at once
if ! mkdir $lock_file_location; then
	echo "Failed to acquire lock.\n" >&2
	exit 1
fi
trap 'rm -rf $lock_file_location' EXIT #remove the lockdir on exit



#setup log file
echo "Beginning backup of 
PLEX Data" |& tee $log_file_location

#determine DSM version to ensure the DSM6 vs DSM7 version of the synology PLEX package is downloaded
DSMVersion=$(                   cat /etc.defaults/VERSION | grep -i 'productversion=' | cut -d"\"" -f 2)

echo "" |& tee -a $log_file_location
MinDSMVersion=7.0
/usr/bin/dpkg --compare-versions "$MinDSMVersion" gt "$DSMVersion"
if [ "$?" -eq "0" ]; then
	echo "DSM version is 6.x.x"
	echo "Current DSM Version Installed: $DSMVersion"
	plex_library_directory_location="/$plex_installed_volume/Plex"
	folder_name_to_backup="Library"
	plex_package_name="Plex Media Server"
	plex_Preferences_loction="Plex/Library/Application Support/Plex Media Server/Preferences.xml"
else
	echo "DSM version is 7.x.x"
	echo "Current DSM Version Installed: $DSMVersion"
	plex_library_directory_location="/$plex_installed_volume/PlexMediaServer"
	folder_name_to_backup="AppData"
	plex_package_name="PlexMediaServer"
	plex_Preferences_loction="PlexMediaServer/AppData/Plex Media Server/Preferences.xml"
fi
		
#####################################
#get current date
#####################################

DATE=$(date +%m-%d-%Y);

#####################################
#Shutdown Plex before backing up plex data directory
#####################################

now=$(date +"%T")
echo "" |& tee -a $log_file_location
echo "$now - BACKING UP PLEX" |& tee -a $log_file_location

#####################################
#first terminate any active sessions
#####################################
		

MSG='PLEX_Backup_Process_In_Progress'
CLIENT_IDENT='123456'
token=$(cat "/$plex_installed_volume/$plex_Preferences_loction" | grep -oP 'PlexOnlineToken="\K[^"]+')
#Start by getting the active sessions

sessionURL="http://$PMS_IP:32400/status/sessions?X-Plex-Client-Identifier=$CLIENT_IDENT&X-Plex-Token=$token"
response=$(curl -i -k -L -s $sessionURL)
sessions=$(printf %s "$response"| grep '^<Session*'| awk -F= '$1=="id"{print $2}' RS=' '| cut -d '"' -f 2)

# Active sessions id's now stored in sessions variable, so convert to an array
set -f                      # avoid globbing (expansion of *).
array=(${sessions//:/ })
for i in "${!array[@]}"
do
	echo "PLEX Active - Need to kill session: ${array[i]}" |& tee -a $log_file_location
	killURL="http://$PMS_IP:32400/status/sessions/terminate?sessionId=${array[i]}&reason=$MSG&X-Plex-Client-Identifier=$CLIENT_IDENT&X-Plex-Token=$token"
	# Kill it
	response=$(curl -i -k -L -s $killURL)
	# Get response
	http_status=$(echo "$response" | grep HTTP |  awk '{print $2}')
	#echo $killURL |& tee -a $log_file_location
	if [ $http_status -eq "200" ]
	then
		echo "Success with killing of stream ${array[i]}" |& tee -a $log_file_location
	else
		echo "Something went wrong here" |& tee -a $log_file_location
		exit
	fi
done
sleep 1
#####################################
#Stop plex package
#####################################
plex_status=$(/usr/syno/bin/synopkg is_onoff "$plex_package_name")
if [ -f "$plex_backup_dir/Library_$DATE.tar" ]; then
	echo "Backup File $plex_backup_dir/Library_$DATE.tar already exists, PLEX shutdown aborting" |& tee -a $log_file_location
else
	if [ "$plex_status" = "package $plex_package_name is turned on" ]; then
		echo |& tee -a $log_file_location
		echo "Stopping PLEX Media Server...." |& tee -a $log_file_location
		/usr/syno/bin/synopkg stop "$plex_package_name" |& tee -a $log_file_location
		sleep 1
	else
		echo "PLEX Media Server Already Shutdown" |& tee -a $log_file_location
	fi
fi


#####################################
#Backup plex data directory
#####################################
plex_status=$(/usr/syno/bin/synopkg is_onoff "$plex_package_name")

if [ "$plex_status" = "package $plex_package_name is turned on" ]; then
	echo "PLEX Media Server Shutdown Failed, Skipping PLEX Data Backup Process" |& tee -a $log_file_location
else
	echo "PLEX Media Server Shutdown Successfully" |& tee -a $log_file_location
	if [ -f "$plex_backup_dir/Library_$DATE.tar" ]; then
		echo "Backup File $plex_backup_dir/Library_$DATE.tar already exists, Skipping PLEX Data Backup Process" |& tee -a $log_file_location
	else
		cd $plex_library_directory_location
		current_dir=$(pwd)
		if [ "$current_dir" = "$plex_library_directory_location" ]; then
			now=$(date +"%T")
			echo "$now - Backing up PLEX \"$folder_name_to_backup\" Directory.... This may take a while" |& tee -a $log_file_location
			tar cf Library_$DATE.tar "$folder_name_to_backup"  |& tee -a $log_file_location
			if [ -f "$plex_library_directory_location/Library_$DATE.tar" ]; then
				now=$(date +"%T")
				echo "$now - Backup of PLEX Data Directory Complete. Moving Library_$DATE.tar to $plex_backup_dir" |& tee -a $log_file_location
				mv Library_$DATE.tar $plex_backup_dir/Library_$DATE.tar |& tee -a $log_file_location
				if [ -f "$plex_backup_dir/Library_$DATE.tar" ]; then
					now=$(date +"%T")
					echo "$now - Moving Library_$DATE.tar Complete" |& tee -a $log_file_location
				else
					echo "Moving Library_$DATE.tar Failed, file does not exist in the destination directory" |& tee -a $log_file_location
				fi
			else
				echo "backup file Library_$DATE.tar does not exist, something went wrong" |& tee -a $log_file_location
			fi
		else
			echo "Could not change directory to $plex_library_directory_location, Skipping PLEX Data Backup Process" |& tee -a $log_file_location
		fi
	fi
fi

sleep 1
			
			
#####################################
#start PLEX Media Server Package 
#####################################
plex_status=$(/usr/syno/bin/synopkg is_onoff "$plex_package_name")
if [ "$plex_status" = "package $plex_package_name is turned on" ]; then
	echo "PLEX already active, skipping PLEX restart" |& tee -a $log_file_location
else
	echo |& tee -a $log_file_location
	echo "Starting PLEX Media Server...." |& tee -a $log_file_location
	/usr/syno/bin/synopkg start "$plex_package_name" |& tee -a $log_file_location
	sleep 1
fi

#####################################
#Cleanup activities
#####################################
#delete older un-needed backups. this will keep the last two backup files and delete all others 

echo "" |& tee -a $log_file_location			
cd $plex_backup_dir
current_dir=$(pwd)
if [ "$current_dir" = "$plex_backup_dir" ]; then
	echo ""
	echo "Cleaning up PLEX backup directory $plex_backup_dir" |& tee -a $log_file_location
	ls -1t | tail -n +3 | xargs rm -f
else
	echo "Could not change directory to $plex_backup_dir, canceling cleaning of PLEX backup directory $plex_backup_dir" |& tee -a $log_file_location
fi

now=$(date +"%T")
echo "" |& tee -a $log_file_location
echo "" |& tee -a $log_file_location
echo "$now - Backup Process Complete" |& tee -a $log_file_location

exit


#cleanup command explanation
#ls : List directory contents.
#-1t : 1(Number one) indicates that the output of ls should be one file per line. t indicates sort contents by modification time, newest first.
#tail : Output the last part of files.
#-n +x : output the last x NUM lines, instead of the last 10; or use -n +NUM to output starting with line NUM
#xargs : Build and execute command lines from standard input.
#rm -f : Remove files or directories. f indicates ignore nonexistent files and arguments, never prompt. It means that this command won't display any error messages if there are less than 10 files.
#| - It is a pipeline. It is generally a sequence of one or more commands separated by one of the control operators | or |&.
#So, the above command will delete the oldest files if there are more than 10 files in the current working directory. To verify how many files are in the directory after deleting the oldest file(s), just run:
