class_name SingleTimeEventsConditions

static func prestige_reached(_args: Array) -> bool: return Game.get_player().total_money.greater_or_equal(10000000)

static func weaponize_reached(_args: Array) -> bool: return Game.get_player().prestige_points.greater_or_equal(10000000)
