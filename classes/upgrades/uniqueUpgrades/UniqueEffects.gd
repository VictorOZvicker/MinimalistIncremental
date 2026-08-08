class_name UniqueEffects

func get_effect(_name: String) -> Callable:
	return Callable(self, _name)

#Ex.
#Increase the production of generators by 50% per second it takes to generate
func time_flux_upgrade_effect(_current_value: BigNumber, _effect_values: Array[BigNumber], _upgrade_amount: int, _type_to_apply: Enums.UpgradeBonusTags, _generator: Generator = null):
	if _type_to_apply != Enums.UpgradeBonusTags.MUL: return _current_value
	return _current_value.mul(_effect_values[0].mul(_generator.wait_time_production))

func hourglass_item_upgrade(_current_value: BigNumber, _effect_values: Array[BigNumber], _upgrade_amount: int, _type_to_apply: Enums.UpgradeBonusTags, _generator: Generator = null):
	if _type_to_apply != Enums.UpgradeBonusTags.MUL: return _current_value
	return _current_value.mul((_effect_values[0].mul(_generator.wait_time_production)).bigNumber_pow(float(_upgrade_amount)))
