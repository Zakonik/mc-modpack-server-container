#!/bin/bash

set -euo pipefail

INSTALL_MARKER=$SERVER_PATH/.modpack_installed

STARTER_PATH=$SERVER_PATH/$START_SCRIPT

echo "Checking EULA"
$SCRIPTS_PATH/CheckEula.sh

if [ -n "$SERVER_PACK_URL" ] && [ ! -f "$INSTALL_MARKER" ]; then

    echo "Downloading server files from $SERVER_PACK_URL"

    curl --fail -L "$SERVER_PACK_URL" -o server.zip
    
    echo "Unziping and clearing zip server files"
    unzip -q server.zip &&
        rm server.zip

    echo "$SERVER_PACK_URL" >"$INSTALL_MARKER"

    echo "Server unpacked. Changing variables.txt if exist"
    $SCRIPTS_PATH/ChangeVariables.sh

elif [ -z "$SERVER_PACK_URL" ] && [ ! -f "$INSTALL_MARKER" ]; then

    echo "Server not installed already. Please provide server pack URL"
    exit 1

fi

if [ ! -f "$STARTER_PATH" ]; then
    echo "ERROR: Start script '$STARTER_PATH' not found in server pack."
    exit 1
fi
chmod +x "$STARTER_PATH"
exec "$STARTER_PATH"
