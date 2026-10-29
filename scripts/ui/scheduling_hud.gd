
extends Control

@onready var time_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TimeLabel
@onready var cpu_status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CPUStatusLabel
@onready var ready_queue_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ReadyQueueLabel
@onready var progress_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/ProgressBar
@onready var feedback_label: Label = $PanelContainer/MarginContainer/VBoxContainer/FeedbackLabel



func update_time(current_time: int, total_time: int) -> void:
	time_label.text = "Tempo: %d / %d" % [current_time, total_time]
	progress_bar.max_value = total_time
	progress_bar.value = current_time


func update_cpu(process: Process) -> void:
	if process == null:
		cpu_status_label.text = "CPU: Livre"
		cpu_status_label.add_theme_color_override(
			"font_color", Color("#A0A0A0")
		)
	else:
		cpu_status_label.text = "CPU: P%d executando" % process.pid
		cpu_status_label.add_theme_color_override(
			"font_color", Color("#66E0A3")
		)

func update_queue(processes: Array[Process]) -> void:
	if processes.is_empty():
		ready_queue_label.text = "Fila: Vazia"
		return

	var names: Array[String] = []

	for process in processes:
		names.append("P%d" % process.pid)

	ready_queue_label.text = "Fila: " + ", ".join(names)

func show_feedback(message: String, correct: bool) -> void:
	feedback_label.text = message
	feedback_label.visible = true

	if correct:
		feedback_label.add_theme_color_override(
			"font_color",
			Color("#66E0A3")
		)
	else:
		feedback_label.add_theme_color_override(
			"font_color",
			Color("#FF7777")
		)

func clear_feedback() -> void:
	feedback_label.text = ""
	feedback_label.visible = false
