#!/bin/bash
# BatWiiCera Plaza - build the client package
# Version 0.1.1 | Author: Dan Lee | Licence: MIT
#
# Produces dist/BatWiiCera-Plaza.love (a zip with main.lua at its root) and
# dist/BatWiiCera-Plaza-server.tar.gz. Run from anywhere.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/client"
mkdir -p "$HERE/dist"
rm -f "$HERE/dist/BatWiiCera-Plaza.love"
zip -q -r -X "$HERE/dist/BatWiiCera-Plaza.love" main.lua conf.lua src test -x '*.DS_Store'
cd "$HERE"
tar --exclude=node_modules -czf "$HERE/dist/BatWiiCera-Plaza-server.tar.gz" server
echo "built:"
ls -la "$HERE/dist"
