#!/bin/bash
# BatWiiCera Plaza - one file for Batocera's Ports list: installs, repairs, launches
# Version 0.1.5 | Author: yiddifliddo | Licence: MIT
#
# Drop this file in share\roms\ports (that is /userdata/roms/ports). It shows
# up under Ports as "Plaza". Nothing has to be typed anywhere:
#
#   first launch   - installs the Plaza channel from the BatWiiCera theme
#                    folder (client, EmulationStation system, presence hook,
#                    channel logo, public server address) and restarts
#                    EmulationStation. The Plaza channel is then on the
#                    console grid.
#   later launches - open the Plaza directly, and quietly repair anything
#                    missing first.
#
# It needs the BatWiiCera theme (0.1.15 or newer) in /userdata/themes, because
# the Plaza client ships inside the theme's _plaza folder.

ROMS=/userdata/roms/plaza
ES_CFG=/userdata/system/configs/emulationstation/es_systems_plaza.cfg
HOOK=/userdata/system/scripts/batwiicera-plaza-presence.sh
LOG=/userdata/system/logs/plaza-ports.log
mkdir -p "$(dirname "$LOG")" 2>/dev/null
exec >>"$LOG" 2>&1
echo "== $(date '+%F %T') Plaza.sh start"

# Newest theme copy that carries a Plaza client (PLAZA_SRC overrides).
find_source() {
  [ -n "$PLAZA_SRC" ] && [ -f "$PLAZA_SRC/dist/BatWiiCera-Plaza.love" ] && { echo "$PLAZA_SRC"; return; }
  for d in $(ls -td /userdata/themes/*/_plaza 2>/dev/null); do
    if [ -f "$d/dist/BatWiiCera-Plaza.love" ] && [ -f "$d/installer/install-batocera.sh" ]; then echo "$d"; return; fi
  done
}

installed() { [ -f "$ROMS/Plaza.love" ] && [ -f "$ES_CFG" ] && [ -f "$HOOK" ]; }

if ! installed; then
  SRC="$(find_source)"
  if [ -z "$SRC" ]; then
    echo "No BatWiiCera theme with a _plaza folder found in /userdata/themes. Install the theme first."
    exit 1
  fi
  echo "Installing the Plaza channel from $SRC"
  bash "$SRC/installer/install-batocera.sh"        # built-in public server; restarts EmulationStation
  exit $?
fi

# Already installed: restore the hook's executable bit (lost when copied in
# over a Windows share), then launch the Plaza like the channel tile does.
chmod +x "$HOOK" 2>/dev/null
LAUNCHER="$(ls /usr/lib/python3*/site-packages/configgen/emulatorlauncher.py 2>/dev/null | head -n1)"
if [ -n "$LAUNCHER" ]; then
  exec python "$LAUNCHER" -system love -rom "$ROMS/Plaza.love" -systemname plaza
elif command -v love >/dev/null 2>&1; then
  exec love "$ROMS/Plaza.love"
else
  echo "Neither emulatorlauncher nor love found; cannot start the Plaza."
  exit 1
fi
