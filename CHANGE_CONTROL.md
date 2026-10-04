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
