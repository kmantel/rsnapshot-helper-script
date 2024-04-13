# rsnapshot-helper-script
A helper script for rsnapshot that works similar to anacron.

This script arose from the problem that my backup drive is not constantly plugged into my laptop. Placed e.g. in /etc/cron.hourly it checks every hour whether a (hourly, weekly, ...) backup is due. Upon a failed run of rsnapshot, e.g. if the backup drive is not plugged in, the backup is postponed and run on the next hour. If invoked by a udev rule the backup can be run as soon as the drive is plugged in.
