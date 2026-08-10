extends Control

var currently_selected
var previous_selected

func _ready():
	GameEventsManager.create_item_selection_screen.connect(on_create_selection)

func on_create_selection(_determined_items: Array[GeneratorItem]):
	var item_scene: PackedScene = preload("res://nodes/items/itemSelectionNode.tscn")
	var has_children = $itemSelection.get_children()
	
	if not has_children.is_empty():
		for child in has_children:
			child.queue_free()
	
	for item in _determined_items:
		var new_item = item_scene.instantiate()
		new_item.setup(item.item_name, item.item_description, item.rarity, 0, item.icon_path)
		new_item.selected.connect(on_item_selected)
		$itemSelection.add_child(new_item)

func on_item_selected(_selected: Control):
	self.previous_selected  = currently_selected
	self.currently_selected = _selected
	if self.previous_selected:  self.previous_selected.hide_indicator()
	if self.currently_selected: self.currently_selected.show_indicator()
