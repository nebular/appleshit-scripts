#!/bin/bash

# AGENTS

echo "----- APPLE AGENTS"
input="/etc/appleshit.agents.cfg"

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

input="/etc/appleshit.daemons.cfg"
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


