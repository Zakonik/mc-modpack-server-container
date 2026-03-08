#!/bin/bash

set -euo pipefail

PROPERTIES_PATH=$SERVER_PATH/server.properties

: "${MC_MOTD:=Minecraft Server}"
: "${MC_MAX_PLAYERS:=20}"
: "${MC_DIFFICULTY:=easy}"
: "${MC_GAMEMODE:=survival}"
: "${MC_HARDCORE:=false}"
: "${MC_PVP:=true}"
: "${MC_LEVEL_SEED:=}"
: "${MC_LEVEL_NAME:=world}"
: "${MC_LEVEL_TYPE:=}"
: "${MC_VIEW_DISTANCE:=10}"
: "${MC_SPAWN_PROTECTION:=16}"
: "${MC_ONLINE_MODE:=true}"
: "${MC_WHITELIST:=false}"
: "${MC_ENABLE_RCON:=false}"
: "${MC_RCON_PASSWORD:=}"


if echo "${MC_ENABLE_RCON}" | grep -qi true && [ -z "${MC_RCON_PASSWORD}" ]; then
    echo "ERROR: MC_RCON_PASSWORD is required when MC_ENABLE_RCON=true" >&2
    exit 1
fi

cat > "${PROPERTIES_PATH}" <<EOF
motd=${MC_MOTD}
max-players=${MC_MAX_PLAYERS}
difficulty=${MC_DIFFICULTY}
gamemode=${MC_GAMEMODE}
hardcore=${MC_HARDCORE}
pvp=${MC_PVP}
level-seed=${MC_LEVEL_SEED}
level-name=${MC_LEVEL_NAME}
level-type=${MC_LEVEL_TYPE}
view-distance=${MC_VIEW_DISTANCE}
spawn-protection=${MC_SPAWN_PROTECTION}
online-mode=${MC_ONLINE_MODE}
white-list=${MC_WHITELIST}
enable-rcon=${MC_ENABLE_RCON}
rcon.password=${MC_RCON_PASSWORD}
rcon.port=25575
EOF

echo "✔ server.properties generated"
