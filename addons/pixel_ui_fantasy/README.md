# Pixel UI Fantasy

An RPG pixel-art GUI skin for Godot 4.3+: themes as ready-made `Theme` resources with trimmed
windows, rarity item slots, portrait frames, nameplates, ribbons, a parchment scroll and bar
frames, plus coloured icons, bar fills, a cursor and the Quill bitmap font. Every image is also a
plain PNG, with its 9-slice margins listed for any other engine.

## Use it in Godot

1. Copy `addons/pixel_ui_fantasy/` into your project.
2. Project Settings:
   - *Rendering > Textures > Default Texture Filter*: **Nearest**, or the pixels blur.
   - *GUI > Theme > Custom*: `res://addons/pixel_ui_fantasy/themes/gilded.tres` (or any theme),
     so every Control uses it. Or set `theme` on one Control and its children follow.
3. Draw the UI at a whole-number scale. The art is 1x (the font is 10px on a 13px line), made for
   a UI about 360 pixels high: set *Display > Window > Stretch > Mode* to `canvas_items` and either
   use a small viewport (for example 640x360), or keep yours and set
   `get_tree().root.content_scale_factor` to 2 or 3, as `demo/demo.gd` does.

## Themes

Each `themes/<name>.tres` styles Button, OptionButton, CheckBox (check and radio), Label, Panel,
PanelContainer, LineEdit, HSlider, ProgressBar, TabContainer, PopupMenu, tooltips, scroll bars and
HSeparator (an ornamental divider). Set `theme_type_variation` for the extras:

| Variation | On | Looks like |
|---|---|---|
| `WindowPanel` | PanelContainer | a window with a title bar; its first line of content sits in the bar |
| `Title` | Label | the text for that title bar |
| `InsetPanel` | PanelContainer | a sunken item slot, 24x24 around a 16px icon |
| `CommonSlot`, `UncommonSlot`, `RareSlot`, `EpicSlot`, `LegendarySlot` | PanelContainer | the slot rimmed and lit in its rarity's colour (grey, green, blue, purple, orange) |
| `PortraitPanel` | PanelContainer | a heavy riveted frame for a face or a big icon, 8px in from each side |
| `ParchmentPanel` | PanelContainer | a paper scroll between two wooden rolls, the same in every theme |
| `Ink` | Label | dark text for the parchment |
| `Nameplate` | Label | text on a trim-coloured plate |
| `Ribbon` | Label | text on a banner with forked tails |
| `RedBar`, `BlueBar`, `GreenBar`, `GoldBar` | ProgressBar | health, mana, stamina and experience fills |

A window: PanelContainer (`WindowPanel`) > VBoxContainer > Label (`Title`) first, then the content.
The shared variation names are the same as in Pixel UI and Pixel UI Sci-Fi, so a project can
switch between the kits by switching its theme.

## Icons

The icons are coloured, with a dark outline. The themes leave Button icons untinted (and fade them
when disabled). `icons/_sheet.png` has them all on one 8-column sheet.

## Other engines

Every part is a PNG in `themes/<name>/`. `themes/slices.json` lists each one's 9-slice borders
(left, top, right, bottom, in pixels; the same in every theme):

| Parts | Borders |
|---|---|
| `button_*`, `panel_inset`, `slot_*` | 5, 5, 5, 5 |
| `panel` | 6, 6, 6, 6, with the grainy middle **tiled**, not stretched |
| `window` | 6, 19, 6, 6 (the title bar is rows 4 to 16), middle tiled |
| `parchment` | 6, 9, 6, 9, middle tiled |
| `portrait` | 9, 9, 9, 9 |
| `nameplate` | 5, 4, 5, 4 |
| `ribbon` | 9, 3, 9, 5 |
| `divider` | 8, 0, 8, 0 (7 rows tall) |
| `focus` | 4, 4, 4, 4 |
| `line_edit` | 4, 4, 4, 4 |
| `progress_bg` | 4, 3, 4, 3 |
| `progress_fill`, `bars/bar_*` | 5, 2, 5, 2, drawn over the whole bar: their colour sits inside `progress_bg`'s frame |
| `tooltip` | 3, 3, 3, 3 |
| `slider`, `slider_fill` | 3, 2, 3, 2 |
| `tab_selected` | 4, 4, 4, 1 |
| `tab_unselected`, `tab_hover` | 4, 5, 4, 2 |
| `scroll*`, `menu_hover` | 2, 2, 2, 2 |

The rest are drawn as they are: `checkbox_*` and `radio_*` (11x11), `grabber*` (7x11), `arrow`
(the option button's, 7x4).

## Files

- `themes/<name>.tres` and `themes/<name>/*.png`: the Theme and its parts.
- `icons/*.png`: 16x16, coloured, outlined, on a transparent background.
- `bars/bar_*.png`: the bar fills.
- `cursor.png` and `cursor_2x/3x/4x.png`: a gold pointer, hotspot at the top-left pixel. The OS
  draws cursors unscaled, so pick the copy that matches your UI scale for *Display > Mouse Cursor >
  Custom Image*.
- `font/pixel_ui_fantasy_font.fnt`: Quill, a proportional serif BMFont with printable ASCII and
  Latin-1, 10px on a 13px line. Keep it at size 10 and scale the UI instead.
