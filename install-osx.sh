if [[ $EUID -ne 0 ]]; then
    echo "${0}: This script must be run using sudo or as the root user"
    exit 1
fi

if [[ -f /usr/bin/sw_vers ]]; then 
	
	OSX=$(sw_vers -productVersion | cut -f 1-2 -d .)
	echo "- OSX Version ${OSX}"
	echo "- copying scripts into /usr/local/bin"
	cp -v bin/*.sh /usr/local/bin
	echo "- copying service databases to /etc"
	cp -v etc/*.cfg /etc
	echo "-----------------------------------"
	echo "You can run the scripts above to enable or disable the agents and daemons."
	echo "Changes are permanent until you re-enable or re-disable them"
	echo "-----------------------------------"
	echo "You can also edit the cfg files above to add or remove services."
	echo "You can create additional cfg files for other major versions of OSX,"
	echo "just change the 10.14 part of the filename to your major version."
	echo "The config files matching your version will be automatically"
	echo "selected when running the scripts"
	echo "-----------------------------------"
	echo "PLEASE REMEMBER THAT MANY APPS FROM APPLE IN YOUR MAC THAT DEPEND ON CLOUDSERVICES"
	echo "LIKE IMESSAGES, FACETIME, APPSTORE, SYNC SERVICES ... WILL NOT WORK WHEN DISABLING"
	echo "THE SERVICES !!! YOU MUST ENABLE THEM AGAIN AND POSSIBLY REBOOT TO BE ABLE TO USE THEM!"
	echo "-----------------------------------"
else
	echo "${0}: This script is not compatible with your system"
fi