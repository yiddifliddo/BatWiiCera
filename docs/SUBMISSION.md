# Getting BatWiiCera into Batocera's Themes Downloader

Author: yiddifliddo. Status: distribution repository filled with 0.1.15 (CR-0026); listing request not yet posted.

## How the downloader works

* Batocera's *Main Menu > Updates & Downloads > Themes* reads a JSON feed
  maintained by the Batocera team at `https://batocera.org/upgrades/themes.json`
  (the same list drives https://batocera.org/themes.php). Each entry has a
  theme name, author, a GitHub repository URL, last update date, size and a
  screenshot path. There were 97 entries when checked.
* EmulationStation downloads the repository's default branch and installs it
  into `/userdata/themes/<repo-name>`. **`theme.xml` must therefore sit at the
  root of the repository's default branch.** Every listed theme is laid out
  that way.
* The list itself is not a public file that accepts pull requests. New
  themes are added by the team on request; the usual route is the Batocera
  Discord (themes channel) or the forum, with a link to the repository and a
  screenshot. Community themes with a Creative Commons non-commercial licence
  are already listed, so CC BY-NC-SA 4.0 is not a blocker.

## Why this repository cannot be listed directly

This repository keeps every version in its own `vX.Y.Z/` folder under change
control. A downloader fetch of this repository would get all versions and no
root `theme.xml`. The fix is a second, public, distribution-only repository.

## Steps

1. **Create the distribution repository** on GitHub, public, named
   `BatWiiCera-theme` (the repository name becomes the theme folder name on
   the device, so keep it tidy). Done: https://github.com/yiddifliddo/BatWiiCera-theme
2. **Fill it from the approved version** with the script in this repository,
   from any checkout that has both repositories (the cloud session used for
   this project does; nothing needs to be installed on a PC):

   ```
   tools/make-dist.sh 0.1.15 ../BatWiiCera-theme
   cd ../BatWiiCera-theme && git add -A && git commit -m "BatWiiCera 0.1.15" && git push
   ```

   The script mirrors `v0.1.15/BatWiiCera/` to the root, adds `preview.png`
   and a short README pointing back here. Re-run it for every approved
   release; the downloader then offers the update automatically. Done for
   0.1.15 (commit `545760f` there).
3. **Take a real screenshot** on the device for the request (the team shows
   one image per theme). `preview.png` is a layout mock-up; a photo of the
   console grid on your TV, or a capture through Batocera's screenshot
   hotkey, is better.
4. **Ask for the listing.** Post in the Batocera Discord themes channel or on
   https://forum.batocera.org (Themes section) with the text below. If the
   team asks for a different repository name or branch, adjust step 1 and
   re-run step 2.
5. **Record the outcome** in `CHANGE_CONTROL.md` as a new record (listing
   requested, listing accepted) so the theme's distribution status is
   tracked.

## Request text

> **Theme submission: BatWiiCera**
>
> Hi, I'd like to request that my theme is added to the Themes Downloader.
>
> * Name: BatWiiCera
> * Author: yiddifliddo
> * Repository (theme.xml at root): https://github.com/yiddifliddo/BatWiiCera-theme
> * Source and version history: https://github.com/yiddifliddo/BatWiiCera
> * Licence: CC BY-NC-SA 4.0 (reuses logo assets from Carbon and Art Book Next under the same licence, credited in LICENSE)
> * Size: about 26 MB
> * Screenshot: attached
> * Description: a retro console "channel menu" style theme. Console grid of
>   channel tiles with coloured logos, game list with live video preview,
>   grid view, RetroAchievements and save-state indicators, three colour sets
>   (classic grey, sky blue, dark grey), 16:9 and 4:3 layouts. Format version 7,
>   uses the system-view imagegrid, so it needs a current Batocera.
>
> Thanks!

## Checklist before asking

- [x] Distribution repository created, public, `theme.xml` at root
- [x] `tools/make-dist.sh` run for the approved version and pushed (0.1.15)
- [ ] Theme installs from a zip of that repository on a device and selects cleanly
- [ ] Screenshot taken on a device
- [ ] Request posted; record added to `CHANGE_CONTROL.md`
