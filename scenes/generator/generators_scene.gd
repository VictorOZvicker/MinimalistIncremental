extends Control



func _ready() -> void:
	GameEventsManager.reseted_progression.connect(on_reseted_progression)
	reload_generators()
	reload_upgrades()

func reload_generators():
	var generator_node := preload("res://nodes/generators/GeneratorNode.tscn")
	var prev_generators = $GeneratorsScroll/GeneratorsGrid.get_children()
	if not prev_generators.is_empty():
		for child in prev_generators:
			child.queue_free()
	
	var current_gen = null
	for generator_name in DataLoader.get_all_generators():
		current_gen = generator_node.instantiate()
		current_gen.set_generator(generator_name)
		$GeneratorsScroll/GeneratorsGrid.add_child(current_gen)

func on_reseted_progression():
	reload_generators()
	reload_upgrades()

func on_buy_amount_button_buy_amount_changed(_amount: int, _max: bool) -> void:
	Game.get_player().gen_buy_amount = _amount
	Game.get_player().max_gen_buy    = _max

func reload_upgrades():
	var upgrade_node = preload("res://nodes/upgrades/UpgradeNode.tscn")
	var upgradesGrid := $upgradesScroll/upgradesGrid
	var upgrades = upgradesGrid.get_children()
	
	if not upgrades.is_empty():
		for child in upgrades:
			child.queue_free()
	
	for upgrade_name in DataLoader.get_all_upgrades():
		var current_upgrade             = upgrade_node.instantiate()
		var upgrade_definition: Upgrade = DataLoader.get_upgrade(upgrade_name)
		if upgrade_definition.currency != Enums.UpgradeCostTags.MONEY: continue
		current_upgrade.definition      = upgrade_definition
		current_upgrade.upgrade_name    = upgrade_name
		upgradesGrid.add_child(current_upgrade)
