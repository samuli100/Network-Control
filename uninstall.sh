#!/bin/bash

SCRIPT_NAME="ncping"
SCRIPT_NAME_ger="ncping_ger"
SCRIPT_DIR="/usr/share/$SCRIPT_NAME"
BIN_DIR="/usr/bin"
MAN_DIR="/usr/local/share/man/man1"

# Entfernt Cronjob
    local existing_cron_job=$(crontab -l 2>/dev/null || echo "")

    # Löscht Cronjob wenn er existiert
    if echo "$existing_cron_job" | grep -qE ".*$SCRIPT_NAME"; then
        existing_cron_job=$(echo "$existing_cron_job" | sed -E "/.*$SCRIPT_NAME/d")
    
    else
        echo "No corresponding Cron job found: $SCRIPT_NAME."
    fi


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
