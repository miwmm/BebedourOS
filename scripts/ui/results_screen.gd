extends Control

signal continue_pressed

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var results_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResultsGrid
@onready var average_waiting_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AverageWaitingLabel
@onready var average_turnaround_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AverageTurnaroundLabel
@onready var continue_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton


func _ready() -> void:
	hide()
	continue_button.pressed.connect(_on_continue_pressed)


func show_results(processes: Array[Process], algorithm_name: String = "FCFS") -> void:
	title_label.text = "Resultados do " + algorithm_name

	# Remove os dados anteriores da tabela.
	for child in results_grid.get_children():
		results_grid.remove_child(child)
		child.queue_free()

	# Cabeçalho.
	var headers := [
		"Processo",
		"Chegada",
		"Execução",
		"Espera",
		"Retorno"
	]

	for header in headers:
		_add_cell(header)

	var total_waiting: float = 0.0
	var total_turnaround: float = 0.0

	# Dados dos processos.
	for process in processes:
		_add_cell("P%d" % process.pid)
		_add_cell(str(process.arrival_time))
		_add_cell(str(process.burst_time))
		_add_cell(str(process.waiting_time))
		_add_cell(str(process.turnaround_time))

		total_waiting += process.waiting_time
		total_turnaround += process.turnaround_time

	# Calcula as médias.
	if not processes.is_empty():
		var count: float = float(processes.size())

		average_waiting_label.text = (
			"Tempo médio de espera: %.2f" % (total_waiting / count)
		)

		average_turnaround_label.text = (
			"Tempo médio de retorno: %.2f" % (total_turnaround / count)
		)

	show()


func _add_cell(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(85, 30)

	results_grid.add_child(label)


func _on_continue_pressed() -> void:
	continue_pressed.emit()
