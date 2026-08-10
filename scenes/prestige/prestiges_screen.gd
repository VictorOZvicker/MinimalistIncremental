extends Control

func _ready() -> void:
	GameEventsManager.player_money_changed.connect(on_money_changed)
	load_prestige_upgrades()

func on_money_changed(_new_amount: BigNumber):
	var prestiges_to_gain = Game.get_player().get_prestige_gain()
	
	$ScrollContainer/VBoxContainer/PrestigeLabels/prestigeAmount.text = "Amount to gain: " + str(prestiges_to_gain)


func _on_prestige_button_pressed() -> void:
	Game.get_player().prestige()

func load_prestige_upgrades():
	var upgrade_node = preload("res://nodes/upgrades/UpgradeNode.tscn")
	var upgrades = $ScrollContainer/VBoxContainer/prestigeUpgrades.get_children()
	
	if not upgrades.is_empty():
		for child in upgrades:
			child.queue_free()
			
	for upgrade_name in DataLoader.get_all_upgrades():
		var current_upgrade             = upgrade_node.instantiate()
		var upgrade_definition: Upgrade = DataLoader.get_upgrade(upgrade_name)
		if upgrade_definition.currency != Enums.UpgradeCostTags.PRESTIGE: continue
		current_upgrade.definition      = upgrade_definition
		current_upgrade.upgrade_name    = upgrade_name
		$ScrollContainer/VBoxContainer/prestigeUpgrades.add_child(current_upgrade)
