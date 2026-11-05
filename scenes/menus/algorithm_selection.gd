extends Control


func _on_fcfs_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/fcfs_level.tscn")

func _on_sjf_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/sjf_level.tscn")

func _on_round_robin_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/rr_level.tscn")
