#!/bin/bash
# BatWiiCera Plaza - installer for Batocera
# Version 0.1.8 | Author: yiddifliddo | Licence: MIT
#
# Normally nobody runs this by hand: Plaza.sh (under Ports, or as the channel
# entry) calls it, the Plaza client's menu item calls it indirectly, and the
# theme's full-install zip lays the same files down directly. From a root
# shell it still works:
#
#   bash install-batocera.sh                      # public BatWiiCera server, built in
#   bash install-batocera.sh <game-host> [game-port] [presence]    # your own server
#   --no-restart as the last argument skips the EmulationStation restart
#
# It installs, from the _plaza folder this script lives in:
#   dist/BatWiiCera-Plaza.love        -> /userdata/roms/plaza/Plaza.love
#   runtime/love-*.AppImage           -> /userdata/roms/plaza/runtime/   (unpacked once)
#   installer/Plaza.sh                -> /userdata/roms/plaza/Plaza.sh   (the channel entry)
#                                     -> /userdata/roms/ports/Plaza.sh   (Ports entry)
#   installer/gamelist.xml, images/   -> /userdata/roms/plaza/
#   installer/es_systems_plaza.cfg    -> /userdata/system/configs/emulationstation/
#   hook/batwiicera-plaza-presence.sh -> /userdata/system/scripts/  (executable)
#   installer/plaza.svg               -> BatWiiCera theme logo folders that lack it
# writes the server address to the Plaza config, then restarts
# EmulationStation so the Plaza channel appears. Re-run it to repair.

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

PLAZA=/userdata/roms/plaza
PORTS=/userdata/roms/ports
ES_CFG_DIR=/userdata/system/configs/emulationstation
SCRIPTS=/userdata/system/scripts
SAVE_DIR="${PLAZA_SAVE_DIR:-/userdata/system/.local/share/love/batwiicera-plaza}"

mkdir -p "$PLAZA/runtime" "$PLAZA/images" "$PORTS" "$ES_CFG_DIR" "$SCRIPTS" "$SAVE_DIR"

cp "$LOVE_FILE" "$PLAZA/Plaza.love"
cp "$HERE/installer/gamelist.xml" "$PLAZA/gamelist.xml"
cp "$HERE"/installer/images/*.png "$PLAZA/images/" 2>/dev/null || true
cp "$HERE/installer/es_systems_plaza.cfg" "$ES_CFG_DIR/es_systems_plaza.cfg"
cp "$HERE/hook/batwiicera-plaza-presence.sh" "$SCRIPTS/batwiicera-plaza-presence.sh"
chmod +x "$SCRIPTS/batwiicera-plaza-presence.sh"
# The launcher may be the very script that called us; only copy when different.
for dest in "$PLAZA/Plaza.sh" "$PORTS/Plaza.sh"; do
  cmp -s "$HERE/installer/Plaza.sh" "$dest" || cp "$HERE/installer/Plaza.sh" "$dest"
  chmod +x "$dest"
done
# Old 0.1.3-0.1.5 layout listed the .love itself; nothing else to clean.

# The runtime: copy every bundled build, unpack the one for this machine now
# so the first launch is instant. Unpacking needs the runtime to run here.
ARCH="$(uname -m)"
for app in "$HERE"/runtime/love-*.AppImage; do
  [ -f "$app" ] || continue
  cmp -s "$app" "$PLAZA/runtime/$(basename "$app")" || cp "$app" "$PLAZA/runtime/"
  chmod +x "$PLAZA/runtime/$(basename "$app")"
done
APP="$(ls "$PLAZA"/runtime/love-*-"$ARCH".AppImage 2>/dev/null | head -n1)"
if [ -n "$APP" ]; then
  ( cd "$PLAZA/runtime" && rm -rf squashfs-root "$ARCH" && "$APP" --appimage-extract >/dev/null 2>&1 && mv squashfs-root "$ARCH" ) \
    && echo "  runtime: $(basename "$APP") unpacked for $ARCH" \
    || echo "  runtime: could not unpack $(basename "$APP") now; Plaza.sh will retry on launch"
else
  echo "  runtime: none bundled for $ARCH (x86_64 only so far); the Plaza will not start on this machine"
fi

# Server address for the client and the hook (keeps an existing profile intact).
printf '{"host":"%s","tcpPort":%s,"httpPort":%s,"presenceUrl":"%s"}\n' "$HOST" "$TCP" "$HTTP" "$PRESENCE_URL" > "$SAVE_DIR/config.json"

# Channel logo for any installed BatWiiCera theme version that lacks it.
for logos in /userdata/themes/BatWiiCera/_inc/systems/logos /userdata/themes/BatWiiCera*/_inc/systems/logos; do
  [ -d "$logos" ] && [ ! -f "$logos/plaza.svg" ] && cp "$HERE/installer/plaza.svg" "$logos/plaza.svg"
done

echo "Plaza installed."
echo "  channel: $PLAZA/Plaza.sh -> $PLAZA/Plaza.love   (also under Ports as Plaza)"
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
