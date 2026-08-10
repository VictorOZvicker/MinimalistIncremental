class_name GeneratorItem

var item_id:          String

var item_name:        String
var item_description: String
var upgrade_name:     String
var icon_path:        String
var space:            Vector2i
var level:            int
var rarity:           Enums.ItemRarity

func _init(_item_name: String, _item_description: String,_upgrade_name: String, _rarity: Enums.ItemRarity, _icon_path: String, _space := Vector2i(1,1)) -> void:
	self.item_name        = _item_name
	self.item_description = _item_description
	self.upgrade_name     = _upgrade_name
	self.rarity           = _rarity
	self.level            = 1
	self.icon_path        = _icon_path
	self.space            = _space
