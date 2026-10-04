# BatWiiCera - version 0.1.8

**Author:** Dan Lee (personal project)
**Target:** Batocera EmulationStation (theme format version 7)
**Licence:** Creative Commons BY-NC-SA 4.0 (see `LICENSE`)

BatWiiCera recreates the feel of a classic motion-controlled console's home menu:
a grid of rounded "channel" tiles on a softly striped light grey background, a
curved bottom bar with a big clock, and a channel-preview style game screen with
a live video preview.

## Navigation flow

1. **Console grid** - every system is a channel tile showing its logo in
   greyscale; the highlighted tile's logo fades up to full colour.
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
| Pointer hand on highlighted tile | Yes, No | The pointing hand rides the selected tile in the console grid and game grid, moving with your controller. Not shown in the list view |
| Background music | On, Off | On by default. Plays the bundled quiet loop and any files you add to the theme's `_music` folder |

## Bottom bar buttons

The two round buttons respond to a mouse click or a touchscreen tap
(EmulationStation does not route controller input to on-screen buttons):

| Button | Console grid | Game list and game grid |
| --- | --- | --- |
| House (left) | Opens game search | Goes back to the console grid |
| Envelope (right) | Opens the Netplay lobby | Opens the options for the selected game |

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

1. Copy the whole `BatWiiCera` folder (this folder) to `/userdata/themes/` on
   your Batocera device, or to `\\BATOCERA\share\themes\` over the network.
2. In EmulationStation open *Main Menu > UI Settings > Theme set* and choose
   **BatWiiCera**.
3. Music: a quiet loop is bundled and plays by default. To add or replace
   tracks, or to change the volume, see `_music/README.md`.

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
    music.xml            background music include
    systems/logos/       coloured logos per system (Carbon, with Art Book Next fallbacks)
  _music/                bundled quiet loop; add your own tracks here
```

## Changes in this version (0.1.8)

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
* Known limitation to confirm on device: the tile highlighted when the grid
  first appears may stay grey until the highlight moves once.

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
  0.1.3), arrows, disc, stars, pointer hand and the "No preview available" card.
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
