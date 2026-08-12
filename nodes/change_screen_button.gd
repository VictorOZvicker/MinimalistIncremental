extends Control

@export var button_icon: CompressedTexture2D
@export var button_label: String
@export var screen_name: String

signal change_screen(_screen_change: String)

func _ready():
	$HBoxContainer/buttonIcon.texture = button_icon
	$HBoxContainer/buttonLabel.text   = button_label

func _on_button_pressed() -> void:
	change_screen.emit(self.screen_name)
