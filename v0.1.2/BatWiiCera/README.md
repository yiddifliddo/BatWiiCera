# BatWiiCera - version 0.1.2

**Author:** Dan Lee (personal project)
**Target:** Batocera EmulationStation (theme format version 7)
**Licence:** Creative Commons BY-NC-SA 4.0 (see `LICENSE`)

BatWiiCera recreates the feel of a classic motion-controlled console's home menu:
a grid of rounded "channel" tiles on a softly striped light grey background, a
curved bottom bar with a big clock, and a channel-preview style game screen with
a live video preview.

## Navigation flow

1. **Console grid** - every system is a channel tile showing its logo and name.
   Move the highlight with the d-pad or stick. The selected console's name and
   game count appear under the clock in the bottom bar.
2. **Game list with preview** (default view) - a white rounded panel on the left
   lists the games; the big screen on the right plays the scraped video, or shows
   the screenshot when no video exists, or a "No preview available" card when
   neither exists. Game logo, rating, year, players, genre and a scrolling
   description sit in the strip below the screen. Press the confirm button to
   start the game.
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
| Colour set | Classic grey, Sky blue | Background stripes, text and highlight colours |
| Aspect ratio | 16:9 widescreen, 4:3 standard | 4:3 and 5:4 screens are detected automatically |
| Game grid tile image | Screenshot, Box art, Logo, Mix image | Picture used on tiles in the game grid view |
| Pointer hand on highlighted tile | Yes, No | The pointing hand rides the selected tile in the console grid and game grid, moving with your controller. Not shown in the list view |
| Background music | On, Off | On by default. Plays the bundled quiet loop and any files you add to the theme's `_music` folder |

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
    colors/              colour sets (classic.xml, sky.xml)
    fonts/               Varela Round, Nunito Regular, Nunito Bold
    images/              backgrounds, tiles, bar, buttons, icons, placeholders
    layouts/4-3.xml      overrides for 4:3 screens
    music.xml            background music include
    systems/logos/       one SVG logo per system (from Art Book Next)
  _music/                bundled quiet loop; add your own tracks here
```

## Changes in this version (0.1.2)

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
  side arrows, curved bottom bar, round home and mail buttons, SD card icon,
  clock, console name and game count.
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
  nine-patches, pill buttons, bottom bar, round buttons, SD card, arrows, disc,
  stars, pointer hand and the "No preview available" card.
* Bundled open fonts and the Art Book Next system logo set (see `LICENSE`).

## Known limitations in 0.1.0

* Not yet verified on a physical Batocera device; positions may need small
  adjustments after the first on-device test.
* The small label under each console tile shows the system's short name
  (for example `snes`). The full console name is shown under the clock.
* The console logo set is shared with other themes; a few less common systems
  may have no logo and show a grey disc with the system name instead.

## Credits

* System logos and help-prompt icons: **Art Book Next** by Anthony Caccese
  (CC-BY-NC-SA).
* Gamepad activity icon and structural ideas: **es-theme-minimal** by lilbud and
  Fabrice Caruso (CC-BY-NC-SA).
* Theme-folder background music approach: **PlayStation-X** by pajarorrojo
  (CC-BY-NC-SA).
* Fonts: Varela Round (Apache 2.0), Nunito (SIL Open Font Licence 1.1).

This theme is a fan-made tribute. It is not affiliated with or endorsed by any
console manufacturer, and it contains no original console artwork, fonts or
audio.
