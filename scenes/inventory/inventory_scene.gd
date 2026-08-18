extends Control

## Tela de inventário: armazenamento do player (stacks 1x1) à direita e a
## grade do gerador à esquerda. Todo o estado de posicionamento vive nos
## modelos (Player.items / GeneratorInventory), então sobrevive ao fechar
## e reabrir a tela.
##
## Identidade: os dicionários de inventário usam a CHAVE do item em
## items.json (GeneratorItem.item_id, ex. "Battery_Item"); item_name é
## apenas o nome de exibição. Cada cópia colocada na grade tem um uid
## próprio do GeneratorInventory, então duplicatas são permitidas.

var generator_name: String

var _model: GeneratorInventory

@onready var _grid: GeneratorInventoryGrid = $screenSeparator/generatorArea
@onready var _player_panel: PlayerInventoryPanel = $screenSeparator/PlayerInventory

func set_inventory(_generator_name: String):
	generator_name = _generator_name

func load_inventory():
	var player: Player = Game.get_player()

	player.initialize_generator_inventory(generator_name)
	_model = player.get_generator_inventory(generator_name)

	$inventoryOwnerLabel.text = "%s's Inventory" % generator_name

	_grid.setup(_model.columns, _model.rows)
	_grid.player_item_dropped.connect(_on_player_item_dropped)
	_grid.item_moved.connect(_on_item_moved)

	_player_panel.accepted_grid = _grid
	_player_panel.item_returned.connect(_on_item_returned)
	_player_panel.refresh(player.items)

	for uid in _model.items:
		_grid.place_item(uid, DataLoader.get_item(_model.get_item_name(uid)), _model.get_item_position(uid))

func _on_player_item_dropped(_item: GeneratorItem, _cell: Vector2i) -> void:
	var item_id := _item.uid
	var uid := _model.insert_item(item_id, _cell)
	if uid < 0: return
	
	GameEventsManager.player_placed_item(_item.uid, _cell, self.generator_name)
	
	_grid.place_item(uid, _item, _cell)
	_player_panel.refresh(Game.get_player().items)

func _on_item_moved(_uid: int, _cell: Vector2i) -> void:
	if _model.move_item(_uid, _cell):
		_grid.move_item(_uid, _cell)

func _on_item_returned(_uid: int) -> void:
	var player: Player = Game.get_player()
	var item_id := _model.get_item_name(_uid)
	if item_id == "": return

	_model.remove_item(_uid)
	_grid.remove_item(_uid)
	player.items[item_id] = player.items.get(item_id, 0) + 1
	_player_panel.refresh(player.items)

func _on_button_pressed() -> void:
	self.queue_free()
