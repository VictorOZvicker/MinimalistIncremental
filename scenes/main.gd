extends Control

var upgrade_tooltip: Control = null

func _ready() -> void:
	GameEventsManager.player_money_changed.connect(on_money_changed)
	GameEventsManager.player_prestige_points_changed.connect(on_player_prestige)
	GameEventsManager.open_inventory.connect(on_open_inventory)
	GameEventsManager.prestige_unlocked.connect(on_prestige_unlocked, CONNECT_ONE_SHOT)
	GameEventsManager.open_upgrade_tooltip.connect(on_upgrade_tooltip_opened)
	
func _process(_delta: float) -> void:
	pass

func change_screen(_screen_name: String):
	var screens = $screenSeparator/scoreBoardSeparator/screens.get_children()
	for child in screens:
		if child.name == _screen_name:
			child.show()
		else:
			child.hide()

func _on_generators_button_pressed() -> void:
	change_screen("GeneratorsScreen")

func _on_prestige_button_pressed() -> void:
	change_screen("PrestigesScreen")

func _on_weaponize_button_pressed() -> void:
	change_screen("WeaponizeScreen")
	GameEventsManager.prepare_weaponize.emit()

func on_money_changed(_amount: BigNumber):
	$screenSeparator/scoreBoardSeparator/ScoreBoard/scoreInformation/moneyLabel.text = "$: %s" % _amount

func on_player_prestige(_amount: BigNumber):
	$screenSeparator/scoreBoardSeparator/ScoreBoard/scoreInformation/prestigeLabel.text = "Prestiges: %s" % _amount

func on_open_inventory(_generator_name: String):
	var inventory_scene = load("res://scenes/inventory/InventoryScene.tscn").instantiate()
	inventory_scene.set_inventory(_generator_name)
	self.add_child(inventory_scene)
	inventory_scene.global_position = (Vector2(960, 540) - inventory_scene.size)/2
	inventory_scene.load_inventory()

func on_prestige_unlocked():
	$screenSeparator/menuBar/VBoxContainer/prestigeButton.show()

func on_upgrade_tooltip_opened(_target: Upgrade = null, _uid: String = "", _position: Vector2 = Vector2.ZERO):
	var clear_tooltip = func(): 
		upgrade_tooltip.queue_free()
		upgrade_tooltip = null
	if _target == null:
		clear_tooltip.call()
		return
	if upgrade_tooltip != null: 
		clear_tooltip.call()
	upgrade_tooltip = load("res://nodes/upgrades/UpgradeToolTip.tscn").instantiate()
	upgrade_tooltip.set_labels(_target, _uid)
	upgrade_tooltip.global_position = _position + Vector2(78, -16)
	add_child(upgrade_tooltip)
