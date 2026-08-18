class_name Upgrade

var uid: String

var upgrade_name: String
var icon_path: String
var description: String

var currency: Enums.UpgradeCostTags

var cost: BigNumber
var cost_increase: float

var buy_limit: int

var upgrade_effect: UpgradeEffect

var tags: Array[Enums.GenTags]

func _init(_uid: String, _name: String, _cost: BigNumber, _upgrade_effect: UpgradeEffect, _tags: Array[Enums.GenTags], _description: String, _icon_path: String, _buy_limit: int, _cost_increase: float, _currency: Enums.UpgradeCostTags):
	self.uid            = _uid
	self.upgrade_name   = _name
	self.cost           = _cost
	self.cost_increase  = _cost_increase
	self.description    = _description
	self.icon_path      = _icon_path
	self.buy_limit      = _buy_limit
	self.tags           = _tags
	self.upgrade_effect = _upgrade_effect
	self.currency       = _currency
