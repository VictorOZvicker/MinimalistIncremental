extends Control


func set_labels(_definition: Upgrade, _upgrade_name: String):
	var _amount = Game.get_player().get_upgrade_amount(_upgrade_name)
	var ident = "%*s" % [13, ""]
	if _definition.currency == Enums.UpgradeCostTags.MONEY: $upgradeInfos/upgradeCost.add_theme_color_override("font_color", Color.GREEN)
	$upgradeInfos/upgradeName.text        = _definition.upgrade_name
	$upgradeInfos/upgradeDescription.text = _definition.description
	$upgradeInfos/upgradeCost.text        = ident + "$ %s" % str(Game.get_player().get_upgrade_cost(_upgrade_name))
	$upgradeInfos/upgradeAmount. text     = ident + "# %s" % str(_amount) if (_definition.buy_limit > 1 and _amount > 0) else ""
