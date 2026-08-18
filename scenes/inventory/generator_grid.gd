class_name GeneratorInventoryGrid
extends Control

## Grade de inventário estilo Resident Evil: cada item ocupa as células do
## seu formato (GeneratorItem.get_cells, tabela de células de 64px), que
## não precisa ser retangular. O mesmo item pode aparecer em várias cópias
## (cada instância é identificada pelo uid do GeneratorInventory). Aceita
## drops vindos do inventário do player, permite mover itens já colocados
## e desenha o preview de encaixe (verde = cabe, vermelho = bloqueado) nas
## células exatas onde o item cairá.

const CELL_SIZE := 64
const InventorySlotScene := preload("res://scenes/inventory/InventorySlot.tscn")

signal player_item_dropped(_item: GeneratorItem, _cell: Vector2i)
signal item_moved(_uid: int, _cell: Vector2i)

var columns := 0
var lines := 0

var _placed: Dictionary[int, PlacedInventoryItem] = {}

var _preview_active := false
var _preview_valid := false
var _preview_cells: Array[Vector2i] = []

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

## Todas as células do formato cabem na grade sem sobrepor outros itens.
## _ignore_uid: ao mover um item desta grade, o footprint antigo dele não
## conta como ocupado.
func can_place(_item: GeneratorItem, _anchor: Vector2i, _ignore_uid: int = -1) -> bool:
	if _item == null: return false

	var occupied := {}
	for uid in _placed:
		if uid == _ignore_uid: continue
		var node := _placed[uid]
		for cell in node.item.get_cells():
			occupied[node.grid_cell + cell] = true

	for cell in _item.get_cells():
		var abs_cell: Vector2i = _anchor + cell
		if abs_cell.x < 0 or abs_cell.y < 0: return false
		if abs_cell.x >= columns or abs_cell.y >= lines: return false
		if occupied.has(abs_cell): return false
	return true

## O ghost do drag fica centralizado no cursor; a âncora é o canto
## superior esquerdo do bounding box do item com esse centro, ajustado à
## célula mais próxima.
func anchor_for_mouse(_local_pos: Vector2, _item: GeneratorItem) -> Vector2i:
	var top_left := _local_pos - Vector2(_item.get_size() * CELL_SIZE) / 2.0
	return Vector2i(((top_left + Vector2.ONE * (CELL_SIZE / 2.0)) / CELL_SIZE).floor())

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	var info := _drag_info(_data)
	if info.is_empty(): return false
	var item: GeneratorItem = info["item"]
	var anchor := anchor_for_mouse(_at_position, item)
	return can_place(item, anchor, _ignore_uid_of(info))

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	var info := _drag_info(_data)
	if info.is_empty(): return
	var item: GeneratorItem = info["item"]
	var anchor := anchor_for_mouse(_at_position, item)
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
				var anchor := anchor_for_mouse(mouse, item)
				_preview_active = true
				_preview_valid = can_place(item, anchor, _ignore_uid_of(info))
				_preview_cells = []
				for cell in item.get_cells():
					_preview_cells.append(anchor + cell)

	if _preview_active or was_active:
		_preview_layer.queue_redraw()

func _on_preview_layer_draw() -> void:
	if not _preview_active: return
	var fill   := Color(0.35, 1.0, 0.45, 0.28) if _preview_valid else Color(1.0, 0.3, 0.3, 0.32)
	var border := Color(0.5, 1.0, 0.6, 0.9)   if _preview_valid else Color(1.0, 0.4, 0.4, 0.9)

	var cell_set := {}
	for cell in _preview_cells:
		cell_set[cell] = true

	for cell in _preview_cells:
		var origin := Vector2(cell * CELL_SIZE)
		_preview_layer.draw_rect(Rect2(origin + Vector2.ONE, Vector2.ONE * (CELL_SIZE - 2)), fill)

		# Contorno do formato: desenha só as arestas sem célula vizinha do
		# próprio item, seguindo o desenho exato (não o bounding box).
		if not cell_set.has(cell + Vector2i.LEFT):
			_preview_layer.draw_line(origin, origin + Vector2(0, CELL_SIZE), border, 2.0)
		if not cell_set.has(cell + Vector2i.RIGHT):
			_preview_layer.draw_line(origin + Vector2(CELL_SIZE, 0), origin + Vector2(CELL_SIZE, CELL_SIZE), border, 2.0)
		if not cell_set.has(cell + Vector2i.UP):
			_preview_layer.draw_line(origin, origin + Vector2(CELL_SIZE, 0), border, 2.0)
		if not cell_set.has(cell + Vector2i.DOWN):
			_preview_layer.draw_line(origin + Vector2(0, CELL_SIZE), origin + Vector2(CELL_SIZE, CELL_SIZE), border, 2.0)

func _grid_pixel_size() -> Vector2:
	return Vector2(Vector2i(columns, lines) * CELL_SIZE)
