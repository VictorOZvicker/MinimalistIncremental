class_name GeneratorItem

## Chave do item em items.json, usada como identidade nos inventários
## (Player.items e GeneratorInventory). Definida pelo DataLoader ao
## carregar o cache; item_name é apenas o nome de exibição.
var item_id:          String

var item_name:        String
var item_description: String
var upgrade_name:     String
var icon_path:        String
var space:            Vector2i

func _init(_item_name: String, _item_description: String,_upgrade_name: String, _icon_path: String, _space := Vector2i(1,1)) -> void:
	self.item_name        = _item_name
	self.item_description = _item_description
	self.upgrade_name     = _upgrade_name
	self.icon_path        = _icon_path
	self.space            = _space
