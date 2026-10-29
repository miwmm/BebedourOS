
extends Node2D

const STUDENT_SCENE := preload("res://scenes/characters/student.tscn")

# Cada unidade lógica terá 2 segundos reais para facilitar as animações.
@export var seconds_per_unit: float = 2.0

var simulation_time: int = 0
var students: Dictionary = {}
var queue_order: Array[Process] = []
var completed_processes: Array[Process] = []
var ready_queue: Array[Process] = []
var waiting_for_selection: bool = false
var current_process: Process = null

@onready var fountain_point: Marker2D = $Classroom/WaterFountain/InteractionPoint
@onready var hud = $HUDLayer/SchedulingHUD
@onready var gantt_chart = $HUDLayer/GanttChart
@onready var results_screen = $HUDLayer/ResultsScreen

func _ready() -> void:
	print("SCRIPT EM EXECUÇÃO: ", get_script().resource_path)
	var processes: Array[Process] = [
		Process.new(1, 0, 8),
		Process.new(2, 1, 4),
		Process.new(3, 2, 2)
	]

	var scheduler := SJFScheduler.new()
	queue_order = scheduler.schedule(processes)

	var final_time: int = 0

	for process in queue_order:
		final_time = maxi(final_time, process.completion_time)

	gantt_chart.setup(final_time)
	
	results_screen.continue_pressed.connect(_on_results_continue_pressed)
	
	_create_students(processes)
	_print_process_metrics()

	for student in students.values():
		student.visible = false
	hud.update_time(0, 14)
	hud.update_cpu(null)
	_run_simulation()


func _run_simulation() -> void:
	var final_time: int = 0

	for process in queue_order:
		final_time = maxi(final_time, process.completion_time)

	while simulation_time <= final_time:
		print("Tempo atual: ", simulation_time)

		_check_arrivals()
		_check_execution_events()

		hud.update_time(simulation_time, final_time)
		hud.update_cpu(current_process)
		hud.update_queue(ready_queue)

		if simulation_time == final_time:
			break

		# Pausa o relógio enquanto o jogador escolhe.
		while waiting_for_selection:
			await get_tree().process_frame

		await get_tree().create_timer(seconds_per_unit).timeout
		simulation_time += 1

	print("Simulação finalizada no tempo ", simulation_time)
	results_screen.show_results(queue_order, "SJF")

func _check_arrivals() -> void:
	for process in queue_order:
		if process.arrival_time == simulation_time:
			var student: Student = students[process.pid]

			student.visible = true
			process.state = "ready"

			ready_queue.append(process)

			print("P", process.pid, " → PRONTO")

			_update_queue_positions()


func _check_execution_events() -> void:
	for process in queue_order:
		if process.completion_time == simulation_time:
			_finish_process(process)

	for process in queue_order:
		if process.start_time == simulation_time:
			waiting_for_selection = true
			hud.clear_feedback()
			print("Aguardando jogador selecionar o próximo processo...")
			print("Seleção liberada para P", process.pid)

func _start_process(process: Process) -> void:
	# Remove o processo da fila de prontos.
	ready_queue.erase(process)

	# Reorganiza os alunos que continuam aguardando.
	_update_queue_positions()

	current_process = process
	process.state = "running"

	print("P", process.pid, " → EXECUTANDO")

	var student: Student = students[process.pid]

	# A caminhada representa visualmente a troca de contexto.
	student.move_to(fountain_point.global_position)

func _finish_process(process: Process) -> void:
	process.state = "finished"
	completed_processes.append(process)
	
	gantt_chart.add_completed_process(process)

	print("P", process.pid, " → FINALIZADO")

	var student: Student = students[process.pid]

	student.is_moving = false
	student.velocity = Vector2.ZERO
	student.visible = false

	if current_process == process:
		current_process = null


func _create_students(processes: Array[Process]) -> void:
	var spawn_points: Array[Marker2D] = [
		$StudentSpawn1,
		$StudentSpawn2,
		$StudentSpawn3
	]

	for i in range(processes.size()):
		var student := STUDENT_SCENE.instantiate() as Student

		$Students.add_child(student)

		student.global_position = spawn_points[i].global_position
		student.setup(processes[i])
		student.student_selected.connect(_on_student_selected)

		students[processes[i].pid] = student


func _update_queue_positions() -> void:
	var queue_positions: Array[Marker2D] = [
		$QueuePositions/QueuePosition1,
		$QueuePositions/QueuePosition2,
		$QueuePositions/QueuePosition3
	]

	for i in range(ready_queue.size()):
		var process: Process = ready_queue[i]
		var student: Student = students[process.pid]

		student.move_to(queue_positions[i].global_position)

func _print_process_metrics() -> void:
	print("\n===== RESULTADOS SJF =====")

	for process in queue_order:
		print(
			"P", process.pid,
			" | Chegada: ", process.arrival_time,
			" | Início: ", process.start_time,
			" | Término: ", process.completion_time,
			" | Espera: ", process.waiting_time,
			" | Retorno: ", process.turnaround_time
		)

func _get_ready_processes() -> Array[Process]:
	var ready_processes: Array[Process] = []

	for process in queue_order:
		if process.state == "ready":
			ready_processes.append(process)

	return ready_processes

func _on_student_selected(process: Process) -> void:
	print(
		"Seleção recebida: P", process.pid,
		" | waiting_for_selection: ", waiting_for_selection,
		" | estado: ", process.state
	)
	if not waiting_for_selection:
		return

	if ready_queue.is_empty():
		return

	# Encontra o processo com menor tempo de execução.
	var expected_process: Process = ready_queue[0]

	for candidate in ready_queue:
		if candidate.burst_time < expected_process.burst_time:
			expected_process = candidate

		elif candidate.burst_time == expected_process.burst_time:
			if candidate.arrival_time < expected_process.arrival_time:
				expected_process = candidate

			elif candidate.arrival_time == expected_process.arrival_time:
				if candidate.pid < expected_process.pid:
					expected_process = candidate

	# Verifica a escolha do jogador.
	if process == expected_process:
		hud.show_feedback(
			"Correto! P%d possui o menor tempo de execução." % process.pid,
			true
		)

		waiting_for_selection = false
		_start_process(process)

	else:
		hud.show_feedback(
			"Incorreto! Existe um processo com menor tempo de execução. Tente novamente.",
			false
		)
		
func _on_results_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
