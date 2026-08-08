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

func _init(_columns: int = 3, _rows: int = 3) -> void:
	self.columns = _columns
	self.rows   = _rows

## Retorna o uid da instância colocada, ou -1 se a posição for inválida.
func insert_item(_item_name: String, _position: Vector2i) -> int:
	if not check_item_position(_item_name, _position): return -1
	var uid := _next_uid
	_next_uid += 1
	self.items[uid] = {"item_name": _item_name, "position": _position}
	item_placed.emit(_item_name)
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
	return self.items[_uid]["item_name"]

func get_item_position(_uid: int) -> Vector2i:
	if not self.items.has(_uid): return Vector2i(-1, -1)
	return self.items[_uid]["position"]

## Quantas cópias de um item estão colocadas neste inventário.
func count_item(_item_name: String) -> int:
	var total := 0
	for uid in self.items:
		if get_item_name(uid) == _item_name: total += 1
	return total

## O footprint (tamanho real do item, GeneratorItem.space) cabe na grade e
## não sobrepõe nenhum outro item colocado. _ignore_uid: ao mover um item,
## o espaço antigo dele não conta como ocupado.
func check_item_position(_item_name: String, _position: Vector2i, _ignore_uid: int = -1) -> bool:
	var space := _item_space(_item_name)
	if _position.x < 0 or _position.y < 0: return false
	if _position.x + space.x > self.columns or _position.y + space.y > self.rows: return false

	var footprint := Rect2i(_position, space)
	for uid in self.items:
		if uid == _ignore_uid: continue
		var placed_rect := Rect2i(get_item_position(uid), _item_space(get_item_name(uid)))
		if footprint.intersects(placed_rect):
			return false
	return true

static func _item_space(_item_name: String) -> Vector2i:
	var item := DataLoader.get_item(_item_name)
	return item.space if item != null else Vector2i.ONE

func get_item_upgrades() -> Dictionary:
	var upgrade_names: Dictionary = {}
	for uid in self.items.keys():
		var item: GeneratorItem = DataLoader.get_item(get_item_name(uid))
		upgrade_names[item.upgrade_name] = upgrade_names.get_or_add(item.upgrade_name, 0) + 1
	return upgrade_names
