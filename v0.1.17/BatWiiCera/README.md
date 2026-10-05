# BatWiiCera - version 0.1.17

**Author:** yiddifliddo (personal project)
**Target:** Batocera EmulationStation (theme format version 7)
**Licence:** Creative Commons BY-NC-SA 4.0 (see `LICENSE`)

BatWiiCera recreates the feel of a classic motion-controlled console's home menu:
a grid of rounded "channel" tiles on a softly striped light grey background, a
curved bottom bar with a big clock, and a channel-preview style game screen with
a live video preview.

## Navigation flow

1. **Console grid** - every system is a channel tile showing its logo
   washed-out; the highlighted tile's logo comes up to full strength.
   Move the highlight with the d-pad or stick. The selected console's name and
   game count appear under the clock in the bottom bar.
2. **Game list with preview** (default view) - a white rounded panel on the left
   lists the games; the big screen on the right plays the scraped video, or shows
   the screenshot when no video exists, or a "No preview available" card when
   neither exists. Game logo, rating, year, players, genre and a scrolling
   description sit in the strip below the screen. A gold trophy marks games
   with achievements and a compact disc marks games that have save states
   (click it to open the save manager; on a controller use the game's options
   menu). Press the confirm button to start the game.
3. **Game grid** (optional view) - games as channel tiles. The selected tile
   starts playing its video after a short delay. Switch with the view options
   from the game list menu.

## Layout previews

Static layout mock-ups built from the theme's own assets (not screenshots from
a device) are in `../previews/`:

* `mockup-console-grid.png` - console channel grid with the pointer on the selected tile
* `mockup-game-list.png` - game list with preview screen

## Theme options

Open *Main Menu > UI Settings > Theme Configuration*.

| Option | Choices | Notes |
| --- | --- | --- |
| Colour set | Classic grey, Sky blue, Dark grey | Background, bar, panels, menus, text and highlight colours. Dark grey keeps the console tiles light so logos stay readable |
| Aspect ratio | 16:9 widescreen, 4:3 standard | 4:3 and 5:4 screens are detected automatically |
| Game grid tile image | Screenshot, Box art, Logo, Mix image | Picture used on tiles in the game grid view |
| Background music | Menu theme, Quiet bass loop, All tracks in _music (shuffle), Off | Menu theme by default. Two tracks are bundled; the shuffle choice also plays anything you add to the theme's `_music` folder |

## Bottom bar buttons

The two round buttons respond to a mouse click or a touchscreen tap
(EmulationStation does not route controller input to on-screen buttons):

| Button | Console grid | Game list and game grid |
| --- | --- | --- |
| House (left) | Opens game search | Goes back to the console grid |
| Envelope (right) | Opens the Netplay lobby | Opens the options for the selected game |

## Plaza channel

The theme ships the **BatWiiCera Plaza**, the companion online room where
players meet as avatars, see what everyone is playing, run around, hop, slap
and kick a ball. It lives in the theme's `_plaza/` folder, the public server is
built in, and nothing has to be typed. Three ways to add the channel:

* **Full-install zip:** extract `BatWiiCera-full-v0.1.15.zip` onto the
  Batocera share and reboot. Theme and Plaza channel are both in place.
* **One file under Ports:** copy `_plaza/installer/Plaza.sh` to
  `share\roms\ports`, start **Plaza** from the Ports list once. It installs
  the channel from this folder and restarts EmulationStation by itself.
* **From the client:** start `_plaza/dist/BatWiiCera-Plaza.love` from the
  LÖVE system and choose **Install Plaza channel on this Batocera**.

A **Plaza** channel then appears in the console grid. Batocera has no LÖVE
engine, so the Plaza carries its own runtime (x86_64 PCs for now; ARM boxes
get a message in `system/logs/plaza.log`). Running your own server
is optional (`_plaza/SERVER-SETUP.md`, `_plaza/RAILWAY-SETUP.md`). Full Plaza
notes and controls: `_plaza/PLAZA-README.md`.

## RetroAchievements

The theme integrates RetroAchievements the same way the popular community
themes do:

* **Bottom bar, left of the clock** - when RetroAchievements is enabled in
  Batocera (*Main Menu > Game Settings > RetroAchievements settings*) your
  avatar and user name are shown; the avatar is fetched from
  retroachievements.org, so it needs an internet connection. When it is not
  enabled a grey trophy and the label "RetroAchievements" are shown instead.
  Clicking either (mouse or touch) opens EmulationStation's RetroAchievements
  panel.
* **Game list with preview** - games that have achievements show a gold
  trophy beside their name in the info strip.

## Save states

When Batocera has save states for the selected game, a compact disc icon
appears in the bottom right of the info strip under the preview. Clicking or
tapping it opens EmulationStation's save-state manager; with a controller open
the game's options menu (envelope button or the select action) and choose the
save states entry.
* **Game grid** - tiles of games with achievements carry a gold trophy badge in
  the top right corner.
* EmulationStation's own trophy marker next to names in the list can be turned
  on per system with *Show RetroAchievements icon* in the game list options.

The clock in the bottom bar is EmulationStation's own clock. If it is not
visible, enable *Main Menu > UI Settings > Show clock*.

## Installation

**Easiest:** extract `BatWiiCera-full-v0.1.15.zip` onto the Batocera network
share (`\\BATOCERA\share`) so its `themes`, `roms` and `system` folders merge
with the existing ones, then reboot. That installs the theme and the Plaza
channel together. Select the theme under *Main Menu > UI Settings > Theme set*.

**Theme only:**

1. Copy the whole `BatWiiCera` folder (this folder) to `/userdata/themes/` on
   your Batocera device, or to `\\BATOCERA\share\themes\` over the network.
   (`BatWiiCera-v0.1.15.zip` holds exactly this folder.)
2. In EmulationStation open *Main Menu > UI Settings > Theme set* and choose
   **BatWiiCera**.
3. Music: two tracks are bundled and the menu theme plays by default. Pick
   the other, a shuffle of everything, or Off under Theme Configuration. To
   add tracks or change the volume, see `_music/README.md`.
4. Plaza channel: see the section above (one file under Ports, or the client's
   menu).

To preview every console tile without ROMs, turn on
*Main Menu > Game Collection Settings > Show empty systems*.

## Requirements

* A current Batocera release. The console grid relies on EmulationStation
  accepting an `imagegrid` element in the system view. On older builds that do
  not support it, EmulationStation falls back to its default carousel while the
  game views still work.
* Scraped media (video, screenshot, marquee) for the previews.

## Folder layout

```
BatWiiCera/
  theme.xml              main theme (all views, options, variables)
  README.md              this file
  LICENSE                licence and third-party credits
  _inc/
    colors/              colour sets (classic.xml, sky.xml, dark.xml)
    fonts/               Varela Round, Nunito Regular, Nunito Bold
    images/              backgrounds, tiles, bar, buttons, icons, placeholders
    layouts/4-3.xml      overrides for 4:3 screens
    music.xml            background music include: shuffle the _music folder
    music-menu.xml       background music include: menu theme only
    music-loop.xml       background music include: bass loop only
    systems/logos/       coloured logos per system (Carbon, with Art Book Next fallbacks)
  _music/                bundled menu theme and bass loop; add your own tracks here
  _plaza/                the Plaza channel: client, runtime, launcher, hook, installer, server package, guides
```

## Changes in this version (0.1.17)

* **Plaza channel now starts.** The first device test showed it closing at
  once: Batocera does not ship the LÖVE engine the Plaza runs on. The
  embedded Plaza is updated to **0.1.6**, which bundles the official LÖVE
  11.5 Linux build (`_plaza/runtime/`, 5 MB, zlib licence) and starts the
  client through one launcher script, `_plaza/installer/Plaza.sh`, used both
  as the channel's entry and under Ports. x86_64 only for now.
* **Plaza game screen filled in.** The channel's entry is "Plaza" with a
  preview image, logo marquee (also used by Batocera's launch splash),
  developer, release date, players and genre instead of placeholders.
* Full-install zip gains `roms/plaza/runtime/`, `roms/plaza/images/` and the
  new `roms/plaza/Plaza.sh`; the system file now lists `.sh` entries.
* `LICENSE` lists the bundled LÖVE runtime. Version bumped to 0.1.17 in
  `theme.xml`, `README.md` and `LICENSE`. No layout changes.

## Changes in version 0.1.16

* **Second music track and a choice.** `_music/batwiicera-menu-theme.ogg`,
  a menu theme supplied by the author (not a Nintendo recording), joins the
  quiet bass loop. The **Background music** option now offers *Menu theme*
  (default, on repeat), *Quiet bass loop*, *All tracks in _music (shuffle)*
  and *Off*. New includes `_inc/music-menu.xml` and `_inc/music-loop.xml`
  use EmulationStation's single-track `bgsound` element, which loops; the
  shuffle keeps the `directory` element. The new track was lowered by 12 dB
  to match the loop's level.
* Players who had the old *On* setting fall back to the default, *Menu
  theme*, until they choose otherwise.
* Version bumped to 0.1.16 in `theme.xml`, `README.md` and `LICENSE`;
  `LICENSE` and `_music/README.md` credit both tracks. No layout changes;
  previews unchanged.

## Changes in version 0.1.15

* **Plaza install automated.** Embedded Plaza updated to **0.1.4**: the
  public server address is built in (nothing to type), a one-file
  `_plaza/installer/Plaza.sh` for Batocera's Ports list installs the channel
  and restarts EmulationStation by itself, and the client's own install item
  restarts EmulationStation too.
* **Full-install zip.** The release now also ships
  `BatWiiCera-full-v0.1.15.zip`, laid out for the Batocera share
  (`themes/`, `roms/ports`, `roms/plaza`, `system/configs`, `system/scripts`):
  extract and reboot, theme and Plaza channel included. The theme-only zip is
  unchanged in form.
* **Author credit** changed to yiddifliddo in `theme.xml`, `README.md`,
  `LICENSE`, the include headers and `_music/README.md`.
* Version bumped to 0.1.15 in `theme.xml`, `README.md` and `LICENSE`. No
  layout changes; previews unchanged.

## Changes in version 0.1.14

* Embedded Plaza updated to **0.1.3**: installs itself from its own menu on
  Batocera (no terminal), and takes the presence address from the server.
  README and `_plaza/README.md` rewritten around the terminal-free flow.
* Version bumped to 0.1.14 in `theme.xml`, `README.md` and `LICENSE`. No
  layout changes; previews unchanged.

## Changes in version 0.1.13

* Embedded Plaza updated to **0.1.2**: Railway hosting support (server
  honours `PORT`, separate presence URL, game address as host:port) and the
  Railway walkthrough `_plaza/RAILWAY-SETUP.md`.
* Version bumped to 0.1.13 in `theme.xml`, `README.md` and `LICENSE`. No
  layout changes; previews unchanged.

## Changes in version 0.1.12

* **Plaza embedded.** The theme folder now carries the Plaza 0.1.1 client,
  presence hook, system definition, logo, server package and a one-command
  installer in `_plaza/`, plus a VPS server walkthrough written for a
  WordPress host (`_plaza/SERVER-SETUP.md`). One download now brings the
  theme and the Plaza; the Plaza still needs its one-time install command.
* README "Plaza channel" section rewritten for the embedded copy.
* Version bumped to 0.1.12 in `theme.xml`, `README.md` and `LICENSE`. No
  layout changes; previews unchanged.

## Changes in version 0.1.11

* Bundled the Plaza channel logo (`_inc/systems/logos/plaza.svg`) so the
  Plaza tile looks right without the Plaza installer having to copy a file
  into the theme.
* README: new "Plaza channel" section.
* Version bumped to 0.1.11 in `theme.xml`, `README.md` and `LICENSE`. No other
  changes; previews unchanged.

## Changes in version 0.1.10

Fixes from the third on-device test (Batocera 43.1).

* **Console logos were stuck grey.** The engine only sends tile selection
  storyboards to extra elements, never to the built-in tile image, so the
  0.1.7 greyscale fade could never run and the static zero saturation left
  every logo grey. A true greyscale-to-colour fade is therefore not possible
  on tile images. Replaced with the per-state tile colour the engine does
  support: unselected logos are drawn washed-out at 40 percent opacity and the
  highlighted logo at full strength, with the engine blending between them.
* **Dark menus unreadable.** The dark menu relied on tinting the light frame
  image. Dark mode now ships a genuinely dark frame image
  (`menu-frame-dark.png`); the colour sets carry a `menuFrameImage` variable
  instead of a tint. After switching colour set, restart EmulationStation
  (Main Menu, Quit) so the cached menu theme is rebuilt.
* Version bumped to 0.1.10 in `theme.xml`, `README.md` and `LICENSE`;
  previews re-rendered.

## Changes in version 0.1.9

* **Pointer hand removed completely.** On the device the hand overlay drew
  small and squashed on the highlighted tile, so the overlay, the "Pointer
  hand on highlighted tile" option and `cursor-hand.svg` are gone from this
  version. The blue border and full-colour logo already show the selection.
* Version bumped to 0.1.9 in `theme.xml`, `README.md` and `LICENSE`;
  previews re-rendered without the hand.

## Changes in version 0.1.8

* **Dark mode.** New "Dark grey" colour set: dark striped backdrop, dark
  bottom bar and round buttons, dark list, preview and info panels, dark
  pop-up menus and menu button, light text throughout, dark "No preview"
  card. Console tiles stay light grey (white when highlighted) because many
  console logos use black lettering; the console logo above the game list
  sits on a light plate for the same reason.
* Colour sets now also carry the artwork and tint variables that differ
  between light and dark (bar, buttons, no-preview card, tile tint, menu frame
  tint, menu group background, grid label backgrounds), so `theme.xml` has no
  per-set special cases apart from the logo plate.
* New files: `_inc/colors/dark.xml`, `bg-stripes-dark.png`,
  `no-preview-dark.png`, `bottom-bar-dark.svg`, `btn-round-dark.svg`,
  `btn-mail-dark.svg`.
* Version bumped to 0.1.8 in `theme.xml`, `README.md` and `LICENSE`; dark
  mode mock-ups added to the previews.

## Changes in version 0.1.7

* **Grey until selected.** Console logos on the grid are shown in greyscale
  and fade to full colour (about a quarter of a second) when their tile is
  highlighted, fading back to grey when the highlight moves on. Implemented
  with the tile image's saturation and the engine's activate and deactivate
  storyboards, so no extra image files were needed.
* Version bumped to 0.1.7 in `theme.xml`, `README.md` and `LICENSE`; console
  grid mock-up re-rendered.
* (Superseded in 0.1.10: this fade never ran on the device.)

## Changes in version 0.1.6

Fixes from the second on-device test.

* **Readable pop-up menu buttons.** EmulationStation multiplies the button
  artwork by the menu text colour (dark grey here), which made the pill dark
  with invisible text. The normal state now uses a white outline pill (renders
  as a grey outline with dark text) and the focused state a white solid pill
  (renders as a blue pill with white text).
* **Menu and Start pills removed** from the game views; they were decorative.
* **Save-state indicator.** A compact disc icon shows in the info strip when
  the selected game has save states and opens the save manager when clicked.
  New original `compact-disc.svg`; description text narrowed slightly to make
  room.
* Version bumped to 0.1.6 in `theme.xml`, `README.md` and `LICENSE`; game
  list mock-up re-rendered.

## Changes in version 0.1.5

Fixes from the first on-device test.

* **Coloured console logos.** The tiles now use the full-colour logo set from
  the Carbon theme (over 600 systems and collections, SVG and PNG). Systems
  Carbon does not cover fall back to the Art Book Next logos, recoloured from
  white to dark grey. The grey tint applied to logos in earlier versions is
  removed. PNG logos were downscaled to 640 px wide to keep the theme small.
* **No name label on console tiles.** The short system name that rendered
  across the logo is gone; the full console name still shows under the clock.
* **Selected tile no longer clipped.** The console grid and game grid have
  inner padding and a gentler zoom (1.05) so the highlighted tile's border is
  not cut off on the bottom row or the right column.
* **Blue menu button.** The button at the foot of pop-up menus now uses the
  blue pill (darker blue when pressed) to match the selector.
* **Controller icon moved.** The active-controller indicator overlapped the
  help prompts at the bottom; it now sits in the top right corner next to the
  network icon.
* Version bumped to 0.1.5 in `theme.xml`, `README.md` and `LICENSE`; credits
  updated for Carbon; mock-up previews re-rendered.

## Changes in version 0.1.4

* The house and envelope buttons in the bottom bar now have click actions
  (mouse or touch): house opens game search on the console grid and goes back
  from the game views; envelope opens the Netplay lobby on the console grid
  and the selected game's options in the game views.
* The two buttons are now defined per view instead of in the shared block, so
  each view can carry its own action; positions and artwork are unchanged.
* New "Bottom bar buttons" section in this README.
* Version bumped to 0.1.4 in `theme.xml`, `README.md` and `LICENSE`.
* No layout, artwork or music changes compared with 0.1.3; previews unchanged.

## Changes in version 0.1.3

* RetroAchievements integration: the SD card icon in the bottom bar is
  replaced by the player's RetroAchievements avatar and user name (grey trophy
  and label when not signed in), clickable to open the RetroAchievements
  panel; gold trophy beside the game name in the detailed view and a trophy
  badge on game grid tiles for games that have achievements.
* New original `trophy.svg` icon; `sd-card.svg` removed.
* Game name field in the info strip narrowed slightly to make room for the
  trophy.
* Version bumped to 0.1.3 in `theme.xml`, `README.md` and `LICENSE`; mock-up
  previews re-rendered.
* No other layout, artwork or music changes compared with 0.1.2.

## Changes in version 0.1.2

* The pointer hand now follows the controller: it is defined as a grid tile
  overlay that is invisible on normal tiles and visible on the selected tile,
  so it moves (and animates) with the highlight in the console grid and the
  game grid.
* The static hand in the bottom bar was removed, so the list-plus-preview view
  no longer shows a hand.
* Theme option renamed to "Pointer hand on highlighted tile".
* Version bumped to 0.1.2 in `theme.xml`, `README.md` and `LICENSE`; mock-up
  previews re-rendered.
* No other layout, artwork or music changes compared with 0.1.1.

## Changes in version 0.1.1

* Added a bundled background music loop `_music/batwiicera-menu-loop.ogg`
  (quiet bass loop supplied by the author; trimmed to 16 bars, lowered by
  14 dB, encoded as OGG Vorbis).
* Background music option now defaults to **On**; the include comment and
  `_music/README.md` updated to describe the bundled track, how to add your
  own, and where to set the volume.
* Version bumped to 0.1.1 in `theme.xml`, `README.md` and `LICENSE`;
  licence file lists the bundled audio.
* No changes to layout, artwork or views compared with 0.1.0.

## Changes in version 0.1.0

Initial release.

* New `theme.xml` with system, basic, detailed, grid, menu and screen views.
* System view implemented as a 4 x 3 channel grid (3 x 3 on 4:3 screens) using
  `imagegrid`, with white rounded tiles, blue highlight tile, console name label,
  side arrows, curved bottom bar, round home and mail buttons, SD card icon
  (replaced in 0.1.3), clock, console name and game count.
* Detailed game view: left list panel, right preview screen with `md_video`
  (snapshot fallback, rounded corners), info strip with marquee, rating stars,
  year, players, genre and auto-scrolling description, "Menu" and "Start" pills.
* Basic game view: same list panel with a static "No preview available" screen.
* Grid game view: 5 x 3 tiles (4 x 3 on 4:3), video plays in the selected tile,
  favourite star overlay, game name under the clock.
* Menu styling: white rounded pop-ups, grey text, blue gradient selector, pill
  buttons.
* Two colour sets, aspect-ratio handling, pointer toggle, music toggle.
* Original artwork drawn for this theme: striped backgrounds, tile and panel
  nine-patches, pill buttons, bottom bar, round buttons, SD card (removed in
  0.1.3), arrows, disc, stars, pointer hand (removed in 0.1.9) and the "No preview available" card.
* Bundled open fonts and the Art Book Next system logo set (see `LICENSE`).

## Known limitations in 0.1.0

* Not yet verified on a physical Batocera device; positions may need small
  adjustments after the first on-device test.
* A few very uncommon systems may have no logo and show a grey disc instead.
* Hiding a system such as the built-in **Screenshots** (image viewer) is a
  Batocera setting, not a theme setting: *Main Menu > Game Collection
  Settings > Systems displayed*, then untick the system.

## Credits

* Coloured system logos: **Carbon** by Rookervik, based on **Simple** by Nils
  Bonenberger, Batocera edition by Fabrice Caruso (CC-BY-NC-SA 2.0).
* Fallback system logos and help-prompt icons: **Art Book Next** by Anthony
  Caccese (CC-BY-NC-SA).
* Gamepad activity icon and structural ideas: **es-theme-minimal** by lilbud and
  Fabrice Caruso (CC-BY-NC-SA).
* Theme-folder background music approach: **PlayStation-X** by pajarorrojo
  (CC-BY-NC-SA).
* Fonts: Varela Round (Apache 2.0), Nunito (SIL Open Font Licence 1.1).

This theme is a fan-made tribute. It is not affiliated with or endorsed by any
console manufacturer, and it contains no original console artwork, fonts or
audio.
