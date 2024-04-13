#!/bin/bash
#
# This script checks in /var/spool/rsnapshot when the next 
# scheduled run of rsnapshot is. It runs rsnapshot when it 
# is due and updates the timer if it ran sucessfully.

# Timers are stored in $SPOOL/next.${BACKUP_LEVEL}
SPOOL=/var/spool/rsnapshot

# check_and_repair $BACKUP_LEVEL:
#    $BACKUP_LEVEL: Name of the backup level
#
# Checks if the timer for $BACKUP_LEVEL is sane and 
# repairs this timer if neccessary.
function check_and_repair {
        if ! [[ -f "$SPOOL/next.$1" ]]; then 
                echo "Backup timer /var/spool/rsnapshot/next.$1 is missing. Scheduling immediate backup."
                /bin/date +%s > $SPOOL/next.$1
        fi

        if ! [[ "$(/bin/cat $SPOOL/next.$1)" =~ ^[0-9]+$ ]]; then
                echo "Backup timer /var/spool/rsnapshot/next.$1 is damaged. Scheduling immediate backup."
                /bin/date +%s > $SPOOL/next.$1
        fi
}

# run $BACKUP_LEVEL $TIME:
#    $BACKUP_LEVEL: Name of the backup level
#    $TIME:         Length of the backup level (in sec)
#
# Checks if we have to run rsnapshot backup level 
# $BACKUP_LEVEL and scheduels a next backup in $TIME 
# seconds if run successfully.
function run {
        check_and_repair $1
        if [[ "$(/bin/cat $SPOOL/next.$1)" -le "$(/bin/date +%s)" ]]; then
                /usr/bin/rsnapshot $1 && echo $(($(/bin/date +%s) + $2)) > $SPOOL/next.$1
        fi
}

# Run daily, weekly, monthly and yearly updates. Run higher
# backup levels first as higher backup-levels are just 
# copied from lower backup levels
run yearly  29030400
run monthly 2419200
run weekly  604800
run daily   86400
