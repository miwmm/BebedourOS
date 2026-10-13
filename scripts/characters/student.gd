class_name Student
extends CharacterBody2D


var process: Process

@onready var process_label: Label = $ProcessLabel


func setup(new_process: Process) -> void:
	process = new_process
	process_label.text = "P%d" % process.pid
