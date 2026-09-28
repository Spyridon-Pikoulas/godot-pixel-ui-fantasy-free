extends Control
## The kit in use: an RPG screen with the hero's portrait and bars, settings, an inventory of rarity
## slots, a quest scroll, a hotbar and a line of dialogue, all plain Controls styled by one Theme.
## The buttons along the bottom swap the theme.

const KIT := "res://addons/pixel_ui_fantasy/"
const ALL_THEMES: Array[String] = ["parchment", "leather", "iron", "gilded", "elven", "arcane"]
const ART_HEIGHT := 360.0
const FIRST := "gilded"

## Store capture only: switch to the next theme every this many frames.
@export var cycle_frames := 0

var frame := 0
var theme_buttons := {}


## Draws the UI at a whole-number scale so the art pixels stay square: the largest that still
## fits `art_height` pixels of art on screen.
static func pixel_scale(node: Node, art_height: float) -> void:
	var window := node.get_tree().root
	window.content_scale_factor = 1.0
	window.content_scale_factor = maxf(1.0, floorf(window.get_visible_rect().size.y / art_height))


static func themes() -> Array[String]:
	var installed: Array[String] = []
	for n in ALL_THEMES:
		if ResourceLoader.exists(KIT + "themes/%s.tres" % n):
			installed.append(n)
	return installed


## The named theme, or the first one installed.
static func kit_theme(name: String) -> Theme:
	return load(KIT + "themes/%s.tres" % (name if name in themes() else themes()[0]))


## Null when the icon isn't installed.
static func icon_texture(name: String) -> Texture2D:
	var path := KIT + "icons/%s.png" % name
	return load(path) if ResourceLoader.exists(path) else null


static func icon(name: String) -> TextureRect:
	var t := TextureRect.new()
	t.texture = icon_texture(name)
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	return t


## A titled window; add its content to the returned VBox.
static func window(parent: Control, title: String, at: Vector2, width: float) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"WindowPanel"
	panel.position = at
	panel.custom_minimum_size.x = width
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var label := Label.new()
	label.text = title
	label.theme_type_variation = &"Title"
	box.add_child(label)
	return box


static func row(parent: Control, separation := 3) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", separation)
	parent.add_child(h)
	return h


static func bar(parent: Control, colour: String, value: float, width: float) -> ProgressBar:
	var b := ProgressBar.new()
	if colour != "":
		b.theme_type_variation = StringName(colour + "Bar")
	b.show_percentage = false
	b.value = value
	b.custom_minimum_size = Vector2(width, 10)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(b)
	return b


static func slider(parent: Control, label: String, value: float) -> void:
	var r := row(parent)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size.x = 42
	r.add_child(l)
	var s := HSlider.new()
	s.value = value
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.add_child(s)


static func label(parent: Control, text: String, variation := &"") -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	parent.add_child(l)
	return l


## A 24x24 item slot (`rarity` "" for a plain one) holding an icon and a count above 1.
static func slot(parent: Control, item: String, count := 1, rarity := "") -> PanelContainer:
	var s := PanelContainer.new()
	s.theme_type_variation = StringName(rarity.capitalize() + "Slot") if rarity else &"InsetPanel"
	s.custom_minimum_size = Vector2(24, 24)
	parent.add_child(s)
	if item == "" or icon_texture(item) == null:
		return s
	var art := icon(item)
	art.tooltip_text = item.capitalize()
	s.add_child(art)
	if count > 1:
		var n := Label.new()
		n.text = str(count)
		n.add_theme_color_override("font_color", Color.WHITE)
		n.add_theme_color_override("font_shadow_color", Color.BLACK)
		art.add_child(n)
		n.position = Vector2(19, 6) - Vector2(n.get_minimum_size().x, 0)
	return s


## An icon at twice its size in the portrait frame, 48x48 in all.
static func portrait(parent: Control, item: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = &"PortraitPanel"
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var face := icon(item)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.custom_minimum_size = Vector2(32, 32)
	p.add_child(face)
	parent.add_child(p)
	return p


func _ready() -> void:
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST  # project.godot's, for a project without it
	pixel_scale(self, ART_HEIGHT)
	add_child(Backdrop.new())
	theme = kit_theme(FIRST)
	_hud()
	_settings()
	_inventory()
	_hotbar()
	_quests()
	_dialogue()
	var switcher := row(self, 3)
	switcher.position = Vector2(6, 334)
	var group := ButtonGroup.new()
	for name in themes():
		var b := Button.new()
		b.text = name.capitalize()
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = name == kit_theme(FIRST).resource_path.get_file().get_basename()
		b.toggled.connect(func(on: bool) -> void:
			if on:
				theme = kit_theme(name))
		switcher.add_child(b)
		theme_buttons[name] = b


func _process(_delta: float) -> void:
	if cycle_frames <= 0:
		return
	frame += 1
	if frame % cycle_frames == 0:
		var names := themes()
		var next: String = names[(maxi(0, names.find(FIRST)) + frame / cycle_frames) % names.size()]
		theme_buttons[next].button_pressed = true


func _hud() -> void:
	var top := row(self, 4)
	top.position = Vector2(6, 6)
	portrait(top, "helmet")
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 0)
	top.add_child(rows)
	label(rows, "Aria  Lv 7", &"Nameplate")
	for pair in [["heart", "Red", 72], ["mana", "Blue", 48], ["xp", "Gold", 64]]:
		var r := row(rows, 2)
		r.add_child(icon(pair[0]))
		bar(r, pair[1], pair[2], 96)
	var purse := PanelContainer.new()
	add_child(purse)
	var money := row(purse, 2)
	for pair in [["coin", "1250"], ["gem", "12"], ["key", "3"]]:
		money.add_child(icon(pair[0]))
		label(money, pair[1]).custom_minimum_size.x = 28
	purse.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 6)


func _settings() -> void:
	var box := window(self, "Settings", Vector2(6, 76), 166)
	slider(box, "Music", 70)
	slider(box, "Sound", 45)
	var hints := CheckBox.new()
	hints.text = "Show hints"
	hints.button_pressed = true
	box.add_child(hints)
	var group := ButtonGroup.new()
	var modes := row(box, 6)
	for m in ["Classic", "Heroic"]:
		var radio := CheckBox.new()
		radio.text = m
		radio.button_group = group
		radio.button_pressed = m == "Heroic"
		modes.add_child(radio)
	var speed := OptionButton.new()
	for s in ["Text: normal", "Text: fast", "Text: instant"]:
		speed.add_item(s)
	box.add_child(speed)
	var hero := LineEdit.new()
	hero.placeholder_text = "Hero name"
	box.add_child(hero)
	var buttons := row(box)
	for t in ["Back", "Apply"]:
		var b := Button.new()
		b.text = t
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buttons.add_child(b)


func _inventory() -> void:
	var box := window(self, "Inventory", Vector2(178, 30), 256)
	var tabs := TabContainer.new()
	box.add_child(tabs)
	var bag := GridContainer.new()
	bag.name = "Bag"
	bag.columns = 9
	bag.add_theme_constant_override("h_separation", 2)
	bag.add_theme_constant_override("v_separation", 2)
	tabs.add_child(bag)
	var items := [["sword", 1, "rare"], ["shield", 1, "uncommon"], ["bow", 1, "common"], ["staff", 1, "epic"],
		["amulet", 1, "legendary"], ["ring", 1, "rare"], ["potion_red", 5, "common"], ["potion_blue", 3, "common"],
		["potion_green", 2, "uncommon"], ["bread", 4, "common"], ["meat", 2, "common"], ["herb", 9, "common"],
		["mushroom", 3, "uncommon"], ["scroll", 2, "rare"], ["gem", 12, "epic"], ["key", 1, "common"],
		["", 1, ""], ["", 1, ""]]
	for it in items:
		var shown: bool = it[0] != "" and icon_texture(it[0]) != null
		slot(bag, it[0] if shown else "", it[1], it[2] if shown else "")
	var gear := VBoxContainer.new()
	gear.name = "Gear"
	tabs.add_child(gear)
	for pair in [["helmet", "Iron helm", "+4"], ["chestplate", "Knight's plate", "+9"], ["boots", "Swift boots", "+2"]]:
		var r := row(gear)
		slot(r, pair[0])
		var l := label(r, pair[1])
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label(r, pair[2])
	box.add_child(HSeparator.new())
	var weight := row(box)
	weight.add_child(icon("pouch"))
	label(weight, "Weight 34/50")
	bar(weight, "Green", 68, 0).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var actions := row(box)
	for pair in [["check", "Use"], ["cross", "Drop"], ["quest", "Info"]]:
		var b := Button.new()
		b.text = pair[1]
		b.icon = icon_texture(pair[0])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(b)


func _hotbar() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(183, 198)
	add_child(panel)
	var r := row(panel, 2)
	var keys := ["sword", "bow", "fireball", "frost", "lightning", "potion_red", "potion_blue", "torch", "map"]
	for i in keys.size():
		var s := slot(r, keys[i])
		var n := Label.new()
		n.text = str(i + 1)
		n.position = Vector2(3, -1)
		n.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		n.add_theme_color_override("font_shadow_color", Color.BLACK)
		s.add_child(n)
		n.set_anchors_preset(Control.PRESET_TOP_LEFT)


func _quests() -> void:
	var scroll := PanelContainer.new()
	scroll.theme_type_variation = &"ParchmentPanel"
	scroll.position = Vector2(442, 42)
	scroll.custom_minimum_size.x = 192
	add_child(scroll)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	scroll.add_child(box)
	var head := label(box, "Quest Log", &"Ribbon")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for q in [["check", "Find the lost key"], ["check", "Light the old beacon"], ["quest", "Slay the swamp troll"],
			["quest", "Return to the sage"], ["lock", "The sunken crypt"]]:
		var r := row(box, 3)
		r.add_child(icon(q[0]))
		label(r, q[1], &"Ink")
	label(box, "Reward: 300 gold", &"Ink").horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _dialogue() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(6, 262)
	panel.custom_minimum_size.x = 628
	add_child(panel)
	var r := row(panel, 6)
	portrait(r, "spellbook" if icon_texture("spellbook") else "scroll")
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(box)
	label(box, "Old Sage", &"Ribbon").size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	label(box, "The troll guards the bridge by night. Take this torch,\nand the frost scroll: fire alone won't do.")
	var next := Button.new()
	next.icon = icon_texture("arrow_right")
	next.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r.add_child(next)


## A dim dungeon wall behind the UI.
class Backdrop extends Control:
	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		show_behind_parent = true

	func _draw() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 11
		for y in range(0, 400, 12):
			var shift := 12 if (y / 12) % 2 else 0
			for x in range(-24, 700, 24):
				var v := rng.randf_range(0.08, 0.12)
				draw_rect(Rect2(x + shift, y, 23, 11), Color(v * 1.1, v * 0.9, v))
