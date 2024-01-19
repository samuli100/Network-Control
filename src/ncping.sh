#!/bin/bash

# Definieren von Dateipfaden und -namen
CONFIG_FILE="/usr/share/ncping/config.txt"
LOG_FILE="/usr/share/ncping/log.txt"
HOSTS_FILE="/usr/share/ncping/hosts"
CRON_JOB_NAME="ncping"

# Funktion zur Durchführung von Ping-Tests
pinging() {
    local packet_count timeout interval

    # Konfigurationsparameter aus der Konfigurationsdatei lesen
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

    # Standardintervall einstellen, wenn es nicht angegeben ist
    ((interval == 0)) && interval=0.002

    # Hosts aus der Hosts-Datei lesen und Ping-Tests durchführen
    while IFS= read -r host || [ -n "$host" ]; do
        if [ -n "$host" ]; then
            echo "Ping will be executed for: $host"

            # Führt Ping aus und schreibt es in ping result
            ping_result=$(ping "$host" -c "$packet_count" -w "$timeout" -i "$interval" 2>&1)

            # Ausgabe des Pings
            echo "Ping result: $ping_result"

            # Prozentsatz der Paketverluste extrahieren
            packet_loss=$(echo "$ping_result" | grep -oP "\d+(\.\d+)?(?=% packet loss)")

            # Prüft den Ping
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

# Edit Config
config() {
    nano "$CONFIG_FILE" || { echo "Error opening configuration file."; exit 1; }
}

# Edit Log
log() {
    nano "$LOG_FILE" || { echo "Error opening log file."; exit 1; }
}

# Hosts hinzufügen
addhost() {
    local new_host="$2"

    # Überprüfen, ob der Host bereits existiert
    local exists=false
    while IFS= read -r line; do
        if [ "$line" == "$new_host" ]; then
            exists=true
            break
        fi
    done < "$HOSTS_FILE"

    # Entscheidung basierend auf dem Überprüfungsergebnis treffen
    if [ "$exists" = true ]; then
        echo "$new_host already exists."
    else
        [ -n "$new_host" ] && echo "$new_host" >> "$HOSTS_FILE" || echo "Error adding host."
    fi
}

# Hosts löschen
delhost() {
    [ -n "$2" ] && sed -i "/$2/d" "$HOSTS_FILE" && echo "$2 deleted successfully!" || echo "Error deleting host."
}

# Listet alle gespeicherten Hosts auf
-l() {
    echo "Saved Hosts:"
    cat "$HOSTS_FILE"
}

# Cron Jobs hinzufügen
ccron() {
    local cron_schedule="$2"
    local cron_job="*/$cron_schedule * * * * /usr/share/ncping/ncping.sh"

    local existing_cron_job=$(crontab -l 2>/dev/null || echo "")

    # Löscht Cronjob wenn er existiert
    if echo "$existing_cron_job" | grep -qE ".*$CRON_JOB_NAME"; then
        existing_cron_job=$(echo "$existing_cron_job" | sed -E "/.*$CRON_JOB_NAME/d")
    fi

    # Fügt den Cronjob hinzu
    (echo "$existing_cron_job"; echo "$cron_job") | crontab - && echo "Cron job added/updated successfully."
}

# Cron Jobs löschen
delcron() {
    local cron_job_pattern=".*$CRON_JOB_NAME"
    local crontab_content=$(crontab -l 2>/dev/null || echo "")

    # Löscht den Cronjob wenn er existiert
    if echo "$crontab_content" | grep -qE "$cron_job_pattern"; then
        echo "$crontab_content" | sed -E "/$cron_job_pattern/d" | crontab - && echo "Cron job removed successfully: $CRON_JOB_NAME."
    else
        echo "No corresponding Cron job found: $CRON_JOB_NAME."
    fi
}

# Logik
if [[ "$1" == "config" || "$1" == "log" || "$1" == "addhost" || "$1" == "delhost" || "$1" == "-l" || "$1" == "ccron" || "$1" == "delcron" ]]; then
    "$1" "$@"
elif [[ "$1" == "-h" ]]; then
    man ncping
else
    pinging
fi
