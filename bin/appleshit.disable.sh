#!/bin/bash
OSX=$(sw_vers -productVersion | cut -f 1-2 -d .)
OSM=$(sw_vers -productVersion | cut -f 2-2 -d .)

if [[ $OSM -lt "15" ]]; then
	# Before Catalina, ie. Sierra, Mojave, stuff at root level
	RLIB="/System/Library"
	RETC="/etc"
else
	# Catalina onwards, stuff relative to the system volume, script must be executed from the volume root
	RLIB="./System/Library"
	RETC="./etc"
fi

# Check System/Library exists

[ -d ${RLIB} ] || {
	# Must be catalina, and executed outside the OS Volume
	echo "Please change to the OS System Volume (cd /Volumes/...) and run this script again."
	exit 1
}

# Check filelist for the current OS version exists in /etc

[ -f ${RETC}/appleshit.daemons.${OSX}.cfg ] || {
	echo "Please create ${RETC}/appleshit.daemons.${OSX}.cfg with all daemons to disable, one per line."
	exit 1
}


[ -f ${RETC}/appleshit.agents.${OSX}.cfg ] || {
	echo "Please create ${RETC}/appleshit.agents.${OSX}.cfg with all agents to disable, one per line."
	exit 1
}

# Check superuser

if [[ $EUID -ne 0 ]]; then
    echo "${0}: This script must be run using sudo or as the root user"
    exit 1
fi

# Create backup dirs if not already created
[[ -d ${RLIB}/LaunchDaemons.off ]] || mkdir ${RLIB}/LaunchDaemons.off
[[ -d ${RLIB}/LaunchAgents.off ]] || mkdir ${RLIB}/LaunchAgents.off

# Disable AGENTS

echo "----- APPLE AGENTS"
input="/etc/appleshit.agents.${OSX}.cfg"

while IFS= read -r agent
do
	var=${agent}

	# Ignore entries starting with #
	[[ $var =~ ^#.* ]] && continue

	if [[ -f ${RLIB}/LaunchAgents/${agent}.plist ]]; then
		echo "- A ${agent} exists, disabling" 
		# On Catalina do not stop it, as this is executed from the recovery console
		[[ $OSM -lt 15 ]] && launchctl unload -w ${RLIB}/LaunchAgents/${agent}.plist &> /dev/null
		# Move the agent to the backup directory
		mv ${RLIB}/LaunchAgents/${agent}.plist ${RLIB}/LaunchAgents.off/${agent}.plist &> /dev/null
	else 
		if [[ -f ${RLIB}/LaunchAgents.off/${agent}.plist ]]; then 
			# The agent is already on the backup directory
			echo "! A ${agent} ALREADY DISABLED" 
		else 
			# The agent specified in the file list was not found
			echo "! A ${agent} DOES NOT EXIST" 
		fi
	fi

done < "$input"

# Disable DAEMONS

input="/etc/appleshit.daemons.${OSX}.cfg"
echo "----- APPLE DAEMONS"
while IFS= read -r daemon
do

	var=${daemon}
	# Ignore entries starting with #
	[[ $var =~ ^#.* ]] && continue

	if [[ -f ${RLIB}/LaunchDaemons/${daemon}.plist ]]; then
		echo "- D ${daemon} exists, disabling" 
		# On Catalina do not stop it, as this is executed from the recovery console
		[[ $OSM -lt 15 ]] && launchctl unload -w ${RLIB}/LaunchDaemons/${daemon}.plist &> /dev/null
		# Move the daemon to the backup directory
		mv ${RLIB}/LaunchDaemons/${daemon}.plist ${RLIB}/LaunchDaemons.off/${daemon}.plist &> /dev/null
	else 
		if [[ -f ${RLIB}/LaunchDaemons.off/${daemon}.plist ]]; then
			# The daemon is already on the backup directory
			echo "! D ${daemon} ALREADY DISABLED" 
		else
			# The daemon specified in the file list was not found
			echo "! D ${daemon} DOES NOT EXIST" 
		fi
  	fi

done < "$input"
