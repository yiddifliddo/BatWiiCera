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
