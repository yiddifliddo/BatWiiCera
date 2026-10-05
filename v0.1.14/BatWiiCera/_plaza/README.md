# Plaza, embedded in the BatWiiCera theme

This folder carries the BatWiiCera Plaza (version 0.1.3), the online room
where players running the theme meet as avatars, see what everyone is
playing, run around, hop, slap and kick a ball. Full details, controls and
privacy notes are in `PLAZA-README.md`.

A theme cannot start programs, so the Plaza is a channel that EmulationStation
launches like a game. Setting it up is one command on the Batocera machine
and one small server on a VPS.

## 1. Server (once)

Either a VPS (`SERVER-SETUP.md`: Node.js service, ports 7777 and 7778 open)
or Railway (`RAILWAY-SETUP.md`: root directory on the server folder, public
domain for presence, TCP Proxy on 7777). The server package is
`server.tar.gz`; Railway builds straight from the repository.

## 2. This machine (once per Batocera box) - no terminal needed

1. Copy `dist/BatWiiCera-Plaza.love` from this folder to the machine's
   network share, into `share\roms\love\`.
2. On the TV: Main Menu, Game Settings, Update Gamelists (or restart
   EmulationStation), open the **LÖVE** system and start **BatWiiCera-Plaza**.
3. Choose **Install Plaza channel on this Batocera** and wait for "Done".
4. Choose **Server address** and type the game address (a VPS IP, or for
   Railway the TCP proxy `host:port`). The presence address arrives from the
   server by itself.
5. Quit, restart EmulationStation. A **Plaza** channel appears in the console
   grid. Open it, **Edit avatar**, then **Enter the plaza**.

Prefer a terminal? As root over SSH:

```
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <server-ip-or-host>                          # VPS
bash /userdata/themes/BatWiiCera/_plaza/install-plaza.sh <proxy-host> <proxy-port> https://<domain>  # Railway
```

## Contents

| File | Purpose |
| --- | --- |
| `install-plaza.sh` | one-command installer (wrapper) |
| `installer/install-batocera.sh` | the installer proper |
| `installer/es_systems_plaza.cfg` | adds the Plaza system to EmulationStation |
| `installer/plaza.svg` | channel logo (also bundled in the theme's logo set) |
| `hook/batwiicera-plaza-presence.sh` | reports the game you start to the server |
| `dist/BatWiiCera-Plaza.love` | the Plaza client for the LÖVE engine |
| `server.tar.gz` | the room server (Node.js) |
| `SERVER-SETUP.md` | VPS walkthrough |
| `RAILWAY-SETUP.md` | Railway walkthrough |
| `PLAZA-README.md`, `LICENSE` | Plaza documentation and MIT licence |

The Plaza is MIT licensed; the theme is CC BY-NC-SA 4.0.
