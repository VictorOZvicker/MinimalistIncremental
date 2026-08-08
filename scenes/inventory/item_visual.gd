class_name InventoryItemVisual

## Constrói o visual de um item: o ícone (icon_path) quando ele existe,
## senão um painel colorido com o nome — cor derivada do nome do item.

const CELL_SIZE := 64

static func create(_item: GeneratorItem, _px_size: Vector2, _compact := false) -> Control:
	var root: Control
	if _item.icon_path != "" and ResourceLoader.exists(_item.icon_path):
		var icon := TextureRect.new()
		icon.texture = load(_item.icon_path)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		root = icon
	else:
		root = _make_colored_panel(_item, _compact)
	root.custom_minimum_size = _px_size
	root.size = _px_size
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return root

## Ghost que segue o cursor durante o drag: item em escala do gerador,
## semitransparente e centralizado no mouse (mesma âncora usada pelo snap).
static func make_drag_preview(_item: GeneratorItem) -> Control:
	var px := Vector2(_item.space * CELL_SIZE)
	var wrapper := Control.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var visual := create(_item, px)
	visual.position = -px / 2.0
	visual.modulate.a = 0.65
	wrapper.add_child(visual)
	return wrapper

static func color_for(_item_name: String) -> Color:
	var hue := float(absi(_item_name.hash()) % 360) / 360.0
	return Color.from_hsv(hue, 0.55, 0.7)

static func _make_colored_panel(_item: GeneratorItem, _compact: bool) -> Control:
	var panel := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color_for(_item.item_name)
	style.border_color = style.bg_color.darkened(0.35)
	style.set_corner_radius_all(6)
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = _initials(_item.item_name) if _compact else _item.item_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.add_theme_font_size_override("font_size", 10 if _compact else 12)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("outline_size", 3)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(label)
	return panel

static func _initials(_item_name: String) -> String:
	var initials := ""
	for word in _item_name.split(" ", false):
		initials += word.substr(0, 1).to_upper()
		if initials.length() >= 2: break
	return initials
