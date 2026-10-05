#!/bin/bash
# BatWiiCera - install the embedded Plaza channel on this Batocera machine
# Theme 0.1.14 / Plaza 0.1.3 | Author: Dan Lee | Licence: MIT (Plaza)
#
# Run once, as root, on the Batocera machine after installing the theme:
#   VPS:     bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <server-ip-or-host>
#   Railway: bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <proxy-host> <proxy-port> <https-presence-url>
#
# This forwards to the standard Plaza installer that sits next to it, which
# copies the client to /userdata/roms/plaza, adds the Plaza system, installs
# the presence hook and records the server address. Then restart
# EmulationStation to see the Plaza channel.
HERE="$(cd "$(dirname "$0")" && pwd)"
exec bash "$HERE/installer/install-batocera.sh" "$@"
