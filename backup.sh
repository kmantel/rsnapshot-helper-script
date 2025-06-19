#!/usr/bin/env bash
#
# This script checks in /var/spool/rsnapshot when the next 
# scheduled run of rsnapshot is. It runs rsnapshot when it 
# is due and updates the timer if it ran sucessfully.


USAGE="Usage: $(basename $0) [OPTIONS]

Options:
    -h help
    -v verbose       - Show equivalent shell commands being executed.
    -t test          - Show verbose output, but don't touch anything.
                       This will be similar, but not always exactly the same
                       as the real output from a live run.
    -c [file]        - Specify alternate config file (-c /path/to/file)
    -q quiet         - Suppress non-fatal warnings.
    -V extra verbose - The same as -v, but with more detail.
    -D debug         - A firehose of diagnostic information.
    -x one_fs        - Don't cross filesystems (same as -x option to rsync).
"

test=""
config=""

while getopts "htc:" opt; do
  case $opt in
    t)
        test="-t"
        ;;
    c)
        config="$OPTARG"
        ;;
    h)
        echo "$USAGE"
        exit 0
        ;;
    :)
        echo "option requires an argument -- $OPTARG"
        echo "$USAGE"
        exit 1
        ;;
    \?)
        echo "Invalid option -$OPTARG" >&2
        echo "$USAGE"
        exit 1
        ;;
  esac
done

shift $((OPTIND-1))


# Timers are stored in $SPOOL/next.${BACKUP_LEVEL}
SPOOL=/var/spool/rsnapshot


function spool_file {
        interval=$1
        if [[ -n "$2" ]]; then
                conf=$(basename "$2")
        else
                conf="default"
        fi
        echo "$SPOOL/next.$conf.$interval"
}

spool_file daily
spool_file daily $config

# check_and_repair $BACKUP_LEVEL:
#    $BACKUP_LEVEL: Name of the backup level
#
# Checks if the timer for $BACKUP_LEVEL is sane and 
# repairs this timer if neccessary.
function check_and_repair {
        mkdir -p "$SPOOL"
        spoolfi=$(spool_file "$1" "$config")

        if ! [[ -f "$spoolfi" ]]; then
                echo "Backup timer $spoolfi is missing. Scheduling immediate backup."
                if [[ -z "$test" ]]; then
                        /bin/date +%s > "$spoolfi"
                fi
        fi

        if ! [[ "$(/bin/cat $spoolfi)" =~ ^[0-9]+$ ]]; then
                echo "Backup timer $spoolfi is damaged. Scheduling immediate backup."
                if [[ -z "$test" ]]; then
                        /bin/date +%s > "$spoolfi"
                fi
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
        spoolfi=$(spool_file "$1" "$config")
        echo ${@:3}
        if [[ "$(/bin/cat $spoolfi)" -le "$(/bin/date +%s)" ]]; then
                rsnapshot $1 ${@:3}
                if (( ! $? )) && [[ -z "$test" ]]; then
                        echo $(($(/bin/date +%s) + $2)) > "$spoolfi"
                fi
        fi
}

# Run daily, weekly, monthly and yearly updates. Run higher
# backup levels first as higher backup-levels are just 
# copied from lower backup levels
run yearly  29030400 "$@"
run monthly 2419200 "$@"
run weekly  604800 "$@"
run daily   86400 "$@"
run hourly  3600 "$@"
