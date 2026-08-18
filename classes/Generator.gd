class_name Generator

var uid: String

var generator_name: String
var icon_path: String

var base_cost: BigNumber
var cost_increase: float

var base_production: BigNumber
var wait_time_production: float

var tags: Array[Enums.GenTags]

var gen_color: Color

func _init(_uid: String, _name: String, _base_cost: BigNumber, _cost_increase: float, _base_production: BigNumber, _wait_time_production := 1.0, _icon_path := "", _gen_color := Color(0, 0, 0), _tags: Array[Enums.GenTags] = []):
	self.uid                  = _uid
	self.generator_name       = _name
	self.base_cost            = _base_cost
	self.cost_increase        = _cost_increase
	self.base_production      = _base_production
	self.wait_time_production = _wait_time_production
	self.icon_path            = _icon_path
	self.gen_color            = _gen_color
	self.tags                 = _tags

func has_any_tag(_target_tags: Array[Enums.GenTags]) -> bool:
	for tag in _target_tags:
		if self.tags.has(tag) or tag == Enums.GenTags.ALL:
			return true
	return false
