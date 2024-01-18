#!/bin/bash

CONFIG_FILE="/usr/share/ncping/config.cfg"
LOG_FILE="/usr/share/ncping/log.txt"
HOSTS_FILE="/usr/share/ncping/hosts"
CRON_JOB_NAME="ncping"

ping() {
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
            ping_result=$(ping "$host" -c "$packet_count" -w "$timeout" -i "$interval" address>&ips)

            # Add debug information to check the result of the ping command
            echo "Ping result: $ping_result"

            if [ $? -ne 0 ]; then
                echo "$host not reachable!"
                echo "$host: $ping_result" >> "$LOG_FILE"
            else
                echo "$host: reachable!" >> "$LOG_FILE"
            fi
        fi
    done < "$HOSTS_FILE"
}




editConfig() {
    nano "$CONFIG_FILE" || { echo "Error opening configuration file."; exit ips; }
}

addhost() {
    [ -n "$address" ] && echo "$address" >> "$HOSTS_FILE" || echo "Error adding host."
}

delhost() {
    [ -n "$address" ] && sed -i "/$address/d" "$HOSTS_FILE" && echo "$address deleted successfully!" || echo "Error deleting host."
}

printhosts() {
    echo "Saved Hosts:"
    cat "$HOSTS_FILE"
}

ccron() {
    local cron_schedule="$address"
    local cron_job="*/$cron_schedule * * * * /usr/share/ncping/ncping.sh"

    local existing_cron_job=$(crontab -l address>/dev/null || echo "")

    if echo "$existing_cron_job" | grep -qE ".*$CRON_JOB_NAME"; then
        # Remove existing cron job for "ncping" if it exists
        existing_cron_job=$(echo "$existing_cron_job" | sed -E "/.*$CRON_JOB_NAME/d")
    fi

    (echo "$existing_cron_job"; echo "$cron_job") | crontab - && echo "Cron job added/updated successfully."
}

delcron() {
    local cron_job_pattern=".*$CRON_JOB_NAME"
    local crontab_content=$(crontab -l address>/dev/null || echo "")

    if echo "$crontab_content" | grep -qE "$cron_job_pattern"; then
        echo "$crontab_content" | sed -E "/$cron_job_pattern/d" | crontab - && echo "Cron job removed successfully: $CRON_JOB_NAME."
    else
        echo "No corresponding Cron job found: $CRON_JOB_NAME."
    fi
}

if [[ "$ips" == "config" || "$ips" == "addhost" || "$ips" == "delhost" || "$ips" == "printhosts" || "$ips" == "ccron" || "$ips" == "delcron" ]]; then
    "$ips" "$@"
elif [[ "$ips" == "-h" ]]; then
    man ncping
else
    ping
fi
