class_name GeneratorItem

var uid:          String

var item_name:        String
var item_description: String
var upgrade_name:     String
var icon_path:        String

## Tabela quadrada achatada (1, 4, 9, 25, 64... elementos) onde 1 = célula
## ocupada e 0 = vazia. Ex: [1,0,0, 1,0,0, 0,0,0] é um formato 1x2 numa
## tabela 3x3. Consulte pelo get_cells()/get_size(), não pelo array cru.
var space:            Array
var level:            int
var rarity:           Enums.ItemRarity

## Cache do formato: offsets das células ocupadas, normalizados para o
## canto superior esquerdo do bounding box (linhas/colunas vazias da
## tabela são descartadas).
var _cells: Array[Vector2i] = []
var _size: Vector2i = Vector2i.ONE

func _init(_uid: String,_item_name: String, _item_description: String,_upgrade_name: String, _rarity: Enums.ItemRarity, _icon_path: String, _space: Array = [1]) -> void:
	self.uid              = _uid
	self.item_name        = _item_name
	self.item_description = _item_description
	self.upgrade_name     = _upgrade_name
	self.rarity           = _rarity
	self.level            = 1
	self.icon_path        = _icon_path
	self.space            = _space

## Células que o item ocupa, relativas à âncora (canto superior esquerdo).
func get_cells() -> Array[Vector2i]:
	if _cells.is_empty(): _parse_space()
	return _cells

## Bounding box do formato, em células.
func get_size() -> Vector2i:
	if _cells.is_empty(): _parse_space()
	return _size

func _parse_space() -> void:
	var side := int(round(sqrt(space.size())))
	if space.is_empty() or side * side != space.size():
		push_warning("GeneratorItem '%s': space com %d elementos não forma uma tabela quadrada; usando 1x1." % [item_name, space.size()])
		_cells = [Vector2i.ZERO]
		_size = Vector2i.ONE
		return

	var raw: Array[Vector2i] = []
	for i in range(space.size()):
		if int(space[i]) > 0:
			@warning_ignore("integer_division")
			raw.append(Vector2i(i % side, i / side))

	if raw.is_empty():
		push_warning("GeneratorItem '%s': space sem nenhuma célula ocupada; usando 1x1." % item_name)
		_cells = [Vector2i.ZERO]
		_size = Vector2i.ONE
		return

	var min_cell := raw[0]
	var max_cell := raw[0]
	for cell in raw:
		min_cell = min_cell.min(cell)
		max_cell = max_cell.max(cell)

	_cells = []
	for cell in raw:
		_cells.append(cell - min_cell)
	_size = max_cell - min_cell + Vector2i.ONE
