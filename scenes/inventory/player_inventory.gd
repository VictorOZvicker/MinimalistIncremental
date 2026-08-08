class_name PlayerInventoryPanel
extends Control

## Armazenamento do player: todo item ocupa um slot fixo de 1x1 (com
## contador de stack), independente do tamanho real que ele tem na grade
## do gerador. Também é o alvo de drop para devolver itens do gerador.

const SlotScene := preload("res://scenes/inventory/PlayerInventoryItemSlot.tscn")
const COLUMNS := 6
const ROWS := 5

signal item_returned(_uid: int)

## Única grade de gerador com a qual este painel troca itens.
var accepted_grid: Control

var _drop_highlight := false

@onready var _grid: GridContainer = $GridContainer
@onready var _highlight_layer: Control = $highlightLayer

func _ready() -> void:
	_highlight_layer.draw.connect(_on_highlight_layer_draw)

func refresh(_items: Dictionary) -> void:
	_ensure_slots()
	var names := _items.keys()
	names.sort()

	var slots := _grid.get_children()
	for i in range(slots.size()):
		var slot := slots[i] as PlayerInventoryItemSlot
		if i < names.size():
			slot.setup(DataLoader.get_item(names[i]), _items[names[i]])
		else:
			slot.setup(null, 0)

func _ensure_slots() -> void:
	if _grid.get_child_count() > 0: return
	for i in range(COLUMNS * ROWS):
		_grid.add_child(SlotScene.instantiate())

func _accepts(_data: Variant) -> bool:
	return typeof(_data) == TYPE_DICTIONARY \
		and _data.get("source") == "generator" \
		and _data.get("grid") == accepted_grid \
		and _data.has("uid")

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return _accepts(_data)

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	if _accepts(_data):
		item_returned.emit(_data["uid"])

func _notification(_what: int) -> void:
	match _what:
		NOTIFICATION_DRAG_BEGIN:
			_drop_highlight = _accepts(get_viewport().gui_get_drag_data())
			_highlight_layer.queue_redraw()
		NOTIFICATION_DRAG_END:
			_drop_highlight = false
			_highlight_layer.queue_redraw()

## Borda indicando que o item arrastado pode ser solto aqui para devolver.
func _on_highlight_layer_draw() -> void:
	if _drop_highlight:
		_highlight_layer.draw_rect(Rect2(Vector2.ZERO, _highlight_layer.size), Color(0.5, 1.0, 0.6, 0.8), false, 2.0)
