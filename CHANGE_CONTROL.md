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
screenshots held in the repository root. Navigation is console first, then
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
