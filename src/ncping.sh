#!/bin/bash

CONFIG_FILE="/usr/share/ncping/config.cfg"
LOG_FILE="/usr/share/ncping/log.txt"
HOSTS_FILE="/usr/share/ncping/hosts"
GROUPS_FILE="/usr/share/ncping/groups"
CRON_JOBS_FILE="/usr/share/ncping/cronjobs"
CRON_JOB_NAME="ncping"

pinging() {
    local anzahl_pakete=""
    local timeout=""
    local zeitintervall=""

    while IFS= read -r line; do
        case "$line" in
            "# Anzahl Pakete")
                read -r anzahl_pakete
                ;;
            "# Timeout in Sekunden")
                read -r timeout
                ;;
            "# Zeitintervall in Sekunden")
                read -r zeitintervall
                ;;
            *)
                continue
                ;;
        esac
    done < "$CONFIG_FILE"

    [[ $zeitintervall -eq 0 ]] && zeitintervall=1  # Should not be 0

    echo "---------- Start Pinging ----------"

    while IFS= read -r line || [ -n "$line" ]; do
        [[ -n "$line" ]] || continue

        echo "Ping will be executed for: $line"

        ping -c "$anzahl_pakete" -w "$timeout" -i "$zeitintervall" "$line"

        [[ $? -ne 0 ]] && { echo "$line not reachable!"; echo "$line" >> "$LOG_FILE"; }

        echo "-------------------------"
    done < "$HOSTS_FILE"
}

editConfig() {
    nano "$CONFIG_FILE" || { echo "Error opening configuration file."; exit 1; }
}

addhost() {
    [[ -n "$2" ]] || { echo "No IP address provided."; return 1; }

    echo "$2" >> "$HOSTS_FILE" && echo "$2 added successfully to default group!" || echo "Error adding host."
}

delhost(){
    [[ -n "$2" ]] || { echo "No IP address provided."; return 1; }

    sed -i "/$2/d" "$HOSTS_FILE" && echo "$2 deleted successfully!" || echo "Error deleting host."
}

printhosts(){
    echo "Saved Hosts:"
    cat "$HOSTS_FILE"
}

creategroup() {
    [[ -n "$2" ]] || { echo "No group name provided."; return 1; }

    echo "$2" >> "$GROUPS_FILE" && echo "Group $2 created successfully!" || echo "Error creating group."
}

delgroup() {
    [[ -n "$2" ]] || { echo "No group name provided."; return 1; }

    sed -i "/$2/d" "$GROUPS_FILE" && echo "Group $2 deleted successfully!" || echo "Error deleting group."
}

addgroup() {
    [[ -n "$2" && -n "$3" ]] || { echo "Usage: ncping addgroup GROUP_NAME IP_ADDRESS"; return 1; }

    echo "$2 $3" >> "$GROUPS_FILE" && echo "$3 added to group $2 successfully!" || echo "Error adding host to group."
}

rmgroup() {
    [[ -n "$2" && -n "$3" ]] || { echo "Usage: ncping rmgroup GROUP_NAME IP_ADDRESS"; return 1; }

    sed -i "/$2 $3/d" "$GROUPS_FILE" && echo "$3 removed from group $2 successfully!" || echo "Error removing host from group."
}

ccron() {
    [[ -n "$2" ]] || { echo "Usage: ncping ccron GROUP_NAME CRON_SCHEDULE"; return 1; }

    local group_name="$2"
    local cron_schedule="$3"

    if grep -qE "^$group_name " "$GROUPS_FILE"; then
        local cron_job="*/$cron_schedule * * * * /bin/bash -c '/usr/share/ncping/ncping.sh $group_name'"

        (crontab -l ; echo "$cron_job") | crontab - && echo "Cron job added successfully for group $group_name."
        echo "$cron_job" >> "$CRON_JOBS_FILE"
    else
        echo "Group $group_name does not exist."
    fi
}

delcron() {
    [[ -n "$2" ]] || { echo "Usage: ncping delcron GROUP_NAME"; return 1; }

    local group_name="$2"

    if grep -qE "^$group_name " "$GROUPS_FILE"; then
        local cron_job_pattern=".*$CRON_JOB_NAME.sh $group_name"
        local crontab_content=$(crontab -l 2>/dev/null || echo "")

        if echo "$crontab_content" | grep -qE "$cron_job_pattern"; then
            echo "$crontab_content" | sed -E "/$cron_job_pattern/d" | crontab - && echo "Cron job removed successfully for group $group_name."
            sed -i "/$group_name/d" "$CRON_JOBS_FILE"
        else
            echo "No corresponding Cron job found for group $group_name."
        fi
    else
        echo "Group $group_name does not exist."
    fi
}

case "$1" in
    "config" | "addhost" | "delhost" | "lshosts" | "creategroup" | "delgroup" | "addgroup" | "rmgroup" | "ccron" | "delcron")
        "$1" "$@"
        ;;
    "-h")
        man ncping
        ;;
    *)
        pinging
        ;;
esac