#!/bin/bash
OSX=$(sw_vers -productVersion | cut -f 1-2 -d .)

[ -f /etc/appleshit.daemons.${OSX}.cfg ] || {
echo "Please create /etc/appleshit.daemons.${OSX}.cfg with all daemons to disable, one per line."
	exit 1
}


[ -f /etc/appleshit.agents.${OSX}.cfg ] || {
	echo "Please create /etc/appleshit.agents.${OSX}.cfg with all agents to disable, one per line."
	exit 1
}

if [[ $EUID -ne 0 ]]; then
    echo "${0}: This script must be run using sudo or as the root user"
    exit 1
fi


# Create backup dirs if not already created
[ -d /System/Library/LaunchDaemons.off ] || mkdir /System/Library/LaunchDaemons.off
[ -d /System/Library/LaunchAgents.off ] || mkdir /System/Library/LaunchAgents.off

# Disable AGENTS

echo "----- APPLE AGENTS"
input="/etc/appleshit.agents.${OSX}.cfg"

while IFS= read -r agent
do
  var=${agent}
  [[ $var =~ ^#.* ]] && continue
  [ -f /System/Library/LaunchAgents/${agent}.plist ] && {
 	echo "- A ${agent} exists, disabling" 
        launchctl unload -w /System/Library/LaunchAgents/${agent}.plist > /dev/null
	mv /System/Library/LaunchAgents/${agent}.plist /System/Library/LaunchAgents.off/${agent}.plist
  } || {
	[ -f /System/Library/LaunchAgents.off/${agent}.plist ] && {
 		echo "! A ${agent} ALREADY DISABLED" 
	} || echo "! A ${agent} DOES NOT EXIST" 
  }

done < "$input"

# Disable DAEMONS

input="/etc/appleshit.daemons.${OSX}.cfg"
echo "----- APPLE DAEMONS"
while IFS= read -r daemon
do
  var=${daemon}
  [[ $var =~ ^#.* ]] && continue
  [ -f /System/Library/LaunchDaemons/${daemon}.plist ] && {
 	echo "- D ${daemon} exists, disabling" 
        launchctl unload -w /System/Library/LaunchDaemons/${daemon}.plist > /dev/null
	mv /System/Library/LaunchDaemons/${daemon}.plist /System/Library/LaunchDaemons.off/${daemon}.plist
  } || {
	[ -f /System/Library/LaunchDaemons.off/${daemon}.plist ] && {
 		echo "! D ${daemon} ALREADY DISABLED" 
	} || echo "! D ${daemon} DOES NOT EXIST" 
  }

done < "$input"


