#!/bin/bash

CONFIG_FILE="/usr/share/ncping/config.cfg"
LOG_FILE="/usr/share/ncping/log.txt"
HOSTS_FILE="/usr/share/ncping/hosts"
CRON_JOBS_FILE="/usr/share/ncping/cronjobs"
CRON_JOB_NAME="ncping"

pinging() {
    local packet_count timeout interval

    read -r packet_count timeout interval < <(awk '/# (Packet Count|Timeout|Interval) in seconds/ {print $NF}' "$CONFIG_FILE")

    ((interval == 0)) && interval=0.002

    while read -r line || [ -n "$line" ]; do
        [ -n "$line" ] || continue
        echo "Ping will be executed for: $line"

        # Run ping with -D to display timestamp and capture the output
        ping_output=$(ping "$line" -c "$packet_count" -w "$timeout" -i "$interval" -D)

        if [ $? -eq 0 ]; then
            # Extract and append timestamp to the IP address in the log file
            timestamp=$(echo "$ping_output" | awk '/^PING/ {print $1}')
            echo "$line [$timestamp]" >> "$LOG_FILE"
        else
            echo "$line not reachable!"
            echo "$line" >> "$LOG_FILE"
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
