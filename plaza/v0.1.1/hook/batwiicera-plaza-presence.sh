#!/bin/bash
# BatWiiCera Plaza - presence hook for Batocera
# Version 0.1.1 | Author: Dan Lee | Licence: MIT
#
# Batocera runs every executable in /userdata/system/scripts/ when a game
# starts or stops, passing:  <gameStart|gameStop> <system> <emulator> <core> <rom>
# This script tells the Plaza server what you are playing so the label above
# your avatar is live. It reads your token from the Plaza profile and the
# server address from the Plaza config, both written by the Plaza client.
#
# Nothing is sent if the Plaza has never been run, if "Show my game" is off,
# or if no server is configured.

EVENT="$1"; SYSTEM="$2"; ROM="$5"

SAVE_DIR="${PLAZA_SAVE_DIR:-$HOME/.local/share/love/batwiicera-plaza}"
PROFILE="$SAVE_DIR/profile.json"
CONFIG="$SAVE_DIR/config.json"

[ -f "$PROFILE" ] && [ -f "$CONFIG" ] || exit 0
command -v curl >/dev/null 2>&1 || exit 0

json_field() { # json_field <file> <key>  (flat string/number/bool values only)
  sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([^\",}]*\)\"\{0,1\}.*/\1/p" "$1" | head -n1
}

TOKEN="$(json_field "$PROFILE" token)"
SHARE="$(json_field "$PROFILE" share)"
HOST="$(json_field "$CONFIG" host)"
PORT="$(json_field "$CONFIG" httpPort)"
[ -n "$TOKEN" ] && [ -n "$HOST" ] || exit 0
[ "$SHARE" = "false" ] && exit 0
PORT="${PORT:-7778}"

if [ "$EVENT" = "gameStart" ]; then
  # Game name from the ROM file name: strip extension and bracketed tags.
  NAME="$(basename "$ROM")"
  NAME="${NAME%.*}"
  NAME="$(printf '%s' "$NAME" | sed -e 's/ *([^)]*)//g' -e 's/ *\[[^]]*\]//g' -e 's/_/ /g' -e 's/  */ /g' -e 's/^ *//;s/ *$//')"
  [ -n "$SYSTEM" ] && NAME="$NAME ($SYSTEM)"
  NAME="${NAME:0:40}"
  BODY="$(printf '{"token":"%s","event":"start","game":"%s"}' "$TOKEN" "$(printf '%s' "$NAME" | sed 's/"/\\"/g')")"
elif [ "$EVENT" = "gameStop" ]; then
  BODY="$(printf '{"token":"%s","event":"stop"}' "$TOKEN")"
else
  exit 0
fi

# Fire and forget; never hold up the game launch.
( curl -s -m 4 -X POST -H 'Content-Type: application/json' --data "$BODY" "http://$HOST:$PORT/presence" >/dev/null 2>&1 & ) &
exit 0
