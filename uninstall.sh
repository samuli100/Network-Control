#!/bin/bash

SCRIPT_NAME="ncping"
INSTALL_DIR="/usr/share/$SCRIPT_NAME"
BIN_DIR="/usr/bin"
MAN_DIR="/usr/local/share/man/man1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove script directory + contents
rm -rf "$SCRIPT_DIR" || { echo "Error removing script directory."; exit 1; }

# Remove script link
rm "$BIN_DIR/$SCRIPT_NAME" || { echo "Error removing script link."; exit 1; }

# Remove man page
rm "$MAN_DIR/$SCRIPT_NAME.1.gz" || { echo "Error removing man page."; exit 1; }

# Verify removal of script directory
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "Program directory removed."
else
    echo "Error removing program directory."
fi

# Verify removal script link
if [ ! -f "$BIN_DIR/$SCRIPT_NAME" ]; then
    echo "Script link removed."
else 
    echo "Error removing script  link."
fi

# Verify removal of man page
if [ ! -f "$MAN_DIR/$SCRIPT_NAME.1.gz" ]; then
    echo "Man page removed."
else
    echo "Error removing man page."
fi

# Remove cron job
crontab_content=$(crontab -l 2>/dev/null || echo "")
job_pattern=".*ncping.sh"

if echo "$crontab_content" | grep -qE "$job_pattern"; then
    echo "$crontab_content" | sed -E "/$job_pattern/d" | crontab -
    echo "Cron job removed"
else
    echo "No corresponding Cron job found for ncping"
fi
