class_name GeneratorInventory

var columns: int
var rows:   int

## uid da instância -> {"item_name": String, "position": Vector2i}.
## "item_name" guarda a CHAVE do item em items.json (GeneratorItem.item_id);
## o uid permite colocar várias cópias do mesmo item.
var items: Dictionary[int, Dictionary]

var _next_uid: int = 0

signal item_placed(_item_name:  String)
signal item_removed(_item_name: String)

func _init(_columns: int = 5, _rows: int = 5) -> void:
	self.columns = _columns
	self.rows   = _rows

## Retorna o uid da instância colocada, ou -1 se a posição for inválida.
func insert_item(_item_uid: String, _position: Vector2i) -> int:
	if not check_item_position(_item_uid, _position): return -1
	var uid := _next_uid
	_next_uid += 1
	self.items[uid] = {"item_name": _item_uid, "position": _position}
	item_placed.emit(_item_uid)
	return uid

func move_item(_uid: int, _position: Vector2i) -> bool:
	if not self.items.has(_uid): return false
	if not check_item_position(get_item_name(_uid), _position, _uid): return false
	self.items[_uid]["position"] = _position
	return true

func remove_item(_uid: int):
	if not self.items.has(_uid): return
	var _item_name := get_item_name(_uid)
	self.items.erase(_uid)
	item_removed.emit(_item_name)

func get_item_name(_uid: int) -> String:
	if not self.items.has(_uid): return ""
	return self.items.get(_uid, {}).get("item_name", "NOT FOUND")

func get_item_position(_uid: int) -> Vector2i:
	if not self.items.has(_uid): return Vector2i(-1, -1)
	return self.items[_uid]["position"]

## Quantas cópias de um item estão colocadas neste inventário.
func count_item(_item_name: String) -> int:
	var total := 0
	for uid in self.items:
		if get_item_name(uid) == _item_name: total += 1
	return total

## Todas as células do formato do item (GeneratorItem.get_cells) cabem na
## grade e não sobrepõem células de outros itens. _ignore_uid: ao mover um
## item, o espaço antigo dele não conta como ocupado.
func check_item_position(_item_name: String, _position: Vector2i, _ignore_uid: int = -1) -> bool:
	var occupied := get_occupied_cells(_ignore_uid)
	for cell in _item_cells(_item_name):
		var abs_cell: Vector2i = _position + cell
		if abs_cell.x < 0 or abs_cell.y < 0: return false
		if abs_cell.x >= self.columns or abs_cell.y >= self.rows: return false
		if occupied.has(abs_cell): return false
	return true

## Conjunto (célula -> true) de todas as células ocupadas pelos itens
## colocados, nas coordenadas da grade.
func get_occupied_cells(_ignore_uid: int = -1) -> Dictionary:
	var occupied := {}
	for uid in self.items:
		if uid == _ignore_uid: continue
		var origin := get_item_position(uid)
		for cell in _item_cells(get_item_name(uid)):
			occupied[origin + cell] = true
	return occupied

static func _item_cells(_item_name: String) -> Array[Vector2i]:
	var item := DataLoader.get_item(_item_name)
	if item == null: return [Vector2i.ZERO]
	return item.get_cells()

func get_item_upgrades() -> Dictionary:
	var upgrade_names: Dictionary = {}
	for uid in self.items.keys():
		var item: GeneratorItem = DataLoader.get_item(self.get_item_name(uid))
		upgrade_names[item.upgrade_name] = upgrade_names.get_or_add(item.upgrade_name, 0) + 1
	return upgrade_names
