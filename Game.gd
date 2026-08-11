extends Node

var _player: Player
var _unique_upgrade_effect: UniqueEffects

#region Game Settings
var prestige_min:   float = 1_000_000_000
var weaponize_min:  float = 1_000_000_000
var prestige_power: float = 0.20
#endregion


func _ready():
	self._player = Player.new()
	self._unique_upgrade_effect = UniqueEffects.new()

func get_player():
	assert(self._player != null, "Player not initialized!")
	return self._player

func get_unique_upgrade_effect(_name: String) -> Callable:
	return _unique_upgrade_effect.get_effect(_name)
