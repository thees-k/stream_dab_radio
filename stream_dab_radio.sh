#!/bin/bash

# Check if the script is run as root
if [ $EUID -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
! command_exists icecast2 && echo "'icecast2' is not installed." && exit 1
! command_exists darkice && echo "'darkice' is not installed." && exit 1
! command_exists screen && echo "'screen' is not installed." && exit 1
! command_exists welle-cli && echo "'welle-cli' is not installed." && exit 1

# Usage function to display help
usage() {
    script_name=$(basename "$0")
    echo "Usage: $script_name -c DARKICE_CONFIG -h CHANNEL -s STATION_NAME"
    exit 1
}

# Parsing command line arguments
while getopts ":c:h:s:" opt; do
    case $opt in
        c) DARKICE_CONFIG="$OPTARG"
        ;;
        h) CHANNEL="$OPTARG"
        ;;
        s) STATION_NAME="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
        :) echo "Option -$OPTARG requires an argument." >&2
           usage
        ;;
    esac
done

# Check if mandatory parameters are set
if [ -z "$DARKICE_CONFIG" ] || [ -z "$CHANNEL" ] || [ -z "$STATION_NAME" ]; then
    usage
fi

# Function to start the DAB radio
start_dab_radio() {
    systemctl restart icecast2 && echo "icecast2 started."
    darkice -v10 -c "$DARKICE_CONFIG" &
    job_darkice_id=$!
    [ $job_darkice_id -gt -1 ] && echo "darkice started."
    screen -d -m -S welle-cli-server welle-cli -c "$CHANNEL" -p "$STATION_NAME" > /dev/null && sleep 1 && echo "welle-cli (\"$STATION_NAME\" @ $CHANNEL) started."
}

# Function to stop the DAB radio
stop_dab_radio() {
    screen -S welle-cli-server -p 0 -X stuff ".^M" && sleep 1 && echo "\nwelle-cli stopped."
    if [ $job_darkice_id -gt -1 ]; then
        kill $job_darkice_id 2> /dev/null && echo "darkice stopped."
    fi
    systemctl stop icecast2 && echo "icecast2 stopped."
    now=$(date -d now +"%Y-%m-%d %H:%M:%S")
    echo "$now: Stopped the radio."
}

# Function to stop the DAB radio and exit
stop_dab_radio_and_exit() {
    stop_dab_radio
    exit 0
}

# Trap SIGINT to stop the DAB radio and exit
trap stop_dab_radio_and_exit SIGINT

# Start the DAB radio
start_dab_radio

echo
echo "-> Press CTRL+C to stop/exit!!"
echo

# Wait indefinitely until the user stops the script
wait
