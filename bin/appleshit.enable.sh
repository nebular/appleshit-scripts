#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "${0}: This script must be run using sudo or as the root user"
    exit 1
fi

OSX=$(sw_vers -productVersion | cut -f 1-2 -d .)

[ -f /etc/appleshit.daemons.$OSX.cfg ] || {
echo "Please create /etc/appleshit.daemons.${OSX}.cfg with all daemons to disable, one per line."
	exit 1
}


[ -f /etc/appleshit.agents.${OSX}.cfg ] || {
	echo "Please create /etc/appleshit.agents.${OSX}.cfg with all agents to disable, one per line."
	exit 1
}


# AGENTS

echo "----- APPLE AGENTS"
input="/etc/appleshit.agents.${OSX}.cfg"

while IFS= read -r agent
do
  var=${agent}
  [[ $var =~ ^#.* ]] && continue
  [ -f /System/Library/LaunchAgents.off/${agent}.plist ] && {
 	echo "- A ${agent} was disabled, enabling" 
	mv /System/Library/LaunchAgents.off/${agent}.plist /System/Library/LaunchAgents/${agent}.plist
        launchctl load -w /System/Library/LaunchAgents/${agent}.plist
  } || {
 	echo "! A ${agent} does not exists, or was not disabled" 
  }

done < "$input"

# DAEMONS

input="/etc/appleshit.daemons.${OSX}.cfg"
echo "----- APPLE DAEMONS"
while IFS= read -r daemon
do
  var=${daemon}
  [[ $var =~ ^#.* ]] && continue
  [ -f /System/Library/LaunchDaemons.off/${daemon}.plist ] && {
 	echo "- D ${daemon} was disabled, enabling"
	mv /System/Library/LaunchDaemons.off/${daemon}.plist /System/Library/LaunchDaemons/${daemon}.plist
        launchctl load -w /System/Library/LaunchDaemons/${daemon}.plist
  } || {
 	echo "! D ${daemon} does not exists, or was not disabled" 
  }

done < "$input"


