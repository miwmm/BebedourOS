
extends Control

signal start_pressed

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var mission_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MissionLabel
@onready var start_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func setup(
	algorithm_name: String,
	description: String,
	mission: String
) -> void:
	title_label.text = algorithm_name
	description_label.text = description
	mission_label.text = mission


func _on_start_button_pressed() -> void:
	start_pressed.emit()
	hide()
