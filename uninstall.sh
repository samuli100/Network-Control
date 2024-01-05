#!/bin/bash

CRON_JOB_NAME="ncping"
SCRIPT_DIR="/usr/share/ncping"
BIN_DIR="/usr/bin"
MAN_DIR="/usr/local/share/man/man1"

# Remove cron job
cron_content=$(crontab -l 2>/dev/null || echo "")
cron_job_pattern=".*$CRON_JOB_NAME.sh"

if echo "$cron_content" | grep -qE "$cron_job_pattern"; then
    echo "$cron_content" | sed -E "/$cron_job_pattern/d" | crontab -
    echo "Cron job removed"
else
    echo "No corresponding Cron job found for $CRON_JOB_NAME"
fi

# Remove script directory + contents
rm -rf "$SCRIPT_DIR" || { echo "Error removing script directory."; exit 1; }

# Remove script link
rm "$BIN_DIR/$CRON_JOB_NAME" || { echo "Error removing script link."; exit 1; }

# Remove man page
rm "$MAN_DIR/$CRON_JOB_NAME.1.gz" || { echo "Error removing man page."; exit 1; }

# Verify removal of script directory
[ ! -d "$SCRIPT_DIR" ] && echo "Program directory removed." || echo "Error removing program directory."

# Verify removal script link
[ ! -f "$BIN_DIR/$CRON_JOB_NAME" ] && echo "Script link removed." || echo "Error removing script  link."

# Verify removal of man page
[ ! -f "$MAN_DIR/$CRON_JOB_NAME.1.gz" ] && echo "Man page removed." || echo "Error removing man page."
