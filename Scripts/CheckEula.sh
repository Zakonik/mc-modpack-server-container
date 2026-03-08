#!/bin/bash

set -euo pipefail

EULA_PATH=$SERVER_PATH/eula.txt

if [ -e "$EULA_PATH" ] && grep -qi true "$EULA_PATH" 2>/dev/null; then
	echo "✔ EULA already accepted!"
elif echo "$EULA" | grep -qi true; then
	echo "# EULA accepted on $(date)" >"$EULA_PATH"
	echo "eula=$EULA" >>"$EULA_PATH"
	echo "✔ EULA file created"
else
	echo "ERROR: Please accept the Minecraft EULA hosted at"
	echo "		 https://account.mojang.com/documents/minecraft_eula"
	exit 1
fi
