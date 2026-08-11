class_name ProductionCalculator


static func get_generator_cost(_generator_name: String, _amount_owned: BigNumber, _upgrades: Dictionary, _buy_amount: int = 1) -> BigNumber:
	var definition := DataLoader.get_generator(_generator_name)
	if definition == null:
		return BigNumber.new(0)

	var price_reduction := BigNumber.new(1)
	var buy_amount := maxi(_buy_amount, 1)

	for upgrade_name in _upgrades:
		var times_bought: int = _upgrades[upgrade_name]
		var upgrade := DataLoader.get_upgrade(upgrade_name)
		if upgrade == null or times_bought <= 0 or not definition.has_any_tag(upgrade.tags):
			continue

		price_reduction = upgrade.upgrade_effect.apply_upgrade(price_reduction,times_bought, Enums.UpgradeBonusTags.PRICE)

	var unit_cost := definition.base_cost.mul(BigNumber.new(definition.cost_increase).bigNumber_pow(_amount_owned.to_float())).mul(price_reduction)

	if buy_amount == 1:
		return unit_cost

	if is_equal_approx(definition.cost_increase, 1.0):
		return unit_cost.mul(buy_amount)

	var ratio := BigNumber.new(definition.cost_increase)
	var series_sum := ratio.bigNumber_pow(float(buy_amount)).sub(BigNumber.new(1)).div(BigNumber.new(definition.cost_increase - 1.0))

	return unit_cost.mul(series_sum)

static func get_max_affordable_generator_amount(_generator_name: String, _amount_owned: BigNumber, _upgrades: Dictionary, _money: BigNumber) -> int:
	var definition := DataLoader.get_generator(_generator_name)
	if definition == null:
		return 0

	var unit_cost := get_generator_cost(_generator_name, _amount_owned, _upgrades, 1)
	if _money.less_than(unit_cost):
		return 0

	var estimate: int

	if is_equal_approx(definition.cost_increase, 1.0):
		estimate = maxi(int(_money.div(unit_cost).to_float()), 1)
	else:
		var log_r := log(definition.cost_increase) / log(10.0)
		var log_bracket := _money.log10() + (log(definition.cost_increase - 1.0) / log(10.0)) - unit_cost.log10()
		estimate = maxi(int(floor(log_bracket / log_r)), 1)

	var safety := 0
	while estimate > 1 and safety < 64 and get_generator_cost(_generator_name, _amount_owned, _upgrades, estimate).greater_than(_money):
		estimate -= 1
		safety += 1

	safety = 0
	while safety < 64 and get_generator_cost(_generator_name, _amount_owned, _upgrades, estimate + 1).less_or_equal(_money):
		estimate += 1
		safety += 1

	return estimate

static func get_upgrade_cost(_upgrade_name: String, _times_bought: int, _buy_amount: int = 1) -> BigNumber:
	var definition := DataLoader.get_upgrade(_upgrade_name)
	if definition == null:
		return BigNumber.new(0)

	var buy_amount := maxi(_buy_amount, 1)
	var unit_cost := definition.cost.mul(BigNumber.new(definition.cost_increase).bigNumber_pow(_times_bought))

	if buy_amount == 1:
		return unit_cost

	if is_equal_approx(definition.cost_increase, 1.0):
		return unit_cost.mul(buy_amount)

	var ratio := BigNumber.new(definition.cost_increase)
	var series_sum := ratio.bigNumber_pow(float(buy_amount)).sub(BigNumber.new(1)).div(BigNumber.new(definition.cost_increase - 1.0))

	return unit_cost.mul(series_sum)

static func get_generator_production(_generator_name: String, _amount_owned: BigNumber, _upgrades: Dictionary) -> BigNumber:
	var definition := DataLoader.get_generator(_generator_name)
	if definition == null or _amount_owned.less_or_equal(0):
		return BigNumber.new(0)

	var effective_production := definition.base_production
	var add_bonus := BigNumber.new(0)
	var mul_bonus := BigNumber.new(1)
	var pow_exponents: Array[float] = []
	
	for upgrade_name in _upgrades:
		var upgrade_amount: int = _upgrades[upgrade_name]
		var upgrade := DataLoader.get_upgrade(upgrade_name)
		if upgrade == null or upgrade_amount <= 0 or not definition.has_any_tag(upgrade.tags):
			continue
		
		add_bonus = upgrade.upgrade_effect.apply_upgrade(add_bonus, upgrade_amount, Enums.UpgradeBonusTags.ADD, definition)
		
		mul_bonus = upgrade.upgrade_effect.apply_upgrade(mul_bonus, upgrade_amount, Enums.UpgradeBonusTags.MUL, definition)
		
		var new_pow_exponent = upgrade.upgrade_effect.apply_upgrade(BigNumber.new(1), upgrade_amount, Enums.UpgradeBonusTags.POW, definition)
		if new_pow_exponent is float: pow_exponents.append(new_pow_exponent)
	
	var lvl_bonus = _amount_owned.div(25).add(1).to_int()
	var prestige_points = Game.get_player().prestige_points
	var prestige_bonus = prestige_points.mul(Game.get_player().prestige_power).add(1) if prestige_points.greater_than(0) else BigNumber.new(1)
	
	effective_production = effective_production.add(add_bonus).mul(mul_bonus).mul(_amount_owned).mul(lvl_bonus).mul(prestige_bonus)
	
	for exponent_value in pow_exponents:
		effective_production = effective_production.bigNumber_pow(exponent_value)
		
	return effective_production

static func get_prestige_gain(_total_money: BigNumber, _current_prestiges: BigNumber, _upgrades: Dictionary) -> BigNumber:
	var prestige_bonus = BigNumber.new(1)
	
	for upgrade_name in _upgrades:
		var times_bought: int = _upgrades[upgrade_name]
		var upgrade := DataLoader.get_upgrade(upgrade_name)
		
		prestige_bonus = upgrade.upgrade_effect.apply_upgrade(prestige_bonus, times_bought, Enums.UpgradeBonusTags.PRESTIGE)
	
	var amount_gain = _total_money.div(BigNumber.new(Game.prestige_min).mul(_current_prestiges.add(1))).bigNumber_pow(0.5).mul(prestige_bonus).to_floor()
	
	return amount_gain

static func get_weaponize_items_selection() -> Array[GeneratorItem]:
	var items_for_selection: Array[GeneratorItem] = []
	items_for_selection.append(DataLoader.get_item("Battery_Item"))
	items_for_selection.append(DataLoader.get_item("Hourglass_Item"))
	items_for_selection.append(DataLoader.get_item("Shovel_Item"))
	return items_for_selection
