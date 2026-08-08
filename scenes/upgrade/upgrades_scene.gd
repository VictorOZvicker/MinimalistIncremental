extends Control

func reload_upgrades():
	var upgrade_node = preload("res://nodes/upgrades/UpgradeNode.tscn")
	var upgrades = $ScrollContainer/moneyUpgrade.get_children()
	
	if not upgrades.is_empty():
		for child in upgrades:
			child.queue_free()
	
	for upgrade_name in DataLoader.get_all_upgrades():
		var current_upgrade             = upgrade_node.instantiate()
		var upgrade_definition: Upgrade = DataLoader.get_upgrade(upgrade_name)
		if upgrade_definition.currency != Enums.UpgradeCostTags.MONEY: continue
		current_upgrade.definition      = upgrade_definition
		current_upgrade.upgrade_name    = upgrade_name
		$ScrollContainer/moneyUpgrade.add_child(current_upgrade)

func on_player_prestige():
	reload_upgrades()
