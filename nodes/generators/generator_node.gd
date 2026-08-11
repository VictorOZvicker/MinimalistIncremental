class_name GeneratorNode extends Control

var generator_name: String
var definition: Generator

var cost: BigNumber
var amount: BigNumber
var production: BigNumber

func _ready() -> void:
	GameEventsManager.update_gen_info.connect(on_gen_updated)
	GameEventsManager.generator_unlocked.connect(on_unlock_generator)
	GameEventsManager.player_money_changed.connect(on_money_changed)

	if generator_name != "Red_Generator":
		self.hide()
		$EventWarningNew.show()

func _on_tree_entered() -> void:
	update_labels()
	if amount.greater_or_equal(1): $unlockBg.hide()
	$VBoxContainer/ProgressBar.set_generator_color(definition.gen_color)
	$VBoxContainer/ProgressBar.progress_complete.connect(on_production_timer_timeout)
	$Labels/generatorName.add_theme_color_override("font_color", definition.gen_color)
	$unlockBg/unlockLabel.text = "Unlock %s" % definition.generator_name

func set_generator(_generator_name: String):
	self.generator_name = _generator_name
	self.definition      = DataLoader.get_generator(_generator_name)
	update_labels()

func calculate_values() -> bool:
	if(definition == null): return false
	production = Game.get_player().get_generator_production(generator_name)
	cost = Game.get_player().get_generator_cost(generator_name)
	amount = Game.get_player().get_generator_amount(generator_name)
	return true 

func update_labels():
	if not calculate_values(): return
	$Labels/generatorName.text                  = definition.generator_name
	$Labels/generatorProduction.text            = "$ %s/s" % str(production.div(definition.wait_time_production))
	$buyButton/buttonsLabels/generatorCost.text = str(cost)
	$levelLabel.text                            = "# " + str(Game.get_player().get_generator_amount(self.generator_name))
	$unlockBg/priceLabel.text                   = str(cost)
	$buyButton/buttonsLabels/amountBought.text  = "(+" + str(Game.get_player().get_generator_buy_amount(self.generator_name))  + ")"
	$buyButton/buyIndicator.border_color = Color.GREEN if self.cost.less_or_equal(Game.get_player().money) else Color.RED

func on_buy_button_pressed():
	Game.get_player().buy_generator(generator_name)

func on_gen_updated(_generator_name: String):
	if _generator_name == self.generator_name or _generator_name == "ALL":
		update_labels()

func on_unlock_generator(_generator_name: String):
	if _generator_name == self.generator_name:
		$unlockBg.hide()
		$VBoxContainer/ProgressBar.start_timer(self.definition.wait_time_production)
		GameEventsManager.generator_unlocked.disconnect(on_unlock_generator)

func on_production_timer_timeout() -> void:
	if amount != null and amount.greater_or_equal(1):
		Game.get_player().produce(production)

func on_money_changed(_amount: BigNumber):
	if self.visible == false and _amount.greater_or_equal(cost.mul(0.6)):
		$EventWarningNew.start_timer()
		self.show()
	update_labels()

func _on_open_invetory_button_pressed() -> void:
	GameEventsManager.open_inventory.emit(generator_name)
