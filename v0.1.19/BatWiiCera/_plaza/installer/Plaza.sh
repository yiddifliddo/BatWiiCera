#!/bin/bash
# BatWiiCera Plaza - the one script that installs, repairs and launches the Plaza
# Version 0.1.7 | Author: yiddifliddo | Licence: MIT
#
# The same file lives in two places:
#   /userdata/roms/plaza/Plaza.sh  - the Plaza channel's single entry (EmulationStation runs it)
#   /userdata/roms/ports/Plaza.sh  - "Plaza" under Ports: drop it there to install, or to launch
#
# First run with nothing installed: installs the channel from the BatWiiCera
# theme folder (client, bundled LÖVE runtime, system definition, presence
# hook, artwork, public server address) and restarts EmulationStation.
# Every run after that: starts the Plaza client with the bundled runtime,
# quietly repairing permissions first. Batocera has no LÖVE engine of its
# own, which is why the runtime travels with the Plaza.
#
# Needs the BatWiiCera theme (0.1.17 or newer) in /userdata/themes for the
# install step. x86_64 only for now (see runtime/README.md).

PLAZA=/userdata/roms/plaza
RUNTIME=$PLAZA/runtime
CLIENT=$PLAZA/Plaza.love
ES_CFG=/userdata/system/configs/emulationstation/es_systems_plaza.cfg
HOOK=/userdata/system/scripts/batwiicera-plaza-presence.sh
LOG=/userdata/system/logs/plaza.log
mkdir -p "$(dirname "$LOG")" 2>/dev/null
exec >>"$LOG" 2>&1
echo "== $(date '+%F %T') Plaza.sh ($0)"

# Newest theme copy that carries a Plaza (PLAZA_SRC overrides).
find_source() {
  if [ -n "$PLAZA_SRC" ] && [ -f "$PLAZA_SRC/dist/BatWiiCera-Plaza.love" ]; then echo "$PLAZA_SRC"; return; fi
  for d in $(ls -td /userdata/themes/*/_plaza 2>/dev/null); do
    if [ -f "$d/dist/BatWiiCera-Plaza.love" ] && [ -f "$d/installer/install-batocera.sh" ]; then echo "$d"; return; fi
  done
}

installed() {
  [ -f "$CLIENT" ] && [ -f "$ES_CFG" ] && [ -f "$HOOK" ] && [ -f "$PLAZA/Plaza.sh" ] \
    && ls "$RUNTIME"/love-*.AppImage >/dev/null 2>&1 && grep -q "Plaza.sh" "$ES_CFG"
}

if ! installed; then
  SRC="$(find_source)"
  if [ -z "$SRC" ]; then
    echo "Plaza is not installed and no BatWiiCera theme with a _plaza folder was found in /userdata/themes."
    echo "Install the theme (0.1.17 or newer) first, then start Plaza again."
    exit 1
  fi
  echo "Installing the Plaza channel from $SRC"
  bash "$SRC/installer/install-batocera.sh"     # public server built in; restarts EmulationStation itself
  exit $?
fi

# ---- launch -------------------------------------------------------------
chmod +x "$HOOK" "$PLAZA/Plaza.sh" 2>/dev/null
ARCH="$(uname -m)"
APP="$(ls "$RUNTIME"/love-*-"$ARCH".AppImage 2>/dev/null | head -n1)"

if [ -z "$APP" ]; then
  if command -v love >/dev/null 2>&1; then
    echo "No bundled runtime for $ARCH; using the system's love"
    cd "$PLAZA" && exec love "$CLIENT"
  fi
  echo "No Plaza runtime for this machine ($ARCH). Only x86_64 is bundled so far; see runtime/README.md."
  exit 1
fi

# Unpack once (no FUSE needed) and start.
if [ ! -x "$RUNTIME/$ARCH/AppRun" ]; then
  echo "Unpacking the runtime $(basename "$APP")"
  chmod +x "$APP"
  ( cd "$RUNTIME" && rm -rf squashfs-root "$ARCH" && "$APP" --appimage-extract >/dev/null && mv squashfs-root "$ARCH" )
fi
if [ ! -x "$RUNTIME/$ARCH/AppRun" ]; then
  echo "Could not unpack the runtime."
  exit 1
fi
cd "$PLAZA"
echo "Starting the Plaza client"
exec "$RUNTIME/$ARCH/AppRun" "$CLIENT"
