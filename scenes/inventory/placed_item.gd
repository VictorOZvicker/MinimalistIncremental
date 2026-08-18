class_name PlacedInventoryItem
extends Control

## Uma instância de item colocada na grade do gerador (identificada pelo
## uid do GeneratorInventory), ocupando as células do seu formato
## (GeneratorItem.get_cells). Arraste-a para movê-la dentro da grade ou
## para devolvê-la ao inventário do player.

const CELL_SIZE := 64

var uid: int = -1
var item: GeneratorItem
var grid_cell: Vector2i
var source_grid: Control

func setup(_uid: int, _item: GeneratorItem, _cell: Vector2i, _source_grid: Control) -> void:
	self.uid = _uid
	self.item = _item
	self.source_grid = _source_grid
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	self.size = Vector2(item.get_size() * CELL_SIZE)
	add_child(InventoryItemVisual.create(item, self.size))
	set_cell(_cell)

func set_cell(_cell: Vector2i) -> void:
	self.grid_cell = _cell
	self.position = Vector2(_cell * CELL_SIZE)

## Hit-test pelo formato real: cantos vazios do bounding box (formatos em
## L, etc.) não pegam o mouse — cliques ali passam para o que está atrás.
func _has_point(_point: Vector2) -> bool:
	if item == null: return false
	var cell := Vector2i((_point / CELL_SIZE).floor())
	return cell in item.get_cells()

func _get_drag_data(_at_position: Vector2) -> Variant:
	self.modulate.a = 0.4
	set_drag_preview(InventoryItemVisual.make_drag_preview(item))
	return {
		"source": "generator",
		"uid": uid,
		"item": item,
		"grid": source_grid,
	}

func _notification(_what: int) -> void:
	if _what == NOTIFICATION_DRAG_END:
		self.modulate.a = 1.0
