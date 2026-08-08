extends Control

var options = {
	0: 1,
	1: 5,
	2: 25,
	3: 100,
	4: 1
}

var current_option := 0
var current_amount := 1 

signal buy_amount_changed(_amount: int, _max: bool)

func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				current_option = (current_option + 1) % 5
			MOUSE_BUTTON_RIGHT:
				current_option = current_option - 1 if current_option > 0 else 4
		update_button()

func update_button():
	current_amount = options.get(current_option, 1)
	if current_option == 4:
		buy_amount_changed.emit(current_amount, true)
		$Button.text = "MAX"
	else:
		buy_amount_changed.emit(current_amount, false)
		$Button.text = str(current_amount)
