# BatWiiCera - background music folder

This folder holds the audio EmulationStation plays while you browse when the
theme option **Background music** (*Main Menu > UI Settings > Theme Configuration*)
is set to **On** (the default from version 0.1.1).

## Bundled track

* `batwiicera-menu-loop.ogg` - a short, quiet bass loop (about 30 seconds,
  130 BPM, F minor) supplied by the theme author, yiddifliddo. It was trimmed to
  16 bars and lowered by 14 dB so it sits in the background; EmulationStation
  repeats it continuously.

## Adding your own music

Drop any `.mp3`, `.ogg`, `.wav` or `.flac` files in this folder. EmulationStation
shuffles through every track it finds here. Delete the bundled loop if you only
want your own tracks.

## Volume

The theme cannot set the playback volume itself. Use
*Main Menu > Sound Settings > Music volume* to make it quieter or louder, and
make sure *Frontend music* is enabled there.

## Copyright

Only add audio you have the right to use. Nintendo's original console menu
music is copyrighted and must not be committed to this repository.
