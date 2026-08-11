extends Control

signal selected(_self: Control)

var item_id: String

func setup(
	_item_id:          String,
	_item_name:        String,
	_item_description: String,
	_item_rarity:      Enums.ItemRarity,
	_amount_owned:     int,
	_item_icon_path:   String):
	$infoLabels/itemName.text        = _item_name
	$infoLabels/itemDescription.text = _item_description
	$infoLabels/itemRarity.text      = str(_item_rarity)
	$infoLabels/amountOwned.text     = "# " + str(_amount_owned)
	$itemIcon.texture                = load(_item_icon_path)
	self.item_id = _item_id

func show_indicator():
	$selectionIndicator.show()
func hide_indicator():
	$selectionIndicator.hide()

func _on_select_buttton_pressed() -> void:
	selected.emit(self)
