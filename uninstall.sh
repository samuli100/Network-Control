#!/bin/bash

INSTALL_DIR="/usr/share/ncping"
BIN_DIR="/usr/bin"
MAN_DIR="/usr/local/share/man/man1"
CRON_JOBS_FILE="/usr/share/ncping/cronjobs"

# Remove script directory + contents
rm -rf "$INSTALL_DIR" || { echo "Error removing script directory."; exit 1; }

# Remove script link
rm "$BIN_DIR/ncping" || { echo "Error removing script link."; exit 1; }

# Remove man page
rm "$MAN_DIR/ncping.1.gz" || { echo "Error removing man page."; exit 1; }

# Verify removal of script directory
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Program directory removed."
else
    echo "Error removing program directory."
fi

# Verify removal script link
if [ ! -f "$BIN_DIR/ncping" ]; then
    echo "Script link removed."
else 
    echo "Error removing script link."
fi

# Verify removal of man page
if [ ! -f "$MAN_DIR/ncping.1.gz" ]; then
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

# Remove cron jobs file
rm -f "$CRON_JOBS_FILE" || { echo "Error removing cron jobs file."; exit 1; }

# Verify removal of cron jobs file
if [ ! -f "$CRON_JOBS_FILE" ]; then
    echo "Cron jobs file removed."
else
    echo "Error removing cron jobs file."
fi
