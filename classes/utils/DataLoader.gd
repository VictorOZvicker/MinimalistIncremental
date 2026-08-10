class_name DataLoader

static var gens_path     := "res://data/generators.json"
static var upgrades_path := "res://data/upgrades.json"
static var item_path     := "res://data/items.json"

static var _generators_cache: Dictionary = {}
static var _upgrades_cache:   Dictionary = {}
static var _item_cache:       Dictionary = {}

static func load_json(_path: String):

	var file = FileAccess.open(_path, FileAccess.READ)

	if file == null:
		print("Erro ao abrir ", _path)
		return null

	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if data == null:
		print("Erro ao ler JSON: ", _path)
		return null

	return data

static func contruct_gen(_data: Dictionary) -> Generator:
	if _data == null:
		return null
	
	# ============= Generators Parameters ===============
	var name: String                = _data.get("name", "")
	var cost: BigNumber             = BigNumber.parseBigNumber(_data.get("cost", ""))
	var cost_increase: float = _data.get("cost_increase", 2.0)
	var base_production: BigNumber  = BigNumber.parseBigNumber(_data.get("base_production", ""))
	var wait_time_production: float = _data.get("wait_time", 1.0)
	var icon_path: String           = _data.get("icon_path", "")
	
	var color_array: Array          = _data.get("color", [0, 0, 0])
	var color: Color                = Color(color_array[0], color_array[1], color_array[2])

	var tags := Enums.gen_tags_from_names(_data.get("tags", []))
	# ==================================================

	return Generator.new(name, cost, cost_increase, base_production, wait_time_production, icon_path, color, tags)

static func construct_upgrade(_data: Dictionary) -> Upgrade:
	if _data == null: return null

	# =========== UPGRADE PARAMETERS ==================
	var name: String                    = _data.get("name", "")
	var cost: BigNumber                 = BigNumber.parseBigNumber(_data.get("cost", ""))
	var tags                           := Enums.gen_tags_from_names(_data.get("tags", ["ALL"]))
	var description: String             = _data.get("description", "")
	var icon_path: String               = _data.get("icon_path", "")
	var buy_limit: int                  = _data.get("buy_limit", 1)
	var cost_increase: float            = _data.get("cost_increase", 1.0)
	var currency: Enums.UpgradeCostTags = Enums.UpgradeCostTags.get(_data.get("currency"), Enums.UpgradeCostTags.MONEY)
	# =================================================
	
	# =========== UPGRADE EFFECTS PARAMETER ===========
	var bonus_types                    := Enums.upgrade_bonuses_tags_from_name(_data.get("bonus_type", []))
	var bonus_values                   := get_array_bonus_values(_data.get("bonus_value", []))
	var unique_effect: String           = _data.get("upgrade_effect", "")
	# =================================================
	
	if bonus_types.has(Enums.UpgradeBonusTags.UNIQUE) and unique_effect.is_empty(): 
		push_error("Unique upgrades must have the unique upgrade effect!")
		return null
	
	var upgrade_effect                 := UpgradeEffect.new(bonus_types, bonus_values, unique_effect)

	return Upgrade.new(name, cost, upgrade_effect, tags, description, icon_path, buy_limit, cost_increase, currency)

static func contruct_item(_data: Dictionary) -> GeneratorItem:
	if _data == null: return null
	
	var item_name: String             = _data.get("name", "")
	var item_description: String      = _data.get("description", "") 
	var item_upgrade_name: String     = _data.get("upgrade_name", "")
	var item_icon_path: String        = _data.get("icon_path", "")
	var item_space_array: Array       = _data.get("space", [1,1])
	var item_rariry: Enums.ItemRarity = Enums.ItemRarity.get(_data.get("rarity", ""), 0)
	var item_space := Vector2i(item_space_array[0], item_space_array[1])
	
	return GeneratorItem.new(item_name, item_description, item_upgrade_name, item_rariry, item_icon_path, item_space)
	
static func _build_cache(_path: String, _constructor: Callable, _cost_getter: Callable) -> Dictionary:
	var data = load_json(_path)
	var cache := {}

	if data == null:
		return cache

	for element_name in data:
		cache[element_name] = _constructor.call(data[element_name])
	
	if _cost_getter.is_valid():
		return _sort_cache_by_cost(cache, _cost_getter)
	else: 
		return cache

static func _sort_cache_by_cost(_cache: Dictionary, _cost_getter: Callable) -> Dictionary:
	var keys := _cache.keys()
	keys.sort_custom(func(a, b): return _cost_getter.call(_cache[a]).less_than(_cost_getter.call(_cache[b])))

	var sorted_cache := {}
	for key in keys:
		sorted_cache[key] = _cache[key]

	return sorted_cache

static func _generator_cost(_generator: Generator) -> BigNumber:
	return _generator.base_cost

static func _upgrade_cost(_upgrade: Upgrade) -> BigNumber:
	return _upgrade.cost

static func get_generator(_name: String) -> Generator:
	get_all_generators()
	
	if not _generators_cache.has(_name):
		push_warning("DataLoader: gerador '%s' não encontrado" % _name)
		return null

	return _generators_cache[_name]

static func get_upgrade(_name: String) -> Upgrade:
	get_all_upgrades()
	
	if not _upgrades_cache.has(_name):
		push_warning("DataLoader: upgrade '%s' não encontrado" % _name)
		return null

	return _upgrades_cache[_name]

static func get_item(_name: String) -> GeneratorItem:
	get_all_items()
	
	if not _item_cache.has(_name):
		push_warning("DataLoader: item '%s' não encontrado" % _name)
		return null

	return _item_cache[_name]

static func get_all_generators() -> Dictionary:
	if _generators_cache.is_empty():
		_generators_cache = _build_cache(gens_path, Callable(DataLoader, "contruct_gen"), Callable(DataLoader, "_generator_cost"))

	return _generators_cache

static func get_all_upgrades() -> Dictionary:
	if _upgrades_cache.is_empty():
		_upgrades_cache = _build_cache(upgrades_path, Callable(DataLoader, "construct_upgrade"), Callable(DataLoader, "_upgrade_cost"))

	return _upgrades_cache

static func get_all_items() -> Dictionary:
	if _item_cache.is_empty():
		_item_cache = _build_cache(item_path, Callable(DataLoader, "contruct_item"), Callable())
		for item_id in _item_cache:
			if _item_cache[item_id] != null:
				_item_cache[item_id].item_id = item_id

	return _item_cache

static func get_array_bonus_values(_input: Variant) -> Array[BigNumber]:
	if _input is Array:
		var new_array: Array[BigNumber] = []
		for number in _input:
			new_array.append(BigNumber.parseBigNumber(number))
		return new_array
	return [BigNumber.parseBigNumber(_input)]
