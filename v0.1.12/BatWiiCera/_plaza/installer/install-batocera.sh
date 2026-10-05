#!/bin/bash
# BatWiiCera Plaza - installer for Batocera
# Version 0.1.1 | Author: Dan Lee | Licence: MIT
#
# Run this ON the Batocera machine (SSH in as root, or from a terminal):
#
#   bash install-batocera.sh <server-host> [tcp-port] [http-port]
#
# It installs, from the folder this script lives in:
#   dist/BatWiiCera-Plaza.love        -> /userdata/roms/plaza/
#   installer/es_systems_plaza.cfg    -> /userdata/system/configs/emulationstation/
#   hook/batwiicera-plaza-presence.sh -> /userdata/system/scripts/
#   installer/plaza.svg               -> the BatWiiCera theme logo folders, if the theme is installed
# and writes the server address to the Plaza config so the client and the
# presence hook know where to connect. Re-run it to update any part.

set -e

HOST="$1"; TCP="${2:-7777}"; HTTP="${3:-7778}"
if [ -z "$HOST" ]; then
  echo "usage: $0 <server-host> [tcp-port] [http-port]"; exit 1
fi

HERE="$(cd "$(dirname "$0")/.." && pwd)"
LOVE_FILE="$HERE/dist/BatWiiCera-Plaza.love"
[ -f "$LOVE_FILE" ] || { echo "missing $LOVE_FILE (run build.sh first)"; exit 1; }

ROMS=/userdata/roms/plaza
ES_CFG_DIR=/userdata/system/configs/emulationstation
SCRIPTS=/userdata/system/scripts
SAVE_DIR="${PLAZA_SAVE_DIR:-/userdata/system/.local/share/love/batwiicera-plaza}"

mkdir -p "$ROMS" "$ES_CFG_DIR" "$SCRIPTS" "$SAVE_DIR"

cp "$LOVE_FILE" "$ROMS/Plaza.love"
cp "$HERE/installer/es_systems_plaza.cfg" "$ES_CFG_DIR/es_systems_plaza.cfg"
cp "$HERE/hook/batwiicera-plaza-presence.sh" "$SCRIPTS/batwiicera-plaza-presence.sh"
chmod +x "$SCRIPTS/batwiicera-plaza-presence.sh"

# Server address for the client and the hook (keeps an existing profile intact).
printf '{"host":"%s","tcpPort":%s,"httpPort":%s}\n' "$HOST" "$TCP" "$HTTP" > "$SAVE_DIR/config.json"

# Channel logo for any installed BatWiiCera theme version.
for logos in /userdata/themes/BatWiiCera/_inc/systems/logos /userdata/themes/BatWiiCera*/_inc/systems/logos; do
  [ -d "$logos" ] && cp "$HERE/installer/plaza.svg" "$logos/plaza.svg"
done

# Friendly name in the game list.
cat > "$ROMS/gamelist.xml" <<'EOF'
<?xml version="1.0"?>
<gameList>
  <game>
    <path>./Plaza.love</path>
    <name>Enter the Plaza</name>
    <desc>Meet everyone running BatWiiCera. Walk around, jump, slap, kick the ball and see what people are playing.</desc>
    <developer>Dan Lee</developer>
    <genre>Social</genre>
  </game>
</gameList>
EOF

echo "Plaza installed."
echo "  client : $ROMS/Plaza.love"
echo "  server : $HOST  (game $TCP, presence $HTTP)"
echo "  hook   : $SCRIPTS/batwiicera-plaza-presence.sh"
echo "Restart EmulationStation (Main Menu > Quit > Restart) to see the Plaza channel."
