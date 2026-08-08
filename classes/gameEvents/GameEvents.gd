class_name GameEvents

signal player_money_changed(_new_value: BigNumber)
signal player_prestige_points_changed(_new_value: BigNumber)

signal player_money_production(_amount: BigNumber)

signal prestige_unlocked()
signal generator_unlocked()
signal upgrade_unlocked()

signal generator_bought(_generator_name: String)
signal upgrade_bought()

signal update_gen_info(_generator_name: String)

signal player_prestiged()

signal open_inventory(_generator_name: String)

signal open_upgrade_tooltip(_target: Upgrade, _uid: String, _position: float)

signal warning_new(_position: Vector2)
