#!/bin/bash
# BatWiiCera - build the distribution layout for Batocera's theme downloader
# Author: Dan Lee
#
# Batocera's Themes Downloader installs a theme by fetching a GitHub
# repository's default branch and expects theme.xml at the repository root.
# This repository keeps every version in its own folder, so the published
# copy lives in a separate public repository that this script fills:
#
#   tools/make-dist.sh <version> <path-to-distribution-repo-checkout>
#   e.g. tools/make-dist.sh 0.1.11 ../BatWiiCera-theme
#
# It mirrors v<version>/BatWiiCera/* to the root of that checkout (deleting
# files that no longer exist), adds a preview image for the downloader and a
# short README. Commit and push the distribution repository afterwards.
set -e
VER="$1"; DEST="$2"
[ -n "$VER" ] && [ -n "$DEST" ] || { echo "usage: $0 <version> <distribution-repo-path>"; exit 1; }
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$HERE/v$VER/BatWiiCera"
[ -d "$SRC" ] || { echo "no such version folder: $SRC"; exit 1; }
mkdir -p "$DEST"
command -v rsync >/dev/null 2>&1 && rsync -a --delete --exclude .git "$SRC/" "$DEST/" || { find "$DEST" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +; cp -r "$SRC/." "$DEST/"; }
# preview image: the downloader shows one screenshot per theme
PREVIEW="$HERE/v$VER/previews/mockup-console-grid.png"
[ -f "$PREVIEW" ] && cp "$PREVIEW" "$DEST/preview.png"
cat > "$DEST/README.md" <<EOF
# BatWiiCera (distribution copy)

Version $VER of the BatWiiCera theme for Batocera, laid out for the Themes
Downloader: theme.xml is at the root of this repository.

Source, version history and change control live in
https://github.com/yiddifliddo/BatWiiCera (folder v$VER).

Author: Dan Lee. Licence: CC BY-NC-SA 4.0 (see LICENSE).
EOF
echo "distribution layout for $VER written to $DEST"
ls "$DEST" | head
