#!/bin/bash

SCRIPT_NAME="ncping"
SCRIPT_NAME_ger="ncping_ger"
INSTALL_DIR="/usr/share/$SCRIPT_NAME"
BIN_DIR="/usr/bin"
MAN_DIR="/usr/local/man/man1"
CONFIG_FILE="config.txt"
MAIN_SCRIPT="ncping.sh"
MAN_PAGE="ncping.1"
GER_MAN_PAGE="ncping_ger.1"

if [ -f "src/$MAIN_SCRIPT" ] && [ -f "src/$MAN_PAGE" ] && [ -f "src/$GER_MAN_PAGE" ]; then

    # Erstellt Ordner
    mkdir -p "$INSTALL_DIR" || { echo "Error creating script directory."; exit 1; }
    cp "src/$MAIN_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME.sh" || { echo "Error copying script."; exit 1; }

    # Erstellt Skript link
    ln -s "$INSTALL_DIR/$SCRIPT_NAME.sh" "$BIN_DIR/$SCRIPT_NAME" || { echo "Error creating symbolic link."; exit 1; }
    
    # Erstellt Log, Host und Config 
    touch "$INSTALL_DIR/log.txt" "$INSTALL_DIR/hosts" || { echo "Error creating assets."; exit 1; }
    cp "src/$CONFIG_FILE" "$INSTALL_DIR/$CONFIG_FILE" || { echo "Error copying configuration file."; exit 1; }

    # Erstellt die Englische Man Page
    cp "src/$MAN_PAGE" "$MAN_DIR/$SCRIPT_NAME.1" || { echo "Error copying man page file."; exit 1; }
    gzip "$MAN_DIR/$SCRIPT_NAME.1" || { echo "Error compressing man page."; exit 1; }

    # Erstellt die Deutsche Man Page
    cp "src/$GER_MAN_PAGE" "$MAN_DIR/$SCRIPT_NAME_ger.1" || { echo "Error copying German man page file."; exit 1; }
    gzip "$MAN_DIR/$SCRIPT_NAME_ger.1" || { echo "Error compressing German man page."; exit 1; }

    mandb || { echo "Error updating man pages."; exit 1; }

    if [ -f "$INSTALL_DIR/$SCRIPT_NAME.sh" ] && [ -f "$BIN_DIR/$SCRIPT_NAME" ]; then

        # Setzt Berechtigungen
        chown root:users "$BIN_DIR/$SCRIPT_NAME" "$MAN_DIR/$SCRIPT_NAME.1.gz" "$MAN_DIR/$SCRIPT_NAME_ger.1.gz" || { echo "Error setting ownership."; exit 1; }
        chmod 755 "$BIN_DIR/$SCRIPT_NAME" || { echo "Error setting execution permissions."; exit 1; }
        chmod -R 777 "$INSTALL_DIR" || { echo "Error setting permissions for script directory."; exit 1; }

        echo "Script '$SCRIPT_NAME' has been successfully installed."
    else
        echo "Error installing the script."
    fi
else
    echo "Error installing the script (main script or man page file missing)."
fi
