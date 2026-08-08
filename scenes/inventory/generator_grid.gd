class_name GeneratorInventoryGrid
extends Control

## Grade de inventário estilo Resident Evil: cada item ocupa
## GeneratorItem.space células de 64px, e o mesmo item pode aparecer em
## várias cópias (cada instância é identificada pelo uid do
## GeneratorInventory). Aceita drops vindos do inventário do player,
## permite mover itens já colocados e desenha o preview de encaixe
## (verde = cabe, vermelho = bloqueado) na célula exata onde o item cairá.

const CELL_SIZE := 64
const InventorySlotScene := preload("res://scenes/inventory/InventorySlot.tscn")

signal player_item_dropped(_item: GeneratorItem, _cell: Vector2i)
signal item_moved(_uid: int, _cell: Vector2i)

var columns := 0
var lines := 0

var _placed: Dictionary[int, PlacedInventoryItem] = {}

var _preview_active := false
var _preview_valid := false
var _preview_anchor := Vector2i.ZERO
var _preview_space := Vector2i.ONE

@onready var _slots_grid: GridContainer = $slotsGrid
@onready var _items_layer: Control = $itemsLayer
@onready var _preview_layer: Control = $previewLayer

func _ready() -> void:
	_preview_layer.draw.connect(_on_preview_layer_draw)

func setup(_columns: int, _lines: int) -> void:
	self.columns = _columns
	self.lines = _lines
	_slots_grid.columns = _columns

	for child in _slots_grid.get_children():
		child.queue_free()
	for i in range(_columns * _lines):
		_slots_grid.add_child(InventorySlotScene.instantiate())

	var grid_px := _grid_pixel_size()
	_items_layer.size = grid_px
	_preview_layer.size = grid_px

func place_item(_uid: int, _item: GeneratorItem, _cell: Vector2i) -> void:
	if _item == null or _placed.has(_uid): return
	var node := PlacedInventoryItem.new()
	_items_layer.add_child(node)
	node.setup(_uid, _item, _cell, self)
	_placed[_uid] = node

func move_item(_uid: int, _cell: Vector2i) -> void:
	if _placed.has(_uid):
		_placed[_uid].set_cell(_cell)

func remove_item(_uid: int) -> void:
	if _placed.has(_uid):
		_placed[_uid].queue_free()
		_placed.erase(_uid)

## _ignore_uid: ao mover um item desta grade, o footprint antigo dele não
## conta como ocupado.
func can_place(_space: Vector2i, _anchor: Vector2i, _ignore_uid: int = -1) -> bool:
	if _anchor.x < 0 or _anchor.y < 0: return false
	if _anchor.x + _space.x > columns or _anchor.y + _space.y > lines: return false

	var footprint := Rect2i(_anchor, _space)
	for uid in _placed:
		if uid == _ignore_uid: continue
		var node := _placed[uid]
		if footprint.intersects(Rect2i(node.grid_cell, node.item.space)):
			return false
	return true

## O ghost do drag fica centralizado no cursor; a âncora é o canto
## superior esquerdo do item com esse centro, ajustado à célula mais próxima.
func anchor_for_mouse(_local_pos: Vector2, _space: Vector2i) -> Vector2i:
	var top_left := _local_pos - Vector2(_space * CELL_SIZE) / 2.0
	return Vector2i(((top_left + Vector2.ONE * (CELL_SIZE / 2.0)) / CELL_SIZE).floor())

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	var info := _drag_info(_data)
	if info.is_empty(): return false
	var item: GeneratorItem = info["item"]
	var anchor := anchor_for_mouse(_at_position, item.space)
	return can_place(item.space, anchor, _ignore_uid_of(info))

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	var info := _drag_info(_data)
	if info.is_empty(): return
	var item: GeneratorItem = info["item"]
	var anchor := anchor_for_mouse(_at_position, item.space)
	if info["source"] == "player":
		player_item_dropped.emit(item, anchor)
	else:
		item_moved.emit(info["uid"], anchor)

## Retorna {} quando _data não é um drag de item que esta grade aceita.
func _drag_info(_data: Variant) -> Dictionary:
	if typeof(_data) != TYPE_DICTIONARY: return {}
	if not (_data.has("source") and _data.has("item")): return {}
	# Itens de outra grade de gerador precisam passar pelo inventário do player.
	if _data["source"] == "generator" and (_data.get("grid") != self or not _data.has("uid")): return {}
	return _data

func _ignore_uid_of(_info: Dictionary) -> int:
	return _info["uid"] if _info["source"] == "generator" else -1

# ============================ preview ============================
# Atualizado por polling em _process (e não só em _can_drop_data) para
# sumir de forma confiável quando o cursor sai da grade ou o drag termina.

func _process(_delta: float) -> void:
	var was_active := _preview_active
	_preview_active = false

	var viewport := get_viewport()
	if viewport.gui_is_dragging():
		var info := _drag_info(viewport.gui_get_drag_data())
		if not info.is_empty():
			var mouse := _preview_layer.get_local_mouse_position()
			if Rect2(Vector2.ZERO, _grid_pixel_size()).has_point(mouse):
				var item: GeneratorItem = info["item"]
				_preview_active = true
				_preview_space = item.space
				_preview_anchor = anchor_for_mouse(mouse, item.space)
				_preview_valid = can_place(item.space, _preview_anchor, _ignore_uid_of(info))

	if _preview_active or was_active:
		_preview_layer.queue_redraw()

func _on_preview_layer_draw() -> void:
	if not _preview_active: return
	var fill   := Color(0.35, 1.0, 0.45, 0.28) if _preview_valid else Color(1.0, 0.3, 0.3, 0.32)
	var border := Color(0.5, 1.0, 0.6, 0.9)   if _preview_valid else Color(1.0, 0.4, 0.4, 0.9)

	for x in range(_preview_space.x):
		for y in range(_preview_space.y):
			var cell := _preview_anchor + Vector2i(x, y)
			if cell.x < 0 or cell.y < 0 or cell.x >= columns or cell.y >= lines: continue
			var cell_rect := Rect2(Vector2(cell * CELL_SIZE) + Vector2.ONE, Vector2.ONE * (CELL_SIZE - 2))
			_preview_layer.draw_rect(cell_rect, fill)

	var footprint_rect := Rect2(Vector2(_preview_anchor * CELL_SIZE), Vector2(_preview_space * CELL_SIZE))
	_preview_layer.draw_rect(footprint_rect, border, false, 2.0)

func _grid_pixel_size() -> Vector2:
	return Vector2(Vector2i(columns, lines) * CELL_SIZE)
