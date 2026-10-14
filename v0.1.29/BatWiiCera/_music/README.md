# BatWiiCera - background music folder

This folder holds the audio EmulationStation plays while you browse when the
theme option **Background music** (*Main Menu > UI Settings > Theme Configuration*)
is set to **On** (the default from version 0.1.1).

## Bundled tracks

* `batwiicera-menu-theme.ogg` - the menu theme (2 min 54 s), supplied by the
  theme author, yiddifliddo. It is not a Nintendo recording. Lowered by 12 dB
  so it sits in the background. **Default.**
* `batwiicera-menu-loop.ogg` - a short, quiet bass loop (about 30 seconds,
  130 BPM, F minor), also supplied by the author. Trimmed to 16 bars and
  lowered by 14 dB.

## Choosing what plays

*Main Menu > UI Settings > Theme Configuration > Background music*:

| Choice | Plays |
| --- | --- |
| Menu theme | the menu theme, on repeat (default) |
| Quiet bass loop | the bass loop, on repeat |
| All tracks in _music (shuffle) | every audio file in this folder, including any you add |
| Off | nothing |

## Adding your own music

Drop any `.mp3`, `.ogg`, `.wav` or `.flac` files in this folder and choose
**All tracks in _music (shuffle)**. Delete the bundled files if you only want
your own.

## Volume

The theme cannot set the playback volume itself. Use
*Main Menu > Sound Settings > Music volume* to make it quieter or louder, and
make sure *Frontend music* is enabled there.

## Copyright

Only add audio you have the right to use. Nintendo's original console menu
music is copyrighted and must not be committed to this repository.
