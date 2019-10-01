# appleshit.enable.sh & appleshit.disable.sh

These scripts disable (And enable again) most background services in your OSX computer that are constantly contacting apple for a variety of reasons.

Latest versions of OSX (Mojave) have an insane amount of services that are constantly contacting their systems to register metrics, synchronizations, updates, ....

### When you may need this?

- If you are a professional user that don't use the Apple Fancies, but only your programs. 

- If you are using your computer for demanding tasks like live performances and you need all horsepower for yourself

### When you should NOT use this

- If you mosty use your Mac to enjoy Apple services and synchronize devices like your iPhone or Apple Watch, iCloud, etc.

- If you don't understand anything we're talking about here

PLEASE MIND THAT A LOT OF APPLE FANCIES WILL NOT WORK ANYMORE WHEN YOU DISABLE THE SERVICES UNTIL YOU ENABLE THEM AGAIN. YOUR IPHONE WILL PROBABLY DON'T SYNC WITH THE COMPUTER. YOUR KITTEN PHOTOS WILL NOT BE UPLOADED TO ICLOUD. SIRI WILL NOT LOVE YOU ANYMORE.

### installing

- execute the provided script "install-osx.sh" as superuser from terminal (**sudo ./install-osx.sh**)
- scripts are installed to **/usr/local/bin** (it is in the path by default)
- configuration files are installed to **/etc/appleshit.*.cfg**

### running

#### To disable all daemons and agents

- from terminal, type **sudo appleshit.disable.sh**
- some services need a reboot in order to be totally disabled, so if in doubt just reboot your computer.

#### To re-enable all daemons and agents

- from terminal, type **sudo appleshit.enable.sh**
- some services need a reboot in order to be totally disabled, so if in doubt just reboot your computer.

### additional configuration

On /etc/ you find the following files

- [/etc/appleshit.daemons.10.14.cfg](etc/appleshit.daemons.10.14.cfg)
	
	This file contains all the daemons to disable/enable, one per line. You can use a # as the first character to ignore that service.
	
- [/etc/appleshit.agents.10.14.cfg](etc/appleshit.agents.10.14.cfg)

	This file contains all the agents to disable/enable, one per line. You can use a # as the first character to ignore that service.

You can edit those files and delete or add more services
The **10.14** part of the filename means those files will be used when running on OSX 10.14 (Mojave). If you are running another version, you must create new files with your version number. This is because some Agents are different across OSX versions. For example, for a system running OSX 10.13 (High Sierra) you will create

- **/etc/appleshit.daemons.10.13.cfg**
- **/etc/appleshit.agents.10.13.cfg**

Mind that you need to investigate what services and daemons to enable and disable. This version currently contains Mpjave services only.

### technical info

In OSX, agents and daemons launchers are stored in

- /System/Library/LaunchAgents/
- /System/Library/LaunchDaemons/

These scripts create two additional folders

- /System/Library/LaunchAgents.off/
- /System/Library/LaunchDaemons.off/

... and move the disabled services launchers there so they are not started. When you enable the services, the files are moved back to their original location.
