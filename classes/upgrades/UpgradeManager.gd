class_name UpgradeManager


## Returns the effects of upgrades in an Array. [br]
## The values are:
## [codeblock]
## 0 = add_bonus
## 1 = mul_bonus
## 2 = pow_bonus: Array[/codeblock]
static func apply_upgrades(_upgrades: Dictionary, _generator: Generator) -> Array:
	var add_bonus := BigNumber.new(0)
	var mul_bonus := BigNumber.new(1)
	var pow_exponents: Array[float] = []
	
	var bonuses = []
	
	for upgrade_name in _upgrades:
		var upgrade_amount: int = _upgrades[upgrade_name]
		var upgrade := DataLoader.get_upgrade(upgrade_name)
		if upgrade == null or upgrade_amount <= 0 or not _generator.has_any_tag(upgrade.tags):
			continue
		
		add_bonus = upgrade.upgrade_effect.apply_upgrade(add_bonus, upgrade_amount, Enums.UpgradeBonusTags.ADD, _generator)
		
		mul_bonus = upgrade.upgrade_effect.apply_upgrade(mul_bonus, upgrade_amount, Enums.UpgradeBonusTags.MUL, _generator)
		
		var new_pow_exponent = upgrade.upgrade_effect.apply_upgrade(BigNumber.new(1), upgrade_amount, Enums.UpgradeBonusTags.POW, _generator)
		if new_pow_exponent is float: pow_exponents.append(new_pow_exponent)
		
	bonuses.append(add_bonus)
	bonuses.append(mul_bonus)
	bonuses.append(pow_exponents)
	
	return bonuses
