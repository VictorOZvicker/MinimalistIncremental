extends Control

var definition: Upgrade
var upgrade_name: String

var amount: int = 0

var tooltip: Control = null

func _ready():
	self.hide()
	if not definition.icon_path.is_empty():
		$iconArt.texture = load(definition.icon_path)
	GameEventsManager.player_money_changed.connect(on_money_changed)

func _on_buy_button_pressed() -> void:
	if Game.get_player().buy_upgrade(upgrade_name, definition.currency):
		amount = Game.get_player().get_upgrade_amount(upgrade_name)
		GameEventsManager.open_upgrade_tooltip.emit(self.definition, self.upgrade_name, self.global_position)
		update_upgrade_node()

func on_money_changed(_amount: BigNumber):
	if not self.visible and (_amount.greater_or_equal(definition.cost.mul(0.8)) or definition.currency == Enums.UpgradeCostTags.PRESTIGE):
		$EventWarningNew.start_timer()
		self.show()
	
	if _amount.greater_or_equal(Game.get_player().get_upgrade_cost(self.upgrade_name)): $buyIndicator.border_color = Color.GREEN
	else: $buyIndicator.border_color = Color.RED
	
func update_upgrade_node():
	if amount >= definition.buy_limit:
		self.queue_free()
		return

func _on_mouse_entered() -> void:
	GameEventsManager.open_upgrade_tooltip.emit(self.definition, self.upgrade_name, self.global_position)

func _on_mouse_exited() -> void:
	GameEventsManager.open_upgrade_tooltip.emit()
