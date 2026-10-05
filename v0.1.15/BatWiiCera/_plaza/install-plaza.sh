#!/bin/bash
# BatWiiCera - install the embedded Plaza channel on this Batocera machine
# Theme 0.1.15 / Plaza 0.1.4 | Author: yiddifliddo | Licence: MIT (Plaza)
#
# Usually not needed: the full-install zip, the Ports entry (installer/Plaza.sh)
# and the Plaza client's own menu all install the channel without a terminal.
# From a root shell on the Batocera machine it still works:
#   bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh                      # public server, built in
#   bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <host> [port] [presence]   # your own server
#
# This forwards to the standard Plaza installer that sits next to it, which
# copies the client to /userdata/roms/plaza, adds the Plaza system, installs
# the presence hook and the Ports entry, records the server address and
# restarts EmulationStation so the Plaza channel appears.
HERE="$(cd "$(dirname "$0")" && pwd)"
exec bash "$HERE/installer/install-batocera.sh" "$@"
