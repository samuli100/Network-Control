#!/bin/bash

CONFIG_FILE="/usr/share/ncping/config.cfg"
LOG_FILE="/usr/share/ncping/log.txt"
HOSTS_FILE="/usr/share/ncping/hosts"
CRON_JOBS_FILE="/usr/share/ncping/cronjobs"
CRON_JOB_NAME="ncping"

pinging() {
    local packet_count timeout interval

    while IFS= read -r host; do
        case "$host" in
            "Packet Count")
                read -r packet_count
                ;;
            "Timeout")
                read -r timeout
                ;;
            "Interval")
                read -r interval
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

            # Add debug information to check the result of the ping command
            echo "Ping result: $ping_result"

            if [ $? -ne 0 ]; then
                echo "$host not reachable!"
                echo "$host: $ping_result" >> "$LOG_FILE"
            else
                echo "$host reachable!"
                echo "$host: $ping_result" >> "$LOG_FILE"
            fi
        fi
    done < "$HOSTS_FILE"
}




editConfig() {
    nano "$CONFIG_FILE" || { echo "Error opening configuration file."; exit 1; }
}

addhost() {
    [ -n "$2" ] && echo "$2" >> "$HOSTS_FILE" || echo "Error adding host."
}

delhost() {
    [ -n "$2" ] && sed -i "/$2/d" "$HOSTS_FILE" && echo "$2 deleted successfully!" || echo "Error deleting host."
}

printhosts() {
    echo "Saved Hosts:"
    cat "$HOSTS_FILE"
}

ccron() {
    local cron_schedule="$2"

    if [ -n "$cron_schedule" ]; then
        local cron_job="*/$cron_schedule * * * * /usr/share/ncping/ncping.sh"

        (crontab -l ; echo "$cron_job") | crontab - && echo "Cron job added successfully."
        echo "$cron_job" >> "$CRON_JOBS_FILE"
    else
        echo "Cron schedule not provided."
    fi
}

delcron() {
    [ -n "$2" ] && local cron_job_name="$2"

    local cron_job_pattern=".*$cron_job_name"
    local crontab_content=$(crontab -l 2>/dev/null || echo "")

    if echo "$crontab_content" | grep -qE "$cron_job_pattern"; then
        echo "$crontab_content" | sed -E "/$cron_job_pattern/d" | crontab - && echo "Cron job removed successfully: $cron_job_name."
    else
        echo "No corresponding Cron job found: $cron_job_name."
    fi
}

if [[ "$1" == "config" || "$1" == "addhost" || "$1" == "delhost" || "$1" == "printhosts" || "$1" == "ccron" || "$1" == "delcron" ]]; then
    "$1" "$@"
elif [[ "$1" == "-h" ]]; then
    man ncping
else
    pinging
fi
