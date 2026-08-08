extends Node

var events: GameEvents

func _ready() -> void:
	events = GameEvents.new()
	var player = Game.get_player()
	player.money_changed.connect(on_money_changed)
	player.gen_bought.connect(on_gen_bought)
	player.upgrade_bought.connect(on_upgrade_bought)
	player.prestige_points_changed.connect(on_player_prestige_points_changed)
	player.prestiged.connect(on_player_prestige)
	player.gen_unlocked.connect(on_gen_unlocked)


func on_money_changed(_new_value: BigNumber):
	events.player_money_changed.emit(_new_value)
	if Game.get_player().total_money.greater_or_equal(10000000): self.events.prestige_unlocked.emit()

func on_gen_bought(_generator_name: String):
	events.generator_bought.emit(_generator_name)
	events.update_gen_info.emit(_generator_name)

func on_player_prestige():
	events.player_prestiged.emit()

func on_player_prestige_points_changed(_amount: BigNumber):
	events.player_prestige_points_changed.emit(_amount)

func on_upgrade_bought(_upgrade_name: String):
	events.upgrade_bought.emit(_upgrade_name)
	events.update_gen_info.emit("ALL")

func on_gen_unlocked(_generator_name: String):
	self.events.generator_unlocked.emit(_generator_name)

func on_prestige_reached():
	self.events.prestige_unlocked.emit()

func on_warning_new(_position: Vector2):
	self.events.warning_new.emit(_position)
