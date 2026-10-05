#!/bin/bash
# BatWiiCera Plaza - installer for Batocera
# Version 0.1.5 | Author: yiddifliddo | Licence: MIT
#
# Normally nobody runs this by hand: the Plaza client (menu item "Install
# Plaza channel") and the Ports entry (roms/ports/Plaza.sh) call it, and the
# theme's full-install zip lays the same files down directly. It still works
# from a root shell on the Batocera machine:
#
#   bash install-batocera.sh                      # public BatWiiCera server, built in
#   bash install-batocera.sh <game-host> [game-port] [presence]    # your own server
#
#   <game-host>  host of the raw game connection (VPS IP, or a TCP proxy host)
#   [game-port]  default 7777 (Railway: the proxy port it shows you)
#   [presence]   a port number (VPS, default 7778) or a full URL (Railway domain)
#   --no-restart as the last argument skips the EmulationStation restart
#
# It installs, from the folder this script lives in:
#   dist/BatWiiCera-Plaza.love        -> /userdata/roms/plaza/Plaza.love
#   installer/es_systems_plaza.cfg    -> /userdata/system/configs/emulationstation/
#   hook/batwiicera-plaza-presence.sh -> /userdata/system/scripts/  (executable)
#   installer/Plaza.sh                -> /userdata/roms/ports/      (Ports entry)
#   installer/plaza.svg               -> the BatWiiCera theme logo folders, if needed
# writes the server address to the Plaza config, then restarts
# EmulationStation so the Plaza channel appears. Re-run it to repair any part.

set -e

PUBLIC_HOST="maglev.proxy.rlwy.net"
PUBLIC_TCP=28071
PUBLIC_PRESENCE_URL="https://batwiicera-production.up.railway.app"

RESTART=yes
ARGS=()
for a in "$@"; do
  case "$a" in
    --no-restart) RESTART=no ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) ARGS+=("$a") ;;
  esac
done

if [ "${#ARGS[@]}" -eq 0 ]; then
  HOST="$PUBLIC_HOST"; TCP="$PUBLIC_TCP"; PRES="$PUBLIC_PRESENCE_URL"
else
  HOST="${ARGS[0]}"; TCP="${ARGS[1]:-7777}"; PRES="${ARGS[2]:-7778}"
fi
case "$PRES" in
  http://*|https://*) HTTP=7778; PRESENCE_URL="${PRES%/}" ;;
  *) HTTP="$PRES"; PRESENCE_URL="" ;;
esac

HERE="$(cd "$(dirname "$0")/.." && pwd)"
LOVE_FILE="$HERE/dist/BatWiiCera-Plaza.love"
[ -f "$LOVE_FILE" ] || { echo "missing $LOVE_FILE (run build.sh first)"; exit 1; }

ROMS=/userdata/roms/plaza
PORTS=/userdata/roms/ports
ES_CFG_DIR=/userdata/system/configs/emulationstation
SCRIPTS=/userdata/system/scripts
SAVE_DIR="${PLAZA_SAVE_DIR:-/userdata/system/.local/share/love/batwiicera-plaza}"

mkdir -p "$ROMS" "$PORTS" "$ES_CFG_DIR" "$SCRIPTS" "$SAVE_DIR"

cp "$LOVE_FILE" "$ROMS/Plaza.love"
cp "$HERE/installer/gamelist.xml" "$ROMS/gamelist.xml"
cp "$HERE/installer/es_systems_plaza.cfg" "$ES_CFG_DIR/es_systems_plaza.cfg"
cp "$HERE/hook/batwiicera-plaza-presence.sh" "$SCRIPTS/batwiicera-plaza-presence.sh"
chmod +x "$SCRIPTS/batwiicera-plaza-presence.sh"
# The Ports entry may be the very script that called us; only copy when different.
if ! cmp -s "$HERE/installer/Plaza.sh" "$PORTS/Plaza.sh"; then
  cp "$HERE/installer/Plaza.sh" "$PORTS/Plaza.sh"
fi
chmod +x "$PORTS/Plaza.sh"

# Server address for the client and the hook (keeps an existing profile intact).
printf '{"host":"%s","tcpPort":%s,"httpPort":%s,"presenceUrl":"%s"}\n' "$HOST" "$TCP" "$HTTP" "$PRESENCE_URL" > "$SAVE_DIR/config.json"

# Channel logo for any installed BatWiiCera theme version that lacks it.
for logos in /userdata/themes/BatWiiCera/_inc/systems/logos /userdata/themes/BatWiiCera*/_inc/systems/logos; do
  [ -d "$logos" ] && [ ! -f "$logos/plaza.svg" ] && cp "$HERE/installer/plaza.svg" "$logos/plaza.svg"
done

echo "Plaza installed."
echo "  client : $ROMS/Plaza.love   (also under Ports as Plaza)"
echo "  server : $HOST:$TCP (game), presence ${PRESENCE_URL:-http://$HOST:$HTTP}"
echo "  hook   : $SCRIPTS/batwiicera-plaza-presence.sh"

if [ "$RESTART" = yes ] && command -v batocera-es-swissknife >/dev/null 2>&1; then
  echo "Restarting EmulationStation in a few seconds so the Plaza channel appears."
  if command -v setsid >/dev/null 2>&1; then
    nohup setsid bash -c 'sleep 3; batocera-es-swissknife --restart' >/dev/null 2>&1 </dev/null &
  else
    nohup bash -c 'sleep 3; batocera-es-swissknife --restart' >/dev/null 2>&1 </dev/null &
  fi
else
  echo "Restart EmulationStation (Main Menu > Quit > Restart) to see the Plaza channel."
fi
