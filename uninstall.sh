#!/bin/bash

SCRIPT_NAME="ncping"
CRON_JOB_NAME="ncping"
SCRIPT_NAME_ger="ncping_ger"
SCRIPT_DIR="/usr/share/$SCRIPT_NAME"
BIN_DIR="/usr/bin"
MAN_DIR="/usr/local/man/man1"

# Entfernt Cronjob
rmc() {
    local cron_job_pattern=".*$CRON_JOB_NAME"
    local crontab_content=$(crontab -l 2>/dev/null || echo "")

    # Löscht den Cronjob wenn er existiert
    if echo "$crontab_content" | grep -qE "$cron_job_pattern"; then
        echo "$crontab_content" | sed -E "/$cron_job_pattern/d" | crontab - && echo "Cron job removed successfully: $CRON_JOB_NAME."
    else
        echo "No corresponding Cron job found: $CRON_JOB_NAME."
    fi
}

# Fügt informationen hinzu
echo "Removing script directory: $SCRIPT_DIR"

# Entfernt Skript Ordner
rm -rf "$SCRIPT_DIR" || { echo "Error removing script directory."; exit 1; }

# Entfernt Skript link
rm "$BIN_DIR/$SCRIPT_NAME" || { echo "Error removing script link."; exit 1; }

# Enfernt man page
rm "$MAN_DIR/$SCRIPT_NAME.1.gz" "$MAN_DIR/$SCRIPT_NAME_ger.1.gz" || { echo "Error removing man pages."; exit 1; }

# Verifiziert die Auslöschung
[ ! -d "$SCRIPT_DIR" ] && echo "Program directory removed." || echo "Error removing program directory."
[ ! -f "$BIN_DIR/$SCRIPT_NAME" ] && echo "Script link removed." || echo "Error removing script link."
[ ! -f "$MAN_DIR/$SCRIPT_NAME.1.gz" ] && [ ! -f "$MAN_DIR/$SCRIPT_NAME_ger.1.gz" ] && echo "Man pages removed." || echo "Error removing man pages."
