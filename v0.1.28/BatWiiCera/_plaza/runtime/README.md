# Plaza runtime

Batocera does not ship the LÖVE engine, so the Plaza brings its own: the
official self-contained Linux build published by the LÖVE project.

| File | Source | Licence |
| --- | --- | --- |
| `love-11.5-x86_64.AppImage` | https://github.com/love2d/love/releases/tag/11.5 | zlib (see `LICENSE-love.txt`) |

SHA-256: `65a673406431eff7167a15a032bf7a2e4ba50108e091eb7b176465831f9b5e00`

The installer copies it to `/userdata/roms/plaza/runtime/` and unpacks it
once (`--appimage-extract`, no FUSE needed); `Plaza.sh` then starts the
client with `runtime/x86_64/AppRun Plaza.love`. Only x86_64 for now. For
another architecture drop a matching `love-*-<arch>.AppImage` in this folder
and the launcher picks it up by `uname -m`.
