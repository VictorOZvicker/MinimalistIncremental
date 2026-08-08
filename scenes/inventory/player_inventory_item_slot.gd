class_name PlayerInventoryItemSlot
extends Control

## Um slot 1x1 do armazenamento do player. Mostra um stack de itens e é a
## origem do drag em direção à grade do gerador.

var item: GeneratorItem
var count := 0

@onready var _icon_holder: Control = $iconHolder
@onready var _count_label: Label = $countLabel

func setup(_item: GeneratorItem, _count: int) -> void:
	self.item = _item
	self.count = _count

	for child in _icon_holder.get_children():
		child.queue_free()

	if item != null and count > 0:
		_icon_holder.add_child(InventoryItemVisual.create(item, _icon_holder.size, true))
		_count_label.text = "x%d" % count
		_count_label.visible = count > 1
		tooltip_text = "%s (%dx%d)\n%s" % [item.item_name, item.space.x, item.space.y, item.item_description]
	else:
		_count_label.visible = false
		tooltip_text = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item == null or count <= 0:
		return null
	self.modulate.a = 0.5
	set_drag_preview(InventoryItemVisual.make_drag_preview(item))
	return {
		"source": "player",
		"item": item,
	}

func _notification(_what: int) -> void:
	if _what == NOTIFICATION_DRAG_END:
		self.modulate.a = 1.0
