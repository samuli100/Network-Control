#!/bin/bash

CONFIG_FILE="/usr/share/ncping/config.cfg"
LOG_FILE="/usr/share/ncping/log.txt"
HOSTS_FILE="/usr/share/ncping/hosts"
CRON_JOB_NAME="ncping"

pinging() {
    local packet_count timeout interval

    while IFS= read -r line; do
        case "$line" in
            "Packet Count "*)
                packet_count="${line#Packet Count }"
                ;;
            "Timeout "*)
                timeout="${line#Timeout }"
                ;;
            "Interval "*)
                interval="${line#Interval }"
                ;;
            *)
                continue
                ;;
        esac
    done < "$CONFIG_FILE"

    ((interval == 0)) && interval=0.002

    while IFS= read -r host || [ -n "$host" ]; do
        if [ -n "$host" ]; then
            echo "Ping will be executed for: $host"

            # Redirect the output of ping to both the console and the log file
            ping_result=$(ping "$host" -c "$packet_count" -w "$timeout" -i "$interval" 2>&1)

            # Add debug information to check the result of the ping
            echo "Ping result: $ping_result"

            packet_loss=$(echo "$ping_result" | grep -oP "\d+(\.\d+)?(?=% packet loss)")

            if [ $? -ne 0 ] || [ "$packet_loss" == "100" ] || [ -z "$packet_loss" ]; then
                current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_datetime : $host not reachable!" >> "$LOG_FILE"
            else
                current_datetime=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_datetime : $host reachable with $packet_loss% packet loss" >> "$LOG_FILE"
            fi
        fi
    done < "$HOSTS_FILE"
}

config() {
    nano "$CONFIG_FILE" || { echo "Error opening configuration file."; exit 1; }
}

log() {
    nano "$LOG_FILE" || { echo "Error opening log file."; exit 1; }
}

addhost() {
    [ -n "$2" ] && echo "$2" >> "$HOSTS_FILE" || echo "Error adding host."
}

delhost() {
    [ -n "$2" ] && sed -i "/$2/d" "$HOSTS_FILE" && echo "$2 deleted successfully!" || echo "Error deleting host."
}

-l() {
    echo "Saved Hosts:"
    cat "$HOSTS_FILE"
}

ccron() {
    local cron_schedule="$2"
    local cron_job="*/$cron_schedule * * * * /usr/share/ncping/ncping.sh"

    local existing_cron_job=$(crontab -l 2>/dev/null || echo "")

    if echo "$existing_cron_job" | grep -qE ".*$CRON_JOB_NAME"; then
        # Remove existing cron job for "ncping" if it exists
        existing_cron_job=$(echo "$existing_cron_job" | sed -E "/.*$CRON_JOB_NAME/d")
    fi

    (echo "$existing_cron_job"; echo "$cron_job") | crontab - && echo "Cron job added/updated successfully."
}

delcron() {
    local cron_job_pattern=".*$CRON_JOB_NAME"
    local crontab_content=$(crontab -l 2>/dev/null || echo "")

    if echo "$crontab_content" | grep -qE "$cron_job_pattern"; then
        echo "$crontab_content" | sed -E "/$cron_job_pattern/d" | crontab - && echo "Cron job removed successfully: $CRON_JOB_NAME."
    else
        echo "No corresponding Cron job found: $CRON_JOB_NAME."
    fi
}

if [[ "$1" == "config" || "$1" == "log" || "$1" == "addhost" || "$1" == "delhost" || "$1" == "-l" || "$1" == "ccron" || "$1" == "delcron" ]]; then
    "$1" "$@"
elif [[ "$1" == "-h" ]]; then
    man ncping
else
    pinging
fi
