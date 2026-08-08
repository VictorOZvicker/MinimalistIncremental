class_name Player

var money: BigNumber

var total_money: BigNumber
var generators: Dictionary[String, BigNumber]
var generators_inventory: Dictionary[String, GeneratorInventory]

var items:    Dictionary[String, int]
var upgrades: Dictionary[String, int]

var prestige_points: BigNumber
var prestige_power: float

var gen_buy_amount: int = 1:
	set(value):
		gen_buy_amount = clampi(value, 1, 1_000_000)

var upgrade_buy_amount: int = 1:
	set(value):
		upgrade_buy_amount = clampi(value, 1, 1_000_000)

var max_gen_buy := false

signal money_changed(_new_value: BigNumber)
signal prestige_points_changed(_new_value: BigNumber)

signal prestiged()

signal gen_bought(_generator_name: String)
signal gen_unlocked(_generator_name: String)
signal upgrade_bought(_upgrade_name: String)

signal weaponized()

func _init():
	self.money                = BigNumber.new(5)
	self.prestige_points      = BigNumber.new(100)
	self.total_money          = self.money.add(0)
	self.generators           = {}
	self.generators_inventory = {}
	self.upgrades             = {}
	self.prestige_power       = 0.2
	
	self.gen_bought.connect(initialize_generator_inventory)
	
	warm_data_cache()
	
	#=================================================
	#Apenas para fim de testes, recebe todos os itens.
	for item in DataLoader.get_all_items():
		self.items[item] = 3
	#=================================================

func buy_generator(_generator_name: String) -> bool:
	var amount_owned := get_generator_amount(_generator_name)
	var buy_amount := get_generator_buy_amount(_generator_name)

	if buy_amount <= 0:
		return false

	var cost := ProductionCalculator.get_generator_cost(_generator_name, amount_owned, self.upgrades, buy_amount)

	if(self.money.less_than(cost)):
		return false

	if amount_owned.less_than(1): self.gen_unlocked.emit(_generator_name)
	self.money = self.money.sub(cost)
	self.money_changed.emit(self.money)
	self.generators[_generator_name] = amount_owned.add(buy_amount)
	self.gen_bought.emit(_generator_name)
	return true

func buy_upgrade(_upgrade_name: String, _currency: Enums.UpgradeCostTags) -> bool:
	var upgrade := DataLoader.get_upgrade(_upgrade_name)
	if upgrade == null:
		return false

	var times_bought := get_upgrade_amount(_upgrade_name)
	if times_bought >= upgrade.buy_limit:
		return false

	var buy_amount := mini(self.upgrade_buy_amount, upgrade.buy_limit - times_bought)
	var cost := ProductionCalculator.get_upgrade_cost(_upgrade_name, times_bought, buy_amount)


	match _currency:
		Enums.UpgradeCostTags.MONEY:
			if self.money.less_than(cost): return false
			self.money = self.money.sub(cost)
			self.money_changed.emit(self.money)
		Enums.UpgradeCostTags.PRESTIGE:
			if self.prestige_points.less_than(cost): return false
			self.prestige_points = self.prestige_points.sub(cost)
			self.prestige_points_changed.emit(self.prestige_points)
	
	self.upgrades[_upgrade_name] = times_bought + buy_amount
	
	self.upgrade_bought.emit(_upgrade_name)
	return true

func produce(_amount: BigNumber):
	self.money = self.money.add(_amount)
	self.total_money = self.total_money.add(_amount)
	self.money_changed.emit(self.money)

func get_generator_amount(_generator_name: String) -> BigNumber:
	return self.generators.get(_generator_name, BigNumber.new(0))

func get_upgrade_amount(_upgrade_name: String) -> int:
	return self.upgrades.get(_upgrade_name, 0)

func get_generator_buy_amount(_generator_name: String) -> int:
	if self.max_gen_buy:
		return ProductionCalculator.get_max_affordable_generator_amount(_generator_name, get_generator_amount(_generator_name), self.upgrades, self.money)
	return self.gen_buy_amount

func get_generator_cost(_generator_name: String) -> BigNumber:
	return ProductionCalculator.get_generator_cost(_generator_name, get_generator_amount(_generator_name), self.upgrades, get_generator_buy_amount(_generator_name))

func get_upgrade_cost(_upgrade_name: String) -> BigNumber:
	var upgrade := DataLoader.get_upgrade(_upgrade_name)
	if upgrade == null:
		return BigNumber.new(0)

	var times_bought := get_upgrade_amount(_upgrade_name)
	var buy_amount := mini(self.upgrade_buy_amount, maxi(upgrade.buy_limit - times_bought, 1))

	return ProductionCalculator.get_upgrade_cost(_upgrade_name, times_bought, buy_amount)

func get_generator_production(_generator_name: String) -> BigNumber:
	var generator_inventory: GeneratorInventory = get_generator_inventory(_generator_name)
	var generator_item_upgrades = {}
	if generator_inventory != null: generator_item_upgrades = generator_inventory.get_item_upgrades()
	var total_generator_upgrades: Dictionary[String, int] = {}
	total_generator_upgrades.merge(generator_item_upgrades)
	total_generator_upgrades.merge(self.upgrades)
	return ProductionCalculator.get_generator_production(_generator_name, get_generator_amount(_generator_name), total_generator_upgrades)

func warm_data_cache():
	DataLoader.get_all_generators()
	DataLoader.get_all_upgrades()

func prestige():
	var prestige_amount = ProductionCalculator.get_prestiges_gain(self.upgrades)
	
	if prestige_amount.less_than(self.prestige_points):
		return
	
	self.prestige_points = prestige_amount
	self.reset_progression()
	self.prestige_points_changed.emit(self.prestige_points)
	self.prestiged.emit()

func initialize_generator_inventory(_generator_name: String):
	if self.generators_inventory.has(_generator_name): return
	self.generators_inventory[_generator_name] = GeneratorInventory.new()

func get_generator_inventory(_generator_name: String) -> GeneratorInventory:
	return self.generators_inventory.get(_generator_name)

func weaponize(_item: String):
	self.items[_item] = self.items.get_or_add(_item, "")
	self.reset_progression(true, true)
	self.weaponized.emit()

func reset_progression(_reset_all_upgrades: bool = false, _reset_prestige: bool = false):
	var remaining_upgrades: Dictionary
	for upgrade in self.upgrades:
		if DataLoader.get_upgrade(upgrade).currency != Enums.UpgradeCostTags.MONEY:
			remaining_upgrades[upgrade] = self.upgrades[upgrade]
	self.generators.clear()
	self.upgrades.clear()
	if not _reset_all_upgrades: self.upgrades.merge(remaining_upgrades)
	if _reset_prestige: self.prestige_points = BigNumber.new(0)
	self.money = BigNumber.new(5)
	self.money_changed.emit(self.money)
