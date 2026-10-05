# BatWiiCera - Change Control Register

Process reference: ISO/IEC 27001:2022 Annex A, control 8.32 (Change management).

Rules for this register:

* Every change gets a new record. Records are appended, never edited away or
  deleted; corrections are made by adding a new record that references the old one.
* Every change that alters the theme produces a new version in its own
  `vX.Y.Z/` folder. Previous version folders are never modified.
* Each record carries the author, the company or project, a risk assessment,
  test evidence and a rollback plan, and is approved before merge to `main`.

## Register summary

| Change ID | Date | Version | Type | Title | Branch | Status |
| --- | --- | --- | --- | --- | --- | --- |
| CR-0001 | 2026-10-04 | 0.1.0 | New release | Initial creation of the BatWiiCera theme | `release/v0.1.0` | Submitted for approval |
| CR-0002 | 2026-10-04 | 0.1.1 | Standard change | Bundle quiet background music loop, music on by default | `release/v0.1.1` | Submitted for approval |
| CR-0003 | 2026-10-04 | 0.1.1 (docs only) | Documentation change | Embed layout mock-up screenshots in the repository README | `release/v0.1.1` | Submitted for approval |
| CR-0004 | 2026-10-04 | 0.1.1 (packaging) | Packaging change | Add installable zip of version 0.1.1 | `release/v0.1.1` | Submitted for approval |
| CR-0005 | 2026-10-04 | 0.1.2 | Standard change | Pointer hand follows the highlighted grid tile | `release/v0.1.2` | Submitted for approval |
| CR-0006 | 2026-10-04 | 0.1.3 | Standard change | RetroAchievements integration replaces the SD card icon | `release/v0.1.3` | Submitted for approval |
| CR-0007 | 2026-10-04 | 0.1.4 | Standard change | Click actions for the house and envelope buttons | `release/v0.1.4` | Submitted for approval |
| CR-0008 | 2026-10-04 | 0.1.5 | Corrective change | On-device test fixes: coloured logos, tile labels, clipping, menu button | `release/v0.1.5` | Submitted for approval |
| CR-0009 | 2026-10-04 | 0.1.6 | Corrective change | Readable menu buttons, Menu/Start pills removed, save-state indicator | `release/v0.1.6` | Submitted for approval |
| CR-0010 | 2026-10-04 | 0.1.7 | Standard change | Console logos grey until highlighted, then full colour | `release/v0.1.7` | Submitted for approval |
| CR-0011 | 2026-10-04 | 0.1.8 | Standard change | Dark grey colour set (dark mode) | `release/v0.1.8` | Submitted for approval |
| CR-0012 | 2026-10-04 | 0.1.9 | Corrective change | Pointer hand removed completely | `release/v0.1.9` | Submitted for approval |
| CR-0013 | 2026-10-04 | 0.1.10 | Corrective change | Logos stuck grey; dark menus unreadable | `release/v0.1.10` | Submitted for approval |
| CR-0014 | 2026-10-04 | 0.1.10 (repo only) | Repository change | Remove reference screenshots from the repository | `release/v0.1.10` | Submitted for approval |
| CR-0015 | 2026-10-05 | Plaza 0.1.0 | New product area | Add the Plaza channel (own register in `plaza/CHANGE_CONTROL.md`) | `release/plaza-v0.1.0` | Submitted for approval |
| CR-0016 | 2026-10-05 | 0.1.11 | Standard change | Bundle the Plaza channel logo | `release/v0.1.11` | Submitted for approval |
| CR-0017 | 2026-10-05 | repo only | Documentation / tooling | Batocera Themes Downloader submission kit | `release/v0.1.11` | Submitted for approval |
| CR-0018 | 2026-10-05 | 0.1.12 | Standard change | Embed the Plaza (0.1.1) in the theme package with installer and VPS guide | `release/v0.1.12` | Submitted for approval |
| CR-0019 | 2026-10-05 | 0.1.13 | Standard change | Embedded Plaza updated to 0.1.2 (Railway support) | `release/v0.1.13` | Submitted for approval |
| CR-0020 | 2026-10-05 | repo | Release / deployment | Merge all release branches to `main`; make the repository root deploy the Plaza server on Railway | `main` | Approved by author instruction, implemented |
| CR-0021 | 2026-10-05 | repo | Release | Merge Plaza 0.1.3 (PCR-0004) to `main`; root start script now runs Plaza 0.1.3 | `main` | Approved by author instruction, implemented |
| CR-0022 | 2026-10-05 | 0.1.14 | Standard change | Embedded Plaza updated to 0.1.3 (terminal-free install) | `release/v0.1.14`, merged to `main` | Approved by author instruction, implemented |
| CR-0023 | 2026-10-05 | none (record) | Deployment record | Plaza server deployed on Railway; public addresses recorded | `main` | Approved, implemented |
| CR-0024 | 2026-10-05 | 0.1.15 | Standard change | Plaza install automated (Plaza 0.1.4), full-install zip, author credit yiddifliddo | `release/v0.1.15`, merged to `main` | Approved by author instruction, implemented |
| CR-0025 | 2026-10-05 | repo | Emergency release | Root start scripts moved to Plaza 0.1.5 (PCR-0006, Railway port clash) | `main` | Approved by author instruction, implemented |
| CR-0026 | 2026-10-05 | 0.1.15 (distribution) | Release / distribution | Public distribution repository `BatWiiCera-theme` filled with 0.1.15 for Batocera's Themes Downloader | `main` of `BatWiiCera-theme` | Approved by author instruction, implemented |
| CR-0027 | 2026-10-05 | 0.1.15 (distribution) | Distribution record | Listing request posted to the Batocera team | none | Posted, awaiting the Batocera team |
| CR-0028 | 2026-10-05 | 0.1.16 | Standard change | Second music track (menu theme) and a four-way Background music choice | `release/v0.1.16`, merged to `main` | Approved by author instruction, implemented |
| CR-0029 | 2026-10-05 | 0.1.17 | Corrective change | Plaza channel could not start on Batocera: embed Plaza 0.1.6 with bundled runtime, launcher and artwork | `release/v0.1.17`, merged to `main` | Approved by author ("go"), implemented |
| CR-0030 | 2026-10-05 | 0.1.18 | Corrective change | Menu button textures broken at real button height; RetroAchievements avatar address missing the username | `release/v0.1.18`, merged to `main` | Approved by author ("Fix it"), implemented |
| CR-0031 | 2026-10-05 | 0.1.19 | Standard change | Embedded Plaza updated to 0.1.7 (stadium, avatars, movement, generated names); root start scripts to 0.1.7 | `release/v0.1.19`, merged to `main` | Approved by author ("build the stadium and look"), implemented |
| CR-0033 | 2026-10-05 | repo | Release | Root start scripts moved to Plaza 0.1.8 (PCR-0009, netplay relay) | `main` | Approved by author instruction, implemented |
| CR-0032 | 2026-10-05 | 0.1.20 | Corrective change | RetroAchievements avatar stuck on the default picture: web image cache never expires; cache-busting tag added. Corrects the root cause recorded in CR-0030 | `release/v0.1.20`, merged to `main` | Implemented after a repeated report ("I STILL don't have my proper retroachievements avatar") |

---

## CR-0001 - Initial creation of the BatWiiCera theme

| Field | Value |
| --- | --- |
| Change ID | CR-0001 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.0 (folder `v0.1.0/BatWiiCera`) |
| Previous version | None (new product) |
| Change type | New release (planned) |
| Branch | `release/v0.1.0` |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Create a new Batocera EmulationStation theme that reproduces the look of a
classic motion-controlled console's home menu, based on two reference
screenshots supplied by the author (removed from the repository under CR-0014). Navigation is console first, then
game, with a live video or screenshot preview of the highlighted game.

Scope delivered:

* `theme.xml` (format version 7) with system, basic, detailed, grid, menu and
  screen views, five theme options (colour set, aspect ratio, grid tile image,
  pointer hand, background music) and shared variables.
* System view as a 4 x 3 `imagegrid` of channel tiles (3 x 3 on 4:3), bottom
  bar, buttons, clock, console name and game count.
* Detailed view with list panel, video preview with snapshot fallback, info
  strip (marquee, rating, year, players, genre, description), Menu and Start pills.
* Basic view with static preview card. Grid view with video in the selected tile.
* Menu, help-prompt and clock styling.
* Colour sets `classic.xml` and `sky.xml`; `layouts/4-3.xml`; `music.xml`.
* Original artwork (PNG nine-patches and SVG icons) generated for the theme.
* Bundled open fonts (Varela Round, Nunito) and the Art Book Next logo set.
* Theme `README.md`, `LICENSE`, `_music/README.md`, repository `README.md`
  and this register.
* Layout mock-up images in `v0.1.0/previews/`.

### Reason for change

No existing Batocera theme offers this console-menu style with a true
multi-row channel grid. Requested by the author for personal use and possible
community release.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Target EmulationStation build lacks `imagegrid` support in the system view | Low on current Batocera, higher on old builds | Console view shows the default carousel instead of the grid | Documented in README; game views unaffected |
| Layout mis-sized on untested resolutions | Medium | Cosmetic overlap | 16:9 default plus 4:3 override; values are normalised, not pixel based |
| Licence non-compliance for reused assets | Low | Legal | All reused assets listed in LICENSE with authors and links; theme released under the same CC BY-NC-SA licence |
| Copyrighted music committed to repo | Low | Legal | No audio shipped; `_music/README.md` instructs users to add their own locally only |
| Performance on low-power boards (many SVG logos, video previews) | Medium | Slower scrolling | Video delay 0.5 s in list view, 0.9 s in grid view; logos are small SVGs |

Overall risk rating: **Low**. The change adds new files only and does not
touch any existing production asset.

### Impact

* New files only. No existing files in the repository were changed or removed.
* No impact on other themes or on Batocera system configuration.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of `theme.xml` and all includes (`xmllint --noout`) | Pass |
| Every asset path referenced from the XML resolves to a file in the theme folder | Pass (36 unique paths checked) |
| Every SVG asset parses as valid XML | Pass |
| PNG assets encoded as 8-bit RGBA | Pass |
| Element and property names cross-checked against the Batocera EmulationStation source (`ThemeData.cpp`, `SystemView.cpp`, `GridTileComponent.cpp`) and `THEMES.md` | Pass |
| Static HTML mock-ups of the console grid and game list, built with the theme's assets, fonts and coordinates at 1280 x 720, rendered in headless Chromium and visually reviewed (`v0.1.0/previews/`) | Pass - white logo masks were found to be invisible on white tiles and a tint was added before release |
| Render test on a Batocera device | **Not performed** - no device available in the build environment. Required before approval. |

### Rollback plan

Delete the `v0.1.0` folder from `/userdata/themes/` on the device and select
a different theme set. In the repository, revert the merge of
`release/v0.1.0`; no other files are affected.

### Post-implementation review

To be completed after on-device testing. Record any layout corrections as a
new change record producing version 0.1.1.

---

## CR-0002 - Bundle quiet background music loop, music on by default

| Field | Value |
| --- | --- |
| Change ID | CR-0002 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.1 (folder `v0.1.1/BatWiiCera`) |
| Previous version | 0.1.0 (folder `v0.1.0`, left unchanged) |
| Change type | Standard change (planned, low risk) |
| Branch | `release/v0.1.1` (branched from `release/v0.1.0`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Add a background music loop to the theme so the menu plays quiet music by
default, as requested by the author, who supplied the source audio
(30-second bass loop, 130 BPM, F minor, MP3).

* `v0.1.1/` created as a full copy of `v0.1.0/`.
* Source audio trimmed to 16 bars (29.54 s) for a cleaner repeat, gain lowered
  by 14 dB (mean level -29 dB, peak -16 dB), 20 ms fades added at both ends,
  encoded as OGG Vorbis quality 3 (383 KB) and stored as
  `_music/batwiicera-menu-loop.ogg`.
* `theme.xml`: version header 0.1.1; `music` subset reordered so **On** is the
  default.
* `_inc/music.xml` comment, `_music/README.md`, theme `README.md`, `LICENSE`,
  repository `README.md` and this register updated.

### Reason for change

Author request: ambient music that loops quietly while browsing, without the
user having to add files by hand.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Music too loud or unwanted for some users | Low | Annoyance | Gain reduced 14 dB; option can be set to Off; device Music volume setting documented |
| Rights to the supplied audio | Low | Legal | Audio supplied by the author for this theme; recorded in LICENSE. Author to confirm they hold the rights before public release |
| Audible gap or click on repeat | Medium | Cosmetic | Trimmed to a bar boundary with short fades; EmulationStation's own track gap remains |
| Repo size growth | Low | None | 383 KB OGG instead of the 1 MB MP3 |

Overall risk rating: **Low**.

### Impact

* New version folder only; `v0.1.0` untouched.
* Users upgrading from 0.1.0 will hear music by default until they switch the
  option off.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.1` XML files (`xmllint --noout`) | Pass |
| Asset path check for all referenced files in `v0.1.1` | Pass |
| OGG decodes; duration 29.54 s; mean -29.1 dB, peak -15.7 dB (`ffmpeg volumedetect`) | Pass |
| Playback test on a Batocera device | **Not performed** - required before approval |

### Rollback plan

Set the theme option *Background music* to Off, or install the `v0.1.0`
folder instead. In the repository, revert the merge of `release/v0.1.1`.

### Post-implementation review

To be completed after on-device testing.

---

## CR-0003 - Embed layout mock-up screenshots in the repository README

| Field | Value |
| --- | --- |
| Change ID | CR-0003 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | None - documentation only; theme version remains 0.1.1 |
| Previous version | 0.1.1 (folder `v0.1.1`, unchanged) |
| Change type | Documentation change (no code or asset change) |
| Branch | `release/v0.1.1` |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Add a "Screenshots" section to the repository `README.md` that embeds the two
existing layout mock-ups from `v0.1.1/previews/` (console channel grid and
game list with preview), with a note that they are mock-ups rendered from the
theme's assets rather than captures from a device.

### Reason for change

Author request, so the README shows the theme's look at a glance.

### Risk assessment

No theme files changed. Risk rating: **Negligible**. The only risk is the
mock-ups differing slightly from the on-device render, which the caption states.

### Impact

Repository `README.md` only. No installable files affected, so no new version
folder was created.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Image paths referenced by the README exist in the repository | Pass |
| No theme files modified (`git diff --stat` limited to README and this register) | Pass |

### Rollback plan

Revert the single documentation commit.

---

## CR-0004 - Add installable zip of version 0.1.1

| Field | Value |
| --- | --- |
| Change ID | CR-0004 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | None - packaging of existing 0.1.1; theme files unchanged |
| Previous version | 0.1.1 (folder `v0.1.1/BatWiiCera`, unchanged) |
| Change type | Packaging change |
| Branch | `release/v0.1.1` |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Add `v0.1.1/BatWiiCera-v0.1.1.zip`, a zip archive of the `v0.1.1/BatWiiCera`
folder with `BatWiiCera/` as the archive root, so extracting it into
`/userdata/themes/` installs the theme directly. Repository `README.md` gains
a download link and a Zip column in the version table.

### Reason for change

Author request for a single downloadable installer alongside the release.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Zip drifts from the folder after later edits | Medium | Users install stale files | Rule: any change to a version folder is a new version with its own freshly built zip; the zip was built from the committed folder and verified identical |
| Wrong folder structure causes install errors | Low | Theme not found | Archive root verified as `BatWiiCera/theme.xml` |

Overall risk rating: **Negligible**.

### Impact

Adds one 1.7 MB binary file to the repository. No theme files changed.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Archive integrity (`unzip -t`) | Pass, 377 files, no errors |
| Extracted archive compared with `v0.1.1/BatWiiCera` (`diff -rq`) | Identical |
| Archive root is the `BatWiiCera` folder | Pass |

### Rollback plan

Delete the zip and revert the README change; the version folder is unaffected.

---

## CR-0005 - Pointer hand follows the highlighted grid tile

| Field | Value |
| --- | --- |
| Change ID | CR-0005 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.2 (folder `v0.1.2/BatWiiCera`, zip `v0.1.2/BatWiiCera-v0.1.2.zip`) |
| Previous version | 0.1.1 (folder `v0.1.1`, left unchanged) |
| Change type | Standard change (planned, low risk) |
| Branch | `release/v0.1.2` (branched from `release/v0.1.1`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked whether the pointer hand moves with the controller. In 0.1.1
it was a fixed image in the bottom bar. In 0.1.2 the hand is defined as a grid
tile overlay (`gridtile.overlay`) that is fully transparent on normal tiles
and opaque on the selected tile (`gridtile.overlay:selected`), so it appears on
whichever tile is highlighted and animates with the selection in both the
console grid and the game grid. The static hand was removed, so the list view
shows no hand. The theme option was renamed to "Pointer hand on highlighted
tile" and still turns the overlay off.

* `v0.1.2/` created as a full copy of `v0.1.1/` (zip excluded and rebuilt).
* `theme.xml`: version 0.1.2; static `pointer-hand` extra removed; overlay
  elements added to the `system` and `grid` views; subset display name updated.
* Theme `README.md`, `LICENSE`, repository `README.md`, previews and this
  register updated. New zip built and verified.

### Reason for change

Author request following a question about pointer behaviour; brings the
theme closer to the original console's pointer feel.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Overlay position or size differs from the mock-up on the device | Medium | Cosmetic | Positions are tile-relative; adjust in a follow-up version after on-device check |
| Older EmulationStation builds ignore `gridtile.overlay` | Low | No hand shown | Degrades silently; everything else unchanged |
| Overlay drawn under the tile background | Low | Hand hidden | Overlay given z-index 30, above the tile image |

Overall risk rating: **Low**.

### Impact

New version folder only; `v0.1.0` and `v0.1.1` untouched. Users who liked the
static hand in the list view lose it.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.2` XML files | Pass |
| Overlay element and `:selected` state names cross-checked against `GridTileComponent.cpp` (per-state pos, size, origin and colour supported; states are interpolated) | Pass |
| Mock-up of the console grid re-rendered with the hand on the selected tile | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Behaviour on a Batocera device | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.1` folder or zip, or set *Pointer hand on highlighted tile*
to No. In the repository, revert the merge of `release/v0.1.2`.

### Post-implementation review

To be completed after on-device testing.

---

## CR-0006 - RetroAchievements integration replaces the SD card icon

| Field | Value |
| --- | --- |
| Change ID | CR-0006 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.3 (folder `v0.1.3/BatWiiCera`, zip `v0.1.3/BatWiiCera-v0.1.3.zip`) |
| Previous version | 0.1.2 (folder `v0.1.2`, left unchanged) |
| Change type | Standard change (planned, low risk) |
| Branch | `release/v0.1.3` (branched from `release/v0.1.2`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked for the SD card icon to be removed and RetroAchievements
integrated in its place, as other community themes do. Implemented following
the pattern used by PlayStation-X and the EmulationStation source:

* Bottom bar, all browsing views: `sd-card` extra removed. Added a
  `webimage` showing the player's avatar from
  `https://media.retroachievements.org/UserPic/<username>.png` and a text
  showing the user name when `{global.cheevos}` is true; a grey trophy and the
  label "RetroAchievements" when false. All three carry `onclick="cheevos"`,
  which EmulationStation maps to opening the RetroAchievements panel.
* Detailed view: gold trophy beside the game name, visible when
  `{game:cheevos}` is true and RetroAchievements is enabled; game name field
  narrowed from 0.345 to 0.31 of screen width.
* Grid view: `gridtile.cheevos` badge (gold trophy) on tiles whose game has
  achievements.
* New original `_inc/images/trophy.svg`; `_inc/images/sd-card.svg` deleted
  from this version.
* `v0.1.3/` created as a full copy of `v0.1.2/` (zip excluded and rebuilt).
  Theme `README.md` (new RetroAchievements section), `LICENSE`, repository
  `README.md`, previews and this register updated.

### Reason for change

Author request for feature parity with other Batocera themes.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Avatar download fails (offline device or user has no avatar) | Medium | Empty space where the avatar goes; name still shown | Only shown when RetroAchievements is enabled; label falls back to user name |
| `webimage` or `onclick` unsupported on older EmulationStation builds | Low | Element ignored | Degrades silently |
| Trophy badge overlaps tile art | Low | Cosmetic | Placed in the top right corner with a small size; adjust after on-device check |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched. Users lose the
decorative SD card icon.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.3` XML files | Pass |
| Asset path check (no remaining reference to `sd-card.svg`) | Pass |
| `onclick="cheevos"` confirmed as a handled action in `SystemView.cpp`; `{global.cheevos}`, `{global.cheevos.username}` and `{game:cheevos}` confirmed in `SystemData.cpp` and `FileData.cpp`; `gridtile.cheevos` confirmed in `GridTileComponent.cpp` | Pass |
| Mock-ups re-rendered with the RetroAchievements block and trophy | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Behaviour on a Batocera device with RetroAchievements signed in | **Not performed** - required before approval |

### Amendments

* 2026-10-04 - The first preview image committed for 0.1.3 drew the avatar
  placeholder above the bottom bar, which did not match the theme coordinates
  (avatar centred level with the home button). The two preview images in
  `v0.1.3/previews/` were re-rendered in a follow-up commit. No theme files
  or zip changed.

### Rollback plan

Install the `v0.1.2` folder or zip. In the repository, revert the merge of
`release/v0.1.3`.

### Post-implementation review

To be completed after on-device testing.

---

## CR-0007 - Click actions for the house and envelope buttons

| Field | Value |
| --- | --- |
| Change ID | CR-0007 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.4 (folder `v0.1.4/BatWiiCera`, zip `v0.1.4/BatWiiCera-v0.1.4.zip`) |
| Previous version | 0.1.3 (folder `v0.1.3`, left unchanged) |
| Change type | Standard change (planned, low risk) |
| Branch | `release/v0.1.4` (branched from `release/v0.1.3`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked what the envelope button does. It and the house button were
decorative. Both now carry EmulationStation click actions (`onclick`), which
fire on mouse click or touchscreen tap:

| Button | System view | basic, detailed and grid views |
| --- | --- | --- |
| House | `search` (game search) | `back` (return to the console grid) |
| Envelope | `netplay` (Netplay lobby) | `gameoptions` (selected game's options) |

To allow a different action per view the two images were moved out of the
shared view block and defined once in the `system` view and once in the
`basic, detailed, grid` block, with identical positions and artwork.
`v0.1.4/` created as a full copy of `v0.1.3/` (zip excluded and rebuilt);
theme `README.md` gains a "Bottom bar buttons" section; `LICENSE`,
repository `README.md` and this register updated. Previews unchanged.

### Reason for change

Author request so the two prominent buttons do something useful.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Users expect controller input to trigger the buttons | Medium | Confusion | Mouse/touch limitation documented in the README |
| An action name is not handled on an older EmulationStation build | Low | Click does nothing | Degrades silently; names verified against current source |
| 4:3 override of the button size no longer applies | Low | Cosmetic | Override targets the same element names in the `system` view and still merges |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.4` XML files | Pass |
| Asset path check | Pass |
| Action names `search`, `netplay`, `back`, `gameoptions` confirmed in `SystemView.cpp` and `ISimpleGameListView.cpp` `onAction` handlers | Pass |
| Zip integrity and extracted contents identical to the folder | Pass |
| Click behaviour on a Batocera device with mouse or touch | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.3` folder or zip. In the repository, revert the merge of
`release/v0.1.4`.

### Post-implementation review

To be completed after on-device testing.

---

## CR-0008 - On-device test fixes: coloured logos, tile labels, clipping, menu button

| Field | Value |
| --- | --- |
| Change ID | CR-0008 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.5 (folder `v0.1.5/BatWiiCera`, zip `v0.1.5/BatWiiCera-v0.1.5.zip`) |
| Previous version | 0.1.4 (folder `v0.1.4`, left unchanged) |
| Change type | Corrective change (defects found in the first on-device test) |
| Branch | `release/v0.1.5` (branched from `release/v0.1.4`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author installed the theme on a Batocera device (photos supplied) and
reported five defects. The test also confirmed that the console grid, bottom
bar, clock, pop-up menus and help prompts render as designed.

| Defect | Cause | Fix |
| --- | --- | --- |
| Console logos are grey, not colour | Art Book Next logos are white masks tinted grey | Logo set replaced by the full-colour Carbon set (609 files); Art Book Next kept only as fallback, recoloured white to dark grey; all tints removed from `gridtile` and `logo` elements; svg then png path fallback |
| System name text renders across the logo | The grid tile label is drawn over the tile centre; author does not want it | Label hidden (`visible` false, size 0 0); tile padding made symmetrical |
| Selected tile's border clipped on the bottom row and right column | Selected tile zooms 6 percent and the grid clips at its own edge | Inner `padding` 0.015 on both grids and zoom reduced to 1.05 |
| Pop-up menu button is grey | `menuButton` used the grey pill | Blue pill, darker blue when pressed (`pill-blue-dark.png` added) |
| Active-controller icon overlaps the help prompts | `controllerActivity` placed at the bottom right, inside the help prompt row on wider prompt sets | Moved to the top right corner (x 0.80-0.92, y 0.028), left of the network icon |

Also recorded: hiding the built-in Screenshots (image viewer) system is a
Batocera setting (Game Collection Settings > Systems displayed), outside the
theme's control; documented in the README.

`v0.1.5/` created as a full copy of `v0.1.4/` (zip excluded and rebuilt);
theme `README.md`, `LICENSE` (Carbon credit and recolour notice), repository
`README.md`, previews and this register updated.

### Reason for change

Defects reported from on-device testing of the release candidate.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| A Carbon logo designed for a dark background is hard to read on white | Low-Medium | Cosmetic for a few systems | 36 common systems checked on white tiles; the white "-w" variants were excluded |
| Repository and zip grow with the larger logo set | Certain | Theme folder grows from 4 MB to about 25 MB | PNG logos downscaled to at most 640 px wide and stripped; two SVGs with embedded bitmaps replaced by the lighter recoloured fallbacks; remaining size accepted as normal for a full logo set |
| Padding value leaves the zoomed tile still clipped on some resolutions | Low | Cosmetic | Values are normalised; re-check on device |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched. Visual change on every
console tile.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.5` XML files | Pass |
| Asset path check | Pass |
| 36 common Carbon logos rendered on white tiles in headless Chromium and reviewed | Pass (visual) |
| Mock-ups re-rendered with coloured logos, no labels and blue menu button | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Re-test on the Batocera device | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.4` folder or zip. In the repository, revert the merge of
`release/v0.1.5`.

### Post-implementation review

To be completed after the device re-test.

---

## CR-0009 - Readable menu buttons, Menu/Start pills removed, save-state indicator

| Field | Value |
| --- | --- |
| Change ID | CR-0009 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.6 (folder `v0.1.6/BatWiiCera`, zip `v0.1.6/BatWiiCera-v0.1.6.zip`) |
| Previous version | 0.1.5 (folder `v0.1.5`, left unchanged) |
| Change type | Corrective change (second on-device test) plus one small feature |
| Branch | `release/v0.1.6` (branched from `release/v0.1.5`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

| Item | Cause / reason | Change |
| --- | --- | --- |
| Pop-up menu button dark and unreadable (photos supplied) | `ButtonComponent.cpp` multiplies the button image by `menuText` `color` (normal) and `selectorColor` (focused); with the theme's dark grey text colour any pill artwork renders dark, hiding the dark text | `menuButton` now uses a white outline-only pill for the normal state (renders as a grey outline with dark text on the white menu) and a white solid pill for the focused state (renders as a blue pill with white text). New `pill-outline.png` and `pill-solid.png` |
| Menu and Start pills in the game views do nothing | Decorative, carried over from the original console's preview screen | Both pills and their labels removed from `basic`/`detailed` |
| Author wants save states visible with a compact disc icon | EmulationStation exposes `{game:savestate}` (`FileData.cpp`) and the `savestates` click action opens the save manager (`ISimpleGameListView.cpp`) | New original `compact-disc.svg` shown bottom right of the info strip only when the game has save states, `onclick="savestates"`; description width reduced from 0.345 to 0.305 (0.31 on 4:3); 4:3 override added |

`v0.1.6/` created as a full copy of `v0.1.5/` (zip excluded and rebuilt);
theme `README.md` (new "Save states" section), `LICENSE`, repository
`README.md`, previews and this register updated.

### Reason for change

Defects and a feature request from the author's second device test.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Save-state property not evaluated on older EmulationStation builds | Low | Disc never shows, or always shows | Property name taken from the current source; verify on device |
| Outline pill looks different from other themes' buttons | Low | Cosmetic | Matches the theme's light style; focused state is clearly blue |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.6` XML files | Pass |
| Asset path check; no remaining Menu/Start pill elements | Pass |
| Button tint behaviour confirmed in `ButtonComponent.cpp`; `{game:savestate}` and `savestates` action confirmed in source | Pass |
| Game list mock-up re-rendered | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Re-test on the Batocera device (menu button, disc icon on a game with saves) | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.5` folder or zip. In the repository, revert the merge of
`release/v0.1.6`.

### Post-implementation review

To be completed after the device re-test.

---

## CR-0010 - Console logos grey until highlighted, then full colour

| Field | Value |
| --- | --- |
| Change ID | CR-0010 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.7 (folder `v0.1.7/BatWiiCera`, zip `v0.1.7/BatWiiCera-v0.1.7.zip`) |
| Previous version | 0.1.6 (folder `v0.1.6`, left unchanged) |
| Change type | Standard change (planned, low risk) |
| Branch | `release/v0.1.7` (branched from `release/v0.1.6`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked for console tiles to stay grey when not selected and go full
colour when selected. The grid tile's per-state properties do not include
saturation, but `GridTileComponent.cpp` fires `activate` and `deactivate`
storyboards on the tile and its children when the selection changes, and
`ImageComponent.cpp` exposes `saturation` as an animatable property. The
console grid's `gridtile.image` therefore now has `saturation` 0 plus an
`activate` storyboard animating saturation 0 to 1 over 250 ms and a
`deactivate` storyboard animating it back. No new image files.

`v0.1.7/` created as a full copy of `v0.1.6/` (zip excluded and rebuilt);
theme `README.md`, `LICENSE`, repository `README.md`, previews and this
register updated.

### Reason for change

Author request; makes the highlighted console stand out and matches the
"channel lighting up" feel.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Initially highlighted tile stays grey until the highlight moves | Medium | Cosmetic on first display | Documented as a known limitation; can be revisited after the device test |
| Older EmulationStation builds ignore storyboards on tile images | Low | All logos grey | Degrades to a consistent greyscale look |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched. Visual change on the
console grid only; the game grid is unchanged.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.7` XML files | Pass |
| Storyboard events and animatable saturation confirmed in `GridTileComponent.cpp` and `ImageComponent.cpp` | Pass |
| Console grid mock-up re-rendered (grey logos, colour selected logo) | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Behaviour on the Batocera device | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.6` folder or zip. In the repository, revert the merge of
`release/v0.1.7`.

### Post-implementation review

To be completed after the device test.

---

## CR-0011 - Dark grey colour set (dark mode)

| Field | Value |
| --- | --- |
| Change ID | CR-0011 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.8 (folder `v0.1.8/BatWiiCera`, zip `v0.1.8/BatWiiCera-v0.1.8.zip`) |
| Previous version | 0.1.7 (folder `v0.1.7`, left unchanged) |
| Change type | Standard change (new option, low risk) |
| Branch | `release/v0.1.8` (branched from `release/v0.1.7`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Author request for a dark mode in which everything is a darker grey, with
text colours adjusted and console logos kept readable.

* New colour set `_inc/colors/dark.xml` ("Dark grey") added to the
  `colorset` option. Light text (E6E6E6 / B8B8B8 / 8E8E8E), lighter blue for
  metadata text, dark separators, dark panel tint.
* The artwork and tints that differ between light and dark are now variables
  defined in every colour set (bar image, home and mail buttons, no-preview
  card, tile tint, menu frame tint, menu group background, grid label
  backgrounds). `theme.xml` references the variables instead of fixed paths.
* New dark artwork: `bg-stripes-dark.png`, `no-preview-dark.png`,
  `bottom-bar-dark.svg`, `btn-round-dark.svg`, `btn-mail-dark.svg`.
* Console tiles deliberately stay light grey (white when highlighted) in dark
  mode because many Carbon logos use black lettering that would disappear on
  dark tiles. For the same reason a light plate (`logo-plate`, dark set only)
  sits behind the console logo above the game list.
* Pop-up menus: frame tinted dark, group headers on a dark band; the outline
  menu button inherits the light text colour so it stays readable.

`v0.1.8/` created as a full copy of `v0.1.7/` (zip excluded and rebuilt);
theme `README.md`, `LICENSE`, repository `README.md`, previews (light and
dark) and this register updated.

### Reason for change

Author request.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| A colour-set variable missing from one set leaves a path unresolved | Low | Missing artwork in that set | Script-checked: every variable used in `theme.xml` is defined in all three sets |
| Scraped artwork (marquees drawn for dark backgrounds) now sits on dark panels | None | Improves | n/a |
| Users expect dark tiles too | Medium | Preference | Documented reasoning; a dark-tile variant with white logos could follow if wanted |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched. Light sets render as
before (same values moved into variables).

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.8` XML files | Pass |
| Asset path check | Pass |
| Every `${variable}` used in `theme.xml` defined in classic, sky and dark sets | Pass |
| Dark mock-ups of the console grid and game list rendered and reviewed | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Dark grey set on the Batocera device | **Not performed** - required before approval |

### Rollback plan

Select the Classic grey colour set, or install the `v0.1.7` folder or zip.
In the repository, revert the merge of `release/v0.1.8`.

### Post-implementation review

To be completed after the device test.

---

## CR-0012 - Pointer hand removed completely

| Field | Value |
| --- | --- |
| Change ID | CR-0012 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.9 (folder `v0.1.9/BatWiiCera`, zip `v0.1.9/BatWiiCera-v0.1.9.zip`) |
| Previous version | 0.1.8 (folder `v0.1.8`, left unchanged) |
| Change type | Corrective change (device test) |
| Branch | `release/v0.1.9` (branched from `release/v0.1.8`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

On the device (photo supplied) the pointer-hand tile overlay introduced in
CR-0005 rendered small and squashed on the highlighted tile. The author asked
for it to be removed completely rather than fixed.

* `gridtile.overlay` and `gridtile.overlay:selected` removed from the
  `system` and `grid` views.
* The `pointer` option ("Pointer hand on highlighted tile") removed from the
  theme options.
* `_inc/images/cursor-hand.svg` deleted from this version.
* `v0.1.9/` created as a full copy of `v0.1.8/` (zip excluded and rebuilt);
  theme `README.md`, `LICENSE`, repository `README.md`, previews and this
  register updated.

### Reason for change

Device test defect; author decision to drop the feature.

### Risk assessment

Removal only; no new behaviour. Risk rating: **Negligible**. Users who had
the option set keep working because the option no longer exists and the
engine ignores the stale setting.

### Impact

New version folder only; earlier versions untouched.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.9` XML files | Pass |
| No remaining reference to the overlay, option or hand artwork; asset path check | Pass |
| Four mock-ups re-rendered without the hand | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Confirmation on the Batocera device | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.8` folder or zip. In the repository, revert the merge of
`release/v0.1.9`.

### Post-implementation review

To be completed after the device test.

---

## CR-0013 - Logos stuck grey; dark menus unreadable

| Field | Value |
| --- | --- |
| Change ID | CR-0013 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.10 (folder `v0.1.10/BatWiiCera`, zip `v0.1.10/BatWiiCera-v0.1.10.zip`) |
| Previous version | 0.1.9 (folder `v0.1.9`, left unchanged) |
| Change type | Corrective change (third device test, Batocera 43.1) |
| Branch | `release/v0.1.10` (branched from `release/v0.1.9`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

| Defect | Root cause (from source) | Fix |
| --- | --- | --- |
| Console logos grey even when highlighted (photo supplied) | `GridTileComponent::handleStoryBoard` dispatches activate/deactivate storyboards only to `enumerateExtraChildrens()`; the built-in tile image is a BUILTIN child, so the CR-0010 saturation storyboards never ran and the static `saturation` 0 left all logos grey | Saturation and storyboards removed. `gridtile.image` colour `FFFFFF66` (40 percent) and `gridtile.image:selected` colour `FFFFFFFF`, which the engine interpolates per state. Logos are washed-out until highlighted. A true greyscale fade is recorded as not achievable on built-in tile images |
| Dark grey menus hard to read (photo: light frame, pale items) | Dark frame depended on tinting the light `menu-frame.png`; the engine also caches the menu theme until the theme is reloaded | New `menu-frame-dark.png`; colour sets define `menuFrameImage` (light sets keep `menu-frame.png`); `menuBackground` colour reset to white so no tint is involved. README now says to restart EmulationStation after changing colour set |

`v0.1.10/` created as a full copy of `v0.1.9/` (zip excluded and rebuilt);
theme `README.md`, `LICENSE`, repository `README.md`, previews and this
register updated.

### Reason for change

Defects reported from the third device test.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Washed-out logos judged too faint or not faint enough | Medium | Cosmetic | Single alpha value `66`; easy to tune in a follow-up |
| Dark menu still light if the menu theme cache is not rebuilt | Low | Readability | Restart instruction documented; genuine dark image removes the tint dependency |

Overall risk rating: **Low**.

### Impact

New version folder only; earlier versions untouched.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of all `v0.1.10` XML files | Pass |
| Asset path check; every `${variable}` defined in all three colour sets | Pass |
| Root causes confirmed in `GridTileComponent.cpp` (storyboard dispatch) and `ThemeData.cpp` (menu theme cache and background parsing) | Pass |
| Mock-ups re-rendered (light and dark) | Pass (visual) |
| Zip integrity and extracted contents identical to the folder | Pass |
| Re-test on the Batocera 43.1 device | **Not performed** - required before approval |

### Rollback plan

Install the `v0.1.9` folder or zip. In the repository, revert the merge of
`release/v0.1.10`.

### Post-implementation review

To be completed after the device re-test.

---

## CR-0014 - Remove reference screenshots from the repository

| Field | Value |
| --- | --- |
| Change ID | CR-0014 |
| Date raised | 2026-10-04 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera repository |
| Version produced | None - repository content only; theme version remains 0.1.10 |
| Change type | Repository change |
| Branch | `release/v0.1.10` |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The two reference photographs of the original console menu that were
uploaded to the repository root at the start of the project are removed from
the working tree, a `.gitignore` is added so they (and any other image at the
repository root) cannot be committed again, and the repository README and the
CR-0001 record no longer refer to them. The repository README layout block
was also corrected (it had mislabelled the 0.1.8 and 0.1.9 preview folders).

### Reason for change

Author instruction that these files must never be shown. They are also
third-party screenshots, so keeping them out of a public repository is the
correct position under the theme's licence.

### Limitations

The files remain in the `main` branch (original upload commit) and in the
history of every branch until `main` is updated and history is rewritten.
Rewriting history requires a force push, which is outside this change; it is
left for the author to authorise separately.

### Risk assessment

Removal only. Risk rating: **Negligible**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Files absent from the branch working tree and index | Pass |
| `.gitignore` blocks the two filenames and root-level images | Pass |
| No remaining reference to the files in README or registers | Pass |

### Rollback plan

Revert the single commit.

---

## CR-0015 - Add the Plaza channel to the repository

| Field | Value |
| --- | --- |
| Change ID | CR-0015 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera Plaza (companion to the theme) |
| Version produced | Plaza 0.1.0 in `plaza/v0.1.0/`; theme version unchanged (0.1.10) |
| Change type | New product area |
| Branch | `release/plaza-v0.1.0` (branched from `release/v0.1.10`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Adds the Plaza channel as a separate product area under `plaza/`, with its own
`README.md`, MIT `LICENSE` and change register (`plaza/CHANGE_CONTROL.md`,
record PCR-0001) that describes the server, client, presence hook,
installer, design decisions, risks and test evidence in full. A separate
repository was the author's first choice but the tooling could not create
one; the author then asked for it to be added here.

No theme files change. A later theme version will bundle the Plaza channel
logo (`plaza.svg`); until then the Plaza installer copies the logo into an
installed theme folder.

### Risk assessment

See PCR-0001. For this repository: none beyond repository size (about 0.2 MB).

### Testing and verification performed

See PCR-0001 (server smoke test, client self-test, rendering on a virtual
framebuffer, hook end to end, package builds). No Batocera device test yet.

### Rollback plan

Revert the merge of `release/plaza-v0.1.0`; delete the `plaza/` folder.

---

## CR-0016 - Bundle the Plaza channel logo

| Field | Value |
| --- | --- |
| Change ID | CR-0016 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.11 (folder `v0.1.11/BatWiiCera`, zip `v0.1.11/BatWiiCera-v0.1.11.zip`) |
| Previous version | 0.1.10 (folder `v0.1.10`, left unchanged) |
| Change type | Standard change (low risk) |
| Branch | `release/v0.1.11` (branched from `release/v0.1.10`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Adds `_inc/systems/logos/plaza.svg`, the channel logo for the BatWiiCera
Plaza (see CR-0015 / PCR-0001), so the Plaza tile renders with the theme's
own logo set and the Plaza installer no longer needs to copy a file into an
installed theme. README gains a "Plaza channel" section. No layout changes.

### Risk assessment

Additive file only. Risk rating: **Negligible**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| XML well-formedness of `theme.xml` and the logo SVG | Pass |
| Zip integrity and extracted contents identical to the folder | Pass |
| Tile appearance on a device | **Not performed** |

### Rollback plan

Install `v0.1.10`. In the repository, revert the merge of `release/v0.1.11`.

---

## CR-0017 - Batocera Themes Downloader submission kit

| Field | Value |
| --- | --- |
| Change ID | CR-0017 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera repository |
| Version produced | None - documentation and tooling only |
| Change type | Documentation / tooling |
| Branch | `release/v0.1.11` |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked how to get the theme included with Batocera. Findings:
Batocera's Themes Downloader reads a team-curated JSON feed
(`batocera.org/upgrades/themes.json`, 97 entries when checked) of GitHub
repositories, downloads a repository's default branch and expects
`theme.xml` at its root; new entries are added by the team on request
(Discord themes channel or forum). This versioned repository cannot be
listed directly, so:

* `tools/make-dist.sh <version> <path>` mirrors an approved version to the
  root of a separate, public distribution repository and adds a preview and
  README pointing back here.
* `docs/SUBMISSION.md` documents the mechanism, the steps, a checklist and
  the ready-to-post request text.

Submitting is a manual step for the author: creating the public
`BatWiiCera-theme` repository (tooling cannot create repositories), taking a
device screenshot, and posting the request. The outcome is to be recorded as
a further change record.

### Risk assessment

Documentation and a script that only writes into the path it is given.
Risk rating: **Negligible**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `bash -n tools/make-dist.sh` | Pass |
| Dry run of `make-dist.sh` into a temporary folder: root `theme.xml`, `preview.png` and README produced | Pass |

### Rollback plan

Revert the commit.

---

## CR-0018 - Embed the Plaza in the theme package

| Field | Value |
| --- | --- |
| Change ID | CR-0018 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.12 (folder `v0.1.12/BatWiiCera`, zip `v0.1.12/BatWiiCera-v0.1.12.zip`) |
| Previous version | 0.1.11 (folder `v0.1.11`, left unchanged) |
| Change type | Standard change (packaging and documentation) |
| Branch | `release/v0.1.12` (branched from `release/v0.1.11`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

The author asked for the Plaza to be embedded in the theme and for a
walkthrough of adding the server to a WordPress server.

* New `_plaza/` folder inside the theme, built from Plaza 0.1.1
  (`release/plaza-v0.1.1`): `dist/BatWiiCera-Plaza.love`, `hook/`,
  `installer/` (installer, system definition, logo), `server.tar.gz`,
  `LICENSE` (MIT), `PLAZA-README.md`, a `README.md` for the embedded copy and
  `install-plaza.sh`, a wrapper so the whole set-up on a Batocera machine is
  one command run from the theme folder.
* `_plaza/SERVER-SETUP.md`: step-by-step guide for a WordPress VPS: check or
  install Node.js, copy the package, test by hand, open ports 7777 and 7778
  in the OS and provider firewalls, run as a hardened systemd service, point
  the Batocera machines at it, optional reverse proxy for the stats page,
  updating, troubleshooting. States that shared hosting without SSH cannot
  run it.
* Theme README "Plaza channel" section rewritten; version bumped.

A theme cannot start programs, so the one-time install command remains;
this change removes the separate download. Theme zip grows from 13.47 MB to
13.52 MB.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| EmulationStation parses files inside `_plaza/` | None observed | n/a | Theme files are loaded only through includes; the folder holds no theme XML |
| Embedded Plaza copy drifts from the Plaza source | Medium | Stale client in the theme | Each Plaza release triggers a theme release that re-embeds it (recorded here) |
| Users run the installer without a server | Medium | Plaza shows "Set the server address first" | Documented order of steps |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Embedded files extracted from `release/plaza-v0.1.1` unchanged (built client, hook, installer, logo, server package) | Pass |
| `bash -n` on the wrapper; `theme.xml` well-formed | Pass |
| Zip integrity and extracted contents identical to the folder | Pass |
| Install from the embedded folder on a Batocera device; server set-up following the guide on the author's VPS | **Not performed** - required before approval |

### Rollback plan

Install `v0.1.11`. In the repository, revert the merge of `release/v0.1.12`.

---

## CR-0019 - Embedded Plaza updated to 0.1.2

| Field | Value |
| --- | --- |
| Change ID | CR-0019 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.13 (folder `v0.1.13/BatWiiCera`, zip `v0.1.13/BatWiiCera-v0.1.13.zip`) |
| Previous version | 0.1.12 (folder `v0.1.12`, left unchanged) |
| Change type | Standard change (packaging) |
| Branch | `release/v0.1.13` (branched from `release/v0.1.12`) |
| Status | Submitted for approval |
| Approver | Dan Lee |
| Approval date | Pending |

### Description of change

Re-embeds the Plaza from `release/plaza-v0.1.2` (PCR-0003): client,
hook, installer, server package, Plaza README, licence and the new
`RAILWAY-SETUP.md`; the embedded README and installer wrapper mention the
Railway form of the install command. Theme layout untouched.

### Risk assessment

Packaging only. Risk rating: **Negligible**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Embedded files extracted from `release/plaza-v0.1.2` unchanged; server package reports version 0.1.2 | Pass |
| Zip integrity and extracted contents identical to the folder | Pass |
| Device and Railway test | **Not performed** |

### Rollback plan

Install `v0.1.12`. In the repository, revert the merge of `release/v0.1.13`.

---

## CR-0020 - Merge to main and Railway root deployment

| Field | Value |
| --- | --- |
| Change ID | CR-0020 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee ("push it to Railway, it's connected to the repo") |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera repository (theme and Plaza) |
| Version produced | None new; `main` now carries theme 0.1.13 and Plaza 0.1.2 |
| Change type | Release (merge) and deployment configuration |
| Branch | `release/railway-root`, merged into `main` |
| Status | Approved by author instruction, implemented |
| Approver | Dan Lee |
| Approval date | 2026-10-05 |

### Description of change

The author's Railway service is connected to this repository and follows
`main`. Its builds failed because `main` held only the original upload and
the root has no project to build. Under the author's instruction to push to
Railway:

* `release/v0.1.13` (theme line, CR-0001 to CR-0019 except CR-0015) and
  `release/plaza-v0.1.2` (Plaza line, CR-0015 and PCR-0001 to PCR-0003) were
  merged, with the two shared files (README and this register) combined by
  hand, then merged with `main` (which had the author's own deletions of the
  two reference photographs).
* Repository root gains `package.json` (start script running
  `plaza/v0.1.2/server/index.js`, Node 18 or newer), `railway.json`
  (start command, `/health` check, restart policy) and `.railwayignore`
  (keeps the theme version folders and zips out of the build upload). Railway
  therefore builds from the repository root with no settings changes. The
  start script is a pointer to the current Plaza version and is updated by
  the change that releases a new Plaza version.
* On Railway the author still needs: Public Networking > Generate Domain
  (presence over HTTPS) and Networking > TCP Proxy on port 7777 (game
  connection). Both are account-side settings the repository cannot make.

Approval note: the records CR-0001 to CR-0019 and PCR-0001 to PCR-0003 list
"Submitted for approval"; the author's instruction to deploy is taken as
approval to merge them to `main`. On-device test evidence is still
outstanding and remains recorded as such in each record.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Root `package.json` confuses the Batocera Themes Downloader | None | n/a | The downloader uses the separate distribution repository (CR-0017) |
| Railway build uploads the whole repository | Low | Slow builds | `.railwayignore` excludes version folders, zips and previews |
| Untested merge combination | Low | Doc inconsistencies only; theme and Plaza files are disjoint | Tree checked: `v0.1.13/BatWiiCera/theme.xml` and `plaza/v0.1.2/server/index.js` present, no reference photographs |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Server started from the repository root via the root start script with `PORT` set; `/health` answers | Pass (version 0.1.2 reported) |
| No merge conflict markers; register and README contain both lines of records | Pass |

### Rollback plan

Reset `main` to the previous head (`1e00923`) by a revert merge commit;
delete the root `package.json`, `railway.json` and `.railwayignore`.

---

## CR-0021 - Merge Plaza 0.1.3 to main

| Field | Value |
| --- | --- |
| Change ID | CR-0021 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera repository |
| Version produced | None new; `main` now runs Plaza 0.1.3 on Railway |
| Change type | Release (merge) |
| Branch | `main` |
| Status | Approved by author instruction (deploy to Railway), implemented |
| Approver | Dan Lee |
| Approval date | 2026-10-05 |

### Description of change

`release/plaza-v0.1.3` merged into `main`; root `package.json` and
`railway.json` start scripts updated from `plaza/v0.1.2/server` to
`plaza/v0.1.3/server`, so the Railway service serves the version whose
welcome message carries the public presence URL. No volume or variables are
required on Railway: the server holds all state in memory.

### Testing and verification performed

Root start of `plaza/v0.1.3/server/index.js` with `PORT` set: health answers.

### Rollback plan

Point the root start scripts back at `plaza/v0.1.2/server` and push.

---

## CR-0022 - Embedded Plaza updated to 0.1.3

| Field | Value |
| --- | --- |
| Change ID | CR-0022 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.14 (folder `v0.1.14/BatWiiCera`, zip `v0.1.14/BatWiiCera-v0.1.14.zip`) |
| Previous version | 0.1.13 (folder `v0.1.13`, left unchanged) |
| Change type | Standard change (packaging and documentation) |
| Branch | `release/v0.1.14`, merged to `main` under the standing instruction to keep `main` deployable |
| Status | Approved by author instruction, implemented |
| Approver | Dan Lee |
| Approval date | 2026-10-05 |

### Description of change

Re-embeds Plaza 0.1.3 (PCR-0004) in the theme: the client that installs
itself from its menu, the hook, installer, server package and guides. Theme
and embedded READMEs now lead with the terminal-free procedure (copy the
`.love` to `roms/love` over the share, start it, choose Install, set the
server address, restart EmulationStation).

### Testing and verification performed

| Check | Result |
| --- | --- |
| Embedded client reports version 0.1.3; zip integrity and folder identity | Pass |
| Terminal-free install on a device | **Not performed** - required |

### Rollback plan

Install `v0.1.13`. In the repository, revert the merge.

---

## CR-0023 - Plaza server deployed on Railway (public addresses recorded)

| Field | Value |
| --- | --- |
| Change ID | CR-0023 |
| Date raised | 2026-10-05 |
| Requested by | Dan Lee |
| Author | Dan Lee |
| Company / project | Dan Lee (personal project) |
| Product | BatWiiCera Plaza - shared online room (server 0.1.3) |
| Version produced | None - documentation-only record, no theme or Plaza code changed |
| Change type | Standard change (deployment record) |
| Branch | `main` (Railway follows `main`; same standing instruction as CR-0020 to CR-0022) |
| Status | Approved, implemented |
| Approver | Dan Lee |
| Approval date | 2026-10-05 |

### Description of change

The Plaza server from `plaza/v0.1.3/server` is running on Railway, built
from the repository root (`package.json`, `railway.json`, CR-0021). The
author generated the public addresses in Railway, Settings > Networking:

| Purpose | Address |
| --- | --- |
| HTTPS (presence hook, `/health`, `/stats`) | `https://batwiicera-production.up.railway.app` (Railway `PORT` 8080) |
| Game connection (TCP proxy to container port 7777) | `maglev.proxy.rlwy.net:28071` |

The server reads Railway's `PORT` for its HTTP listener and derives the
presence URL from `RAILWAY_PUBLIC_DOMAIN`, so no environment variables and
no volume were added. On Batocera the game address to enter during the
Plaza install is `maglev.proxy.rlwy.net:28071`; the presence URL is handed
to the client by the server on connect.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `GET /health` on the HTTPS domain | Pass - `{"ok":true,"players":0,"version":"0.1.3"}` |
| `GET /stats` on the HTTPS domain | Pass - world 1400 x 800, ball at centre, no players |
| TCP hello/welcome through `maglev.proxy.rlwy.net:28071` | **Not verified** - the build environment used for this record only permits outbound HTTPS, so the raw TCP port could not be reached from it. To be confirmed by the first client connection from a device, or by checking the Railway deploy log for the line `[plaza] game port 0.0.0.0:7777`. |
| Device install using the addresses above | **Not performed** - required |

### Rollback plan

Delete the domain and TCP proxy in Railway, Settings > Networking, or stop
the service. Nothing in the repository needs reverting; this record stays
as history.

---

## CR-0024 - Plaza install automated, full-install zip, author credit

| Field | Value |
| --- | --- |
| Change ID | CR-0024 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("this needs to be automated"; "make the author for all of this yiddifliddo") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.15 (folder `v0.1.15/BatWiiCera`, zips `v0.1.15/BatWiiCera-v0.1.15.zip` and `v0.1.15/BatWiiCera-full-v0.1.15.zip`) |
| Previous version | 0.1.14 (folder `v0.1.14`, left unchanged) |
| Change type | Standard change (packaging, documentation, attribution) |
| Branch | `release/v0.1.15`, merged to `main` under the standing instruction to keep `main` deployable |
| Status | Approved by author instruction, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

* Embeds Plaza 0.1.4 (PCR-0005): built-in public server, the one-file Ports
  entry `_plaza/installer/Plaza.sh`, automatic EmulationStation restart, hook
  fallback, launch command that restores the hook's permissions. `_plaza/`
  READMEs, the wrapper `install-plaza.sh` and the server guides rewritten
  around the three no-typing routes (full zip, Ports file, client menu).
* New **full-install zip** `BatWiiCera-full-v0.1.15.zip` laid out for the
  Batocera share: `themes/BatWiiCera/`, `roms/ports/Plaza.sh`,
  `roms/plaza/Plaza.love` and `gamelist.xml`,
  `system/configs/emulationstation/es_systems_plaza.cfg`,
  `system/scripts/batwiicera-plaza-presence.sh` (executable bits stored) and
  a short `README-FULL-INSTALL.txt`. The theme-only zip keeps its form for
  Batocera's Themes Downloader.
* **Attribution**: author changed from Dan Lee to yiddifliddo in
  `theme.xml`, every include header, `README.md`, `LICENSE`,
  `_music/README.md`, the root `README.md`, `package.json`,
  `docs/SUBMISSION.md`, `tools/make-dist.sh`, `plaza/README.md` and
  `plaza/LICENSE`. Version folders 0.1.0 to 0.1.14 and Plaza 0.1.0 to 0.1.3
  are released artefacts and keep their original credit; earlier change
  records are history and are not edited. Git history is not rewritten
  (author's decision); commits from this record on are authored as
  yiddifliddo.
* Root `package.json` and `railway.json` now start `plaza/v0.1.4/server`, so
  the public server redeploys as 0.1.4 on merge.
* Theme views, colours and assets are unchanged; previews unchanged.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Full zip extracted somewhere other than the share root | Medium (user error) | Files land in the wrong folders | `README-FULL-INSTALL.txt` inside the zip shows the layout; Ports and client routes remain |
| Executable bit lost on the hook when extracted from Windows | High | "Now playing" labels missing until the Plaza is opened once | Channel launch command restores the bit; Ports entry does too |
| Railway redeploy of 0.1.4 server | Low | Short outage during deploy | Protocol unchanged; health check gates the switch |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `xmllint` on `theme.xml`, colour sets, layout and music includes | Pass |
| Embedded client reports version 0.1.4; both zips pass integrity checks; theme zip and the theme part of the full zip are byte-identical to the folder; executable bits present in the full zip | Pass |
| No remaining "Dan Lee" in `v0.1.15`, root documents or `plaza/` index files; no forbidden tool name anywhere in the repository | Pass |
| Plaza 0.1.4 tests (PCR-0005) | Pass |
| Install on a device by each route; EmulationStation restart; theme views | **Not performed** - required before sign-off |

### Rollback plan

Install `v0.1.14`. In the repository, revert the merge; Railway then
redeploys the 0.1.3 server, which 0.1.4 clients can still use.

---

## CR-0025 - Root start scripts moved to Plaza 0.1.5

| Field | Value |
| --- | --- |
| Change ID | CR-0025 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo (Railway error report) |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera repository (Railway deployment files) |
| Version produced | None for the theme; Plaza 0.1.5 (PCR-0006) |
| Change type | Emergency release |
| Branch | `release/plaza-v0.1.5`, merged to `main` |
| Status | Approved by author instruction, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

`package.json` and `railway.json` start `plaza/v0.1.5/server/index.js`, the
server that survives Railway setting `PORT` to the TCP proxy port. Details,
incident and tests in `plaza/CHANGE_CONTROL.md`, PCR-0006. Theme 0.1.15 is
unchanged.

### Rollback plan

Point the two files back at `plaza/v0.1.4/server` and set `PLAZA_HTTP_PORT=8080` in Railway.

---

## CR-0026 - Distribution repository filled with 0.1.15

| Field | Value |
| --- | --- |
| Change ID | CR-0026 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("I have created it already") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - distribution copy for Batocera's Themes Downloader |
| Version produced | None new; publishes 0.1.15 (CR-0024) at https://github.com/yiddifliddo/BatWiiCera-theme |
| Change type | Release / distribution |
| Branch | `main` of `BatWiiCera-theme`, commit `545760f` |
| Status | Approved by author instruction, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

The author created the empty public repository `BatWiiCera-theme`.
`tools/make-dist.sh 0.1.15` filled it: `v0.1.15/BatWiiCera` at the root
(theme.xml, `_inc`, `_music`, `_plaza`, LICENSE), a `preview.png` from the
console-grid mock-up, and a short README pointing back to this repository.
The theme's own long README is replaced by that short one in the
distribution copy, as the script has always done. Pushed as yiddifliddo.
`docs/SUBMISSION.md` updated: steps 1 and 2 marked done, version 0.1.15.

### Testing and verification performed

| Check | Result |
| --- | --- |
| Distribution tree identical to `v0.1.15/BatWiiCera` apart from the intended README and added `preview.png`; 710 files, about 26 MB | Pass |
| `theme.xml` at the root of `main` fetched from GitHub, header shows 0.1.15 and yiddifliddo | Pass |
| `main` branch zip downloaded from GitHub the way the downloader fetches it: integrity check passed, `theme.xml` at the top level, Plaza files present | Pass |
| No forbidden tool name in the distribution copy | Pass |
| Install from that zip on a device | **Not performed** - required before the listing request |

### Rollback plan

Delete the repository, or push an earlier version with `tools/make-dist.sh`.

---

## CR-0027 - Listing request posted to the Batocera team

| Field | Value |
| --- | --- |
| Change ID | CR-0027 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - listing in Batocera's Themes Downloader |
| Version produced | None; concerns the 0.1.15 distribution copy (CR-0026) |
| Change type | Distribution record |
| Status | Posted, awaiting the Batocera team |
| Approver | yiddifliddo |

### Description

The author took a screenshot on the device and posted the request text from
`docs/SUBMISSION.md` to the Batocera team (Discord themes channel or forum),
pointing at https://github.com/yiddifliddo/BatWiiCera-theme. Listing is at
the team's discretion; any questions or requested changes will be handled as
new records. Acceptance, when it happens, gets its own record.

### Open items carried forward

* Install test of the downloader zip on a device: not confirmed to the
  register.
* Distribution rights for the bundled music loop under CC BY-NC-SA: not
  confirmed to the register.
* First device test of the Plaza connection (CR-0024, PCR-0005).

---

## CR-0028 - Second music track and a four-way Background music choice

| Field | Value |
| --- | --- |
| Change ID | CR-0028 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("use this audio"; "add both, let people choose") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.16 (folder `v0.1.16/BatWiiCera`, zips `BatWiiCera-v0.1.16.zip`, `BatWiiCera-full-v0.1.16.zip`) |
| Previous version | 0.1.15 (folder `v0.1.15`, left unchanged) |
| Change type | Standard change (content and option) |
| Branch | `release/v0.1.16`, merged to `main` |
| Status | Approved by author instruction, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

* New track `_music/batwiicera-menu-theme.ogg` (2 min 54 s, Ogg Vorbis,
  stereo 48 kHz, 0.75 MB) from the file `Menu_1.ogg` supplied by the author,
  re-encoded 12 dB quieter (mean -29.5 dB, peak -16.4 dB, matching the
  bundled loop) with metadata stripped. The author states it is not a
  Nintendo recording; the rights question raised before inclusion was
  answered by the author and the file is distributed under the theme licence
  on that basis.
* The **Background music** subset now has four includes: `menu` (default,
  `_inc/music-menu.xml`, `bgsound` element, loops the menu theme), `loop`
  (`_inc/music-loop.xml`, loops the bass loop), `all` (`_inc/music.xml`,
  `directory` element, shuffles the folder) and `off`. EmulationStation's
  audio manager replays a `bgsound` track when it ends, so single-track
  choices loop. Saved settings of the former `on` include fall back to the
  default.
* `LICENSE`, `_music/README.md`, theme `README.md` (option table, install
  step, folder layout, change list) updated. Version 0.1.16 in `theme.xml`,
  `README.md`, `LICENSE`; root README and `package.json` version updated.
* Not pushed to the distribution repository: the Batocera team is reviewing
  0.1.15 (CR-0027). To be pushed on the author's instruction.

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Track rights challenged | Low per author's statement | Takedown; listing refused | Author's statement recorded here; track removable in a new version |
| `bgsound` unsupported on an older EmulationStation | Low | Silence for the single-track choices | Shuffle choice still uses `directory` |
| Larger package (+0.75 MB) | Certain | Negligible | None needed |

Overall risk rating: **Low**.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `xmllint` on `theme.xml` and the three music includes | Pass |
| Loudness of the new track measured after re-encoding (mean -29.5 dB, peak -16.4 dB versus loop -29.1 / -15.7) | Pass |
| Both zips pass integrity checks; theme zip byte-identical to the folder | Pass |
| Audio manager source confirms `directory` shuffles the folder recursively and `bgsound` loops a single file | Pass |
| Option visible and each choice audible on a device | **Not performed** - required before sign-off |

### Rollback plan

Install `v0.1.15`. In the repository, revert the merge.

---

## CR-0029 - Plaza channel could not start: embed Plaza 0.1.6 with bundled runtime

| Field | Value |
| --- | --- |
| Change ID | CR-0029 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo (device photos; "the Plaza doesn't start, it just closes immediately"; approved the proposal with "go") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.17 (folder `v0.1.17/BatWiiCera`, zips `BatWiiCera-v0.1.17.zip` 19 MB and `BatWiiCera-full-v0.1.17.zip` 24 MB) |
| Previous version | 0.1.16 (folder `v0.1.16`, left unchanged) |
| Change type | Corrective change |
| Branch | `release/v0.1.17`, merged to `main` |
| Status | Approved by author ("go"), implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

First device test of the Plaza channel (theme 0.1.16 / Plaza 0.1.5): the
game screen showed placeholder metadata and "No preview available",
Batocera's launch splash showed its stock logo, and the channel closed at
once. Root cause and fix are in Plaza PCR-0007: Batocera ships no LÖVE
engine, so the Plaza now bundles the official LÖVE 11.5 Linux build and
starts through one launcher script.

* `_plaza/` refreshed to Plaza 0.1.6: `runtime/` (5 MB, zlib licence),
  `installer/Plaza.sh`, new system file (`.sh` entry, `bash %ROM%`), game
  list with artwork in `installer/images/`, updated installer, hook, client,
  server package, guides and licence.
* Full-install zip adds `roms/plaza/Plaza.sh`, `roms/plaza/images/` and
  `roms/plaza/runtime/` (unpacked on first launch); executable bits stored.
* `LICENSE` lists the bundled runtime under its zlib licence. Theme README
  and `_plaza/README.md` explain the runtime and the x86_64 limit.
* Root `package.json` and `railway.json` start `plaza/v0.1.6/server`
  (version string only; redeploys as 0.1.6). `.railwayignore` excludes
  `plaza/*/runtime/`.
* Theme views, colours and music unchanged. Not pushed to the distribution
  repository until the author says so (the team is reviewing 0.1.15).

### Risk assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Runtime does not start under Batocera's display stack | Medium until tested | Channel still fails | `plaza.log` records the step reached; device test is the next action |
| Theme package size for the downloader listing (about 32 MB unpacked) | Certain | Team may question size | Documented in the submission notes; runtime could move to a separate download later |
| ARM devices | Certain | No Plaza there yet | Logged message; runtime for ARM can be added |

Overall risk rating: **Medium** until the device test passes.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `xmllint` on `theme.xml` | Pass |
| Both zips pass integrity checks; theme zip byte-identical to the folder; executable bits on launcher, hook and runtime in the full zip | Pass |
| Plaza 0.1.6 tests and dry run (PCR-0007), including a launch through the bundled runtime | Pass |
| No forbidden tool name; no superseded author credit in new folders | Pass |
| On the device: channel tile opens the Plaza, game screen shows artwork and metadata, launch splash shows the Plaza logo | **Not performed** - required |

### Rollback plan

Install `v0.1.16` (theme without a working Plaza). In the repository, revert the merge.

---

## CR-0030 - Menu buttons broken at real height; avatar address missing the username

| Field | Value |
| --- | --- |
| Change ID | CR-0030 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo (device photos; "Buttons on the menus no longer look pill shaped. Fix it. My avatar from retroachievements is not showing") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.18 (folder `v0.1.18/BatWiiCera`, zips `BatWiiCera-v0.1.18.zip`, `BatWiiCera-full-v0.1.18.zip`) |
| Previous version | 0.1.17 (folder `v0.1.17`, left unchanged) |
| Change type | Corrective change |
| Branch | `release/v0.1.18`, merged to `main` |
| Status | Approved by author ("Fix it"), implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Root causes

1. **Buttons.** `NinePatchComponent` takes `cornerSize` in screen pixels
   and `ButtonComponent` sizes a button to its text, roughly 40 px at 1080p
   with the theme's 0.032 menu font. The 0.1.6 textures (160x80, corners 40)
   therefore had corners twice the button height; the middle slice went
   negative and the caps drew inverted. The HTML mock-ups used for earlier
   sign-off did not model this, which is why it was not caught.
2. **Avatar.** The web image address used the static variable form
   `${global.cheevos.username}`. On the device the engine left it empty in
   the image address (it works inside `<text>`), so RetroAchievements
   served its generic "unknown user" joystick. Batocera's Carbon theme uses
   the binding form `{global:cheevosUser}` in the same address.

### Description of change

* `_inc/images/pill-outline.png` and `pill-solid.png` redrawn as 36x36
  textures (2 px white outline, and white fill, radius 12);
  `menuButton` `cornerSize` 12 12. Tinting by the engine unchanged.
* `webimage ra-avatar` path changed to
  `https://media.retroachievements.org/UserPic/{global:cheevosUser}.png`.
* Version bumped to 0.1.18 in `theme.xml`, `README.md`, `LICENSE`; root
  README and `package.json` version updated. Plaza embed unchanged (0.1.6).
* Not pushed to the distribution repository (team reviewing 0.1.15).

### Not addressed in this record

RetroAchievements points next to the avatar on the console grid: the
engine exposes only the on/off flag and the username to themes
(`global.cheevos`, `cheevosUser`); points are fetched only when the
RetroAchievements panel opens. A separate proposal (badge image rendered by
the Plaza server from the RetroAchievements web API) is with the author.

### Testing and verification performed

| Check | Result |
| --- | --- |
| `xmllint` on `theme.xml` | Pass |
| Engine source read: `NinePatchComponent::buildVertices`, `ButtonComponent::setText/onSizeChanged`, `BindingManager` global properties, `ThemeData` path parsing, Carbon theme reference | Done |
| RetroAchievements address check: `UserPic/MonsterGeeza.png` returns the author's picture; `UserPic/.png` returns the generic joystick seen on the device | Pass |
| New textures inspected at 4x | Pass |
| Both zips pass integrity checks; theme zip byte-identical to the folder | Pass |
| On the device: pill buttons in menus, avatar picture on the console grid | **Not performed** - required |

### Rollback plan

Install `v0.1.17`. In the repository, revert the merge.

---

## CR-0031 - Embedded Plaza updated to 0.1.7

| Field | Value |
| --- | --- |
| Change ID | CR-0031 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("build the stadium and look") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.19 (folder `v0.1.19/BatWiiCera`, zips `BatWiiCera-v0.1.19.zip`, `BatWiiCera-full-v0.1.19.zip`) |
| Previous version | 0.1.18 (folder `v0.1.18`, left unchanged) |
| Change type | Standard change (packaging) |
| Branch | `release/v0.1.19`, merged to `main` |
| Status | Approved by author, implemented |
| Approver | yiddifliddo |
| Approval date | 2026-10-05 |

### Description of change

`_plaza/` refreshed to Plaza 0.1.7 (PCR-0008): client, server package,
guides and licence. Installer, hook, system file, artwork and runtime are
unchanged in content. Full-install zip carries the new client under
`roms/plaza/`. Root `package.json` and `railway.json` start
`plaza/v0.1.7/server`; the public server redeploys as 0.1.7 on merge, which
the 0.1.6 client on the author's device tolerates (facings drawn wrongly
until 0.1.19 is installed). Theme views, colours and music unchanged. Not
pushed to the distribution repository (team reviewing 0.1.15).

### Testing and verification performed

| Check | Result |
| --- | --- |
| `xmllint` on `theme.xml`; both zips pass integrity checks; theme zip byte-identical to the folder | Pass |
| Plaza 0.1.7 tests and renders (PCR-0008) | Pass |
| On the device | **Not performed** - required |

### Rollback plan

Install `v0.1.18`. In the repository, revert the merge (server 0.1.6 and client 0.1.6 interoperate).

---

## CR-0032 - RetroAchievements avatar stuck on the default picture (corrects CR-0030)

| Field | Value |
| --- | --- |
| Change ID | CR-0032 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo ("I STILL don't have my proper retroachievements avatar") |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera - EmulationStation theme for Batocera |
| Version produced | 0.1.20 (folder `v0.1.20/BatWiiCera`, zips `BatWiiCera-v0.1.20.zip`, `BatWiiCera-full-v0.1.20.zip`) |
| Previous version | 0.1.19 (folder `v0.1.19`, left unchanged) |
| Change type | Corrective change |
| Branch | `release/v0.1.20`, merged to `main` |
| Status | Implemented; awaiting device confirmation |
| Approver | yiddifliddo |

### Root cause, corrected

CR-0030 stated that the address form `${global.cheevos.username}` was left
empty inside an image address and that RetroAchievements answered with a
"generic joystick for the unknown user". Checked again against the
engine source and the RetroAchievements server:

* The engine substitutes `${...}` variables when the theme is parsed, for
  every property type including paths (`ThemeData::parseElement` calls
  `resolvePlaceholders` before the type switch). The static form was never
  the problem.
* `UserPic/_User.png`, the picture RetroAchievements serves for an account
  with no picture, is the rainbow joystick seen on the device.
  `UserPic/MonsterGeeza.png` returns the author's own picture today.
* `WebImageComponent` caches each download under
  `configs/emulationstation/tmp/<host>/<path>` and, with the default cache
  duration of -1, never refreshes it. A default picture downloaded once
  (before the author's picture existed, or during a failed fetch) is shown
  for ever, whatever the theme does with the address form.

### Description of change

* `webimage ra-avatar` path: back to the parse-time form and suffixed with
  `?v=0120`. The engine includes a checksum of the query in the cache file
  name, so every theme release that changes the tag downloads afresh.
* Version 0.1.20 in `theme.xml`, `README.md`, `LICENSE`; root README and
  `package.json` version updated. Plaza embed unchanged (0.1.7).

### Testing and verification performed

| Check | Result |
| --- | --- |
| `xmllint` on `theme.xml`; zips pass integrity checks; theme zip byte-identical to the folder | Pass |
| `UserPic/_User.png` fetched and inspected: the rainbow joystick | Pass |
| `UserPic/MonsterGeeza.png` fetched and inspected: the author's picture | Pass |
| Engine source: cache path, query checksum, no expiry by default | Read |
| On the device after installing 0.1.20 | **Not performed** - required |

### Rollback plan

Install `v0.1.19`.

---

## CR-0033 - Root start scripts moved to Plaza 0.1.8

| Field | Value |
| --- | --- |
| Change ID | CR-0033 |
| Date raised | 2026-10-05 |
| Requested by | yiddifliddo |
| Author | yiddifliddo |
| Company / project | yiddifliddo (personal project) |
| Product | BatWiiCera repository (Railway deployment files) |
| Change type | Release |
| Status | Approved by author instruction, implemented |

`package.json` and `railway.json` start `plaza/v0.1.8/server/index.js`, which
adds the netplay relay (PCR-0009). Theme unchanged at 0.1.20. Rollback: point
both files back at `plaza/v0.1.7/server`.
