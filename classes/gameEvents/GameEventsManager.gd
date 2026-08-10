extends Node

# ============ EVENTS SIGNALS ============
#region Signals
signal player_money_changed(_new_value: BigNumber)
signal player_prestige_points_changed(_new_value: BigNumber)
signal player_money_production(_amount: BigNumber)

signal prestige_unlocked()
signal generator_unlocked()
signal upgrade_unlocked()

signal generator_bought(_generator_name: String)
signal upgrade_bought()

signal update_gen_info(_generator_name: String)
signal player_prestiged()

signal prepare_weaponize()
signal create_item_selection_screen(_determined_items: Array[GeneratorItem])

signal open_inventory(_generator_name: String)
signal open_upgrade_tooltip(_target: Upgrade, _uid: String, _position: float)
#endregion
# ============ EVENTS SIGNALS ============

func _ready() -> void:
	var player = Game.get_player()
	player.money_changed.connect(on_money_changed)
	player.gen_bought.connect(on_gen_bought)
	player.upgrade_bought.connect(on_upgrade_bought)
	player.prestige_points_changed.connect(on_player_prestige_points_changed)
	player.prestiged.connect(on_player_prestige)
	player.gen_unlocked.connect(on_gen_unlocked)
	
	self.prepare_weaponize.connect(on_prepare_weaponize)

func on_money_changed(_new_value: BigNumber):
	self.player_money_changed.emit(_new_value)
	if Game.get_player().total_money.greater_or_equal(10000000): self.prestige_unlocked.emit()

func on_gen_bought(_generator_name: String):
	self.generator_bought.emit(_generator_name)
	self.update_gen_info.emit(_generator_name)

func on_player_prestige():
	self.player_prestiged.emit()

func on_player_prestige_points_changed(_amount: BigNumber):
	self.player_prestige_points_changed.emit(_amount)

func on_upgrade_bought(_upgrade_name: String):
	self.upgrade_bought.emit(_upgrade_name)
	self.update_gen_info.emit("ALL")

func on_gen_unlocked(_generator_name: String):
	self.generator_unlocked.emit(_generator_name)

func on_prestige_reached():
	self.prestige_unlocked.emit()

func on_prepare_weaponize():
	var determined_items := ProductionCalculator.get_weaponize_items_selection()
	self.create_item_selection_screen.emit(determined_items)
