<div id="top"></div>
<!--
*** comments....
-->



<!-- PROJECT LOGO -->
<br />

<h3 align="center">Synology Native/DOCKER PLEX Installation Automatic Backup</h3>

  <p align="center">
    This project is comprised of a shell script that stops any active PLEX streams, shutdown PLEX, makes a .tar backup file, and restarts PLEX
    <br />
    <a href="https://github.com/wallacebrf/plex_backup"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/wallacebrf/plex_backup/issues">Report Bug</a>
    ·
    <a href="https://github.com/wallacebrf/plex_backup/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#About_the_project_Details">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Road map</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
### About_the_project_Details

The script is written around the Synology NAS DSM operating system Native installation of PLEX or a DOCKER installation on PLEX

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites
		
1. This script can be run through Synology Task Scheduler. 

### Installation

1. Create the following directories on the NAS

```
1. /volume1/[shared_foler_name]/logging
2. /volume1/[shared_foler_name]/logging/notifications
```
Ensure ```[shared_foler_name]``` is properly set a folder of your choice

2. Place the ```plex_backup.sh``` file in the ```/logging``` directory

### Configuration "plex_backup.sh"

1. Open the ```plex_backup.sh``` file in a text editor. 
2. the script contains the following configuration variables 
```
#plex variables
plex_backup_dir="/volume1/Server2/Backups/Plex"
PMS_IP='192.168.1.200'
plex_installed_volume="volume1"
log_file_location="/volume1/[shared_foler_name]/logging/notifications/plex_backup.txt"
lock_file_location="/volume1/[shared_foler_name]/logging/notifications/plex_backup.lock"
installation_type=0 #0 for native plex app, 1 for DOCKER


#if using docker edit these parameters, otherwise they can be ignored. 
docker_container_name="plex" #edit to match the name of your PLEX docker container 
plex_library_directory_location="/$plex_installed_volume/Plex"
folder_name_to_backup="AppData"
plex_Preferences_loction="PlexMediaServer/AppData/Plex Media Server/Preferences.xml"
```

```plex_backup_dir``` is where the .tar backup file will be stored

```PMS_IP``` mujst be the IP address used to access PLEX so the script can terminate any active streams

```plex_installed_volume``` which volume on the Synology NAS is the PLEX data directory located 

```log_file_location``` where the log file of the backup process will be saved. Ensure ```[shared_foler_name]``` is properly set a folder of your choice

```lock_file_location``` where a lock file will be saved while the script is running. Ensure ```[shared_foler_name]``` is properly set a folder of your choice. this prevents more than once instance of this script from running at once

```installation_type``` indicates if this is a PLEX installation using the native plex installer and package manager or if using docker.



```docker_container_name``` if using docker, what is the name of the PLEX container within docker

```plex_library_directory_location``` if using docker, where is the PLEX data folder located?

```folder_name_to_backup``` what folder within the PLEX data structure to backup

```plex_Preferences_loction``` where is the PLEX preference file? this is needed to terminate any active streams 


### Configuration of Task Scheduler 

1. Control Panel -> Task Scheduler
2. Click ```Create -> Scheduled Task -> User-defined script```
3. Under "General Settings" name the script "PLEX Auto-backup" and choose the "root" user and ensure the task is enabled
4. Click the "Schedule" tab at the top of the window. in this example we will set it to run monthly and will run at 11:00 PM
5. Select "Run on the following date" and choose the day of the current or next month you wish for the script to run. also ensure "Repeat Monthly" is selected 
6. Under Time, set "First run time" to "23" and "00"
7. under "Frequency" select "every day"
8. under last run time select "23:00"
9. go to the "Task Settings" tab
10. Ensure "Send run details by email" is checked and enter the email address to send the logs to. 
11. Under "Run command" enter ```bash /volume1/[shared_foler_name]/logging/plex_backup.sh``` NOTE: ensure the ```/volume1/[shared_foler_name]/logging/``` is where the script is located
12. click "ok" in the bottom right
13. IF desired, find the newly created task in your list, right click and select "run". when a confirmation window pops up, choose "yes". The script will run. WARNING this will shutdown any active streams and turn off PLEX while the backup process is happening.  


<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

This is free to use code, use as you wish

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Your Name - Brian Wallace - wallacebrf@hotmail.com

Project Link: [https://github.com/wallacebrf/plex_backup)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments


<p align="right">(<a href="#top">back to top</a>)</p>
