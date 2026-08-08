class_name Enums

enum GenTags {
	ALL,
	DARK,
	LIGHT,
	COOL,
	WARM,
	NEUTRAL,
	PRIMARY,
	SECONDARY,
	ORE
}

enum UpgradeCostTags {
	MONEY,
	PRESTIGE,
	ITEM
}

enum UpgradeBonusTags {
	ADD,
	MUL,
	POW,
	PRICE,
	PRESTIGE,
	UNIQUE
}

enum UniqueUpgradeNames {
	TIME_FLUX_UPGRADE
}

static func gen_tags_from_names(_names: Array) -> Array[GenTags]:
	var result: Array[GenTags] = []
	for tag_name in _names:
		if GenTags.has(tag_name):
			result.append(GenTags[tag_name])
		else:
			push_warning("Enums: tag '%s' não existe em GenTags" % tag_name)
	return result

static func upgrade_bonus_tag_from_name(bonus_name: String) -> UpgradeBonusTags:
	if UpgradeBonusTags.has(bonus_name):
		return UpgradeBonusTags[bonus_name]
	push_warning("Enums: tag '%s' não existe em UpgradeBonusTags" % bonus_name)
	return UpgradeBonusTags.ADD

static func upgrade_bonuses_tags_from_name(_names: Variant) -> Array[UpgradeBonusTags]:
	var result: Array[UpgradeBonusTags] = []
	if _names is not Array: return [Enums.UpgradeBonusTags[_names]]
	for tag_name in _names:
		if UpgradeBonusTags.has(tag_name):
			result.append(UpgradeBonusTags[tag_name])
		else:
			push_warning("Enums: tag '%s' não existe em UpgradeBonusTags" % tag_name)
	return result
