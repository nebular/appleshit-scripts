#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0}: This script must be run using sudo or as the root user"
    exit 1
fi

OSX=$(sw_vers -productVersion | cut -f 1-2 -d .)
OSM=$(sw_vers -productVersion | cut -f 2-2 -d .)

if [[ $OSM -lt "15"]]; then
	RLIB="/System/Library"
	RETC="/etc"
else
	RLIB="./System/Library"
	RETC="./etc"
fi

# Check system/library exists

[ -d ${RLIB} ] || {
	echo "Please change to the OS Volume (cd /Volumes/...) and run this script again."
	exit 1
}

# Check database for current version exists

[ -f ${RETC}/appleshit.daemons.${OSX}.cfg ] || {
	echo "Please create ${RETC}/appleshit.daemons.${OSX}.cfg with all daemons to disable, one per line."
	exit 1
}

[ -f ${RETC}/appleshit.agents.${OSX}.cfg ] || {
	echo "Please create ${RETC}/appleshit.agents.${OSX}.cfg with all agents to disable, one per line."
	exit 1
}

# AGENTS

echo "----- APPLE AGENTS"
input="/etc/appleshit.agents.${OSX}.cfg"

while IFS= read -r agent
do
  var=${agent}
  [[ $var =~ ^#.* ]] && continue
  if [[ -f ${RLIB}/LaunchAgents.off/${agent}.plist ]]; then
	  echo "- A ${agent} was disabled, enabling" 
	  mv ${RLIB}/LaunchAgents.off/${agent}.plist ${RLIB}/LaunchAgents/${agent}.plist &> /dev/null
	  # load if mojave or lower
	  [[ $OSM -lt 15 ]] && launchctl load -w ${RLIB}/LaunchAgents/${agent}.plist &> /dev/null
  else
	  echo "! A ${agent} does not exists, or was not disabled"
  fi

done < "$input"

# DAEMONS

input="/etc/appleshit.daemons.${OSX}.cfg"
echo "----- APPLE DAEMONS"
while IFS= read -r daemon
do
  var=${daemon}
  [[ $var =~ ^#.* ]] && continue
  if [[ -f ${RLIB}/LaunchDaemons.off/${daemon}.plist ]]; then 
	  echo "- D ${daemon} was disabled, enabling"
	  mv ${RLIB}/LaunchDaemons.off/${daemon}.plist ${RLIB}/LaunchDaemons/${daemon}.plist &> /dev/null
	  # load if mojave or lower
	  [[ $OSM -lt 15 ]] && launchctl load -w ${RLIB}/LaunchDaemons/${daemon}.plist &> /dev/null
  else
	  echo "! D ${daemon} does not exists, or was not disabled" 
  fi
done < "$input"


