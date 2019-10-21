#!/bin/bash
OSX=$(sw_vers -productVersion | cut -f 1-2 -d .)
OSM=$(sw_vers -productVersion | cut -f 2-2 -d .)

if [[ $OSM -lt "15" ]]; then
	# Before Catalina, stuff at root level
	RLIB="/System/Library"
	RETC="/etc"
else
	# Catalina onwards, stuff relative to the system volume
	RLIB="./System/Library"
	RETC="./etc"
fi

# Check system/library exists

[ -d ${RLIB} ] || {
	echo "Please change to the OS System Volume (cd /Volumes/...) and run this script again."
	exit 1
}

[ -f ${RETC}/appleshit.daemons.${OSX}.cfg ] || {
echo "Please create ${RETC}/appleshit.daemons.${OSX}.cfg with all daemons to disable, one per line."
	exit 1
}


[ -f ${RETC}/appleshit.agents.${OSX}.cfg ] || {
	echo "Please create ${RETC}/appleshit.agents.${OSX}.cfg with all agents to disable, one per line."
	exit 1
}

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
	[[ $var =~ ^#.* ]] && continue
	if [[ -f ${RLIB}/LaunchAgents/${agent}.plist ]]; then
		echo "- A ${agent} exists, disabling" 
		launchctl unload -w ${RLIB}/LaunchAgents/${agent}.plist &> /dev/null
		mv ${RLIB}/LaunchAgents/${agent}.plist ${RLIB}/LaunchAgents.off/${agent}.plist &> /dev/null
	else 
		if [[ -f ${RLIB}/LaunchAgents.off/${agent}.plist ]]; then 
			echo "! A ${agent} ALREADY DISABLED" 
		else 
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
	[[ $var =~ ^#.* ]] && continue
	if [[ -f ${RLIB}/LaunchDaemons/${daemon}.plist ]]; then
		echo "- D ${daemon} exists, disabling" 
		[[ $OSM -lt 15 ]] && launchctl unload -w ${RLIB}/LaunchDaemons/${daemon}.plist &> /dev/null
		mv ${RLIB}/LaunchDaemons/${daemon}.plist ${RLIB}/LaunchDaemons.off/${daemon}.plist &> /dev/null
	else 
		if [[ -f ${RLIB}/LaunchDaemons.off/${daemon}.plist ]]; then
			echo "! D ${daemon} ALREADY DISABLED" 
		else
			echo "! D ${daemon} DOES NOT EXIST" 
		fi
  	fi
done < "$input"