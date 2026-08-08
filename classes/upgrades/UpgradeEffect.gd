class_name UpgradeEffect

var bonus_type: Array[Enums.UpgradeBonusTags]
var bonus_values: Array[BigNumber]
var unique_effect: String

func _init(_bonus_type: Array[Enums.UpgradeBonusTags], _bonus_value: Array[BigNumber], _unique_effect := "") -> void:
	self.bonus_type  = _bonus_type
	self.bonus_values = _bonus_value
	self.unique_effect = _unique_effect

func apply_upgrade(_current_value: BigNumber, _upgrade_amount: int, _type_to_apply: Enums.UpgradeBonusTags, _generator: Generator = null):
	return apply_default(_current_value, _upgrade_amount, _type_to_apply) if self.unique_effect.is_empty() else Game.get_unique_upgrade_effect(self.unique_effect).call(_current_value, self.bonus_values, _upgrade_amount, _type_to_apply, _generator)

func apply_default(_current_value: BigNumber, _upgrade_amount: int, _type_to_apply: Enums.UpgradeBonusTags,):
	
	if not self.bonus_type.has(_type_to_apply): return _current_value
	
	var bonus_value_per_type = self.bonus_values[self.bonus_type.find(_type_to_apply)]
	
	match _type_to_apply:
		Enums.UpgradeBonusTags.ADD:
			_current_value = _current_value.add(bonus_value_per_type.mul(_upgrade_amount))
		Enums.UpgradeBonusTags.MUL, Enums.UpgradeBonusTags.PRICE, Enums.UpgradeBonusTags.PRESTIGE:
			_current_value = _current_value.mul(bonus_value_per_type.bigNumber_pow(float(_upgrade_amount)))
		Enums.UpgradeBonusTags.POW:
			_current_value = _current_value.mul((pow(bonus_value_per_type.to_float(), _upgrade_amount)))
			return _current_value.to_float()

	
	return _current_value
