extends Node2D

const STUDENT_SCENE := preload("res://scenes/characters/student.tscn")
const QUANTUM: int = 2

@export var seconds_per_unit: float = 2.0

var simulation_time: int = 0

var students: Dictionary = {}
var processes: Array[Process] = []
var ready_queue: Array[Process] = []
var timeline: Array[Dictionary] = []

var current_process: Process = null
var waiting_for_selection: bool = false
var selected_process: Process = null

@onready var fountain_point: Marker2D = $Classroom/WaterFountain/InteractionPoint
@onready var hud = $HUDLayer/SchedulingHUD
@onready var gantt_chart = $HUDLayer/GanttChart
@onready var results_screen = $HUDLayer/ResultsScreen


func _ready() -> void:
	processes = [
		Process.new(1, 0, 5),
		Process.new(2, 0, 3),
		Process.new(3, 0, 2)
	]

	var scheduler := RRScheduler.new(QUANTUM)
	timeline = scheduler.schedule(processes)
	
	for process in processes:
		process.remaining_time = process.burst_time
		process.state = "new"
	
	_create_students(processes)

	for student in students.values():
		student.visible = false

	var final_time: int = 0
	for segment in timeline:
		final_time = maxi(final_time, segment["end"])

	hud.update_time(0, final_time)
	hud.update_cpu(null)
	hud.update_queue(ready_queue)

	gantt_chart.setup(final_time)

	results_screen.continue_pressed.connect(_on_results_continue_pressed)

	_run_simulation()


func _run_simulation() -> void:
	for segment in timeline:
		var process: Process = segment["process"]
		var start_time: int = segment["start"]
		var end_time: int = segment["end"]

		# Avança o relógio até o início do trecho.
		while simulation_time < start_time:
			_check_arrivals()
			_update_hud()
			await get_tree().create_timer(seconds_per_unit).timeout
			simulation_time += 1

		_check_arrivals()
		_update_hud()

		# Aguarda o jogador selecionar o próximo aluno.
		waiting_for_selection = true
		selected_process = null
		hud.clear_feedback()

		while waiting_for_selection:
			await get_tree().process_frame

		_start_process(process)

		# Executa apenas o tempo permitido pelo quantum.
		while simulation_time < end_time:
			await get_tree().create_timer(seconds_per_unit).timeout
			simulation_time += 1
			_check_arrivals()
			_update_hud()

		_finish_quantum(process, end_time)

	print("Round Robin finalizado no tempo ", simulation_time)
	results_screen.show_results(processes, "Round Robin")


func _check_arrivals() -> void:
	for process in processes:
		if process.arrival_time == simulation_time and process.state == "new":
			process.state = "ready"
			ready_queue.append(process)

			var student: Student = students[process.pid]
			student.visible = true

			print("P", process.pid, " → PRONTO")

	_update_queue_positions()


func _start_process(process: Process) -> void:
	ready_queue.erase(process)
	current_process = process
	process.state = "running"

	_update_queue_positions()

	var student: Student = students[process.pid]
	student.move_to(fountain_point.global_position)

	print("P", process.pid, " → EXECUTANDO")


func _finish_quantum(process: Process, end_time: int) -> void:
	var executed_time: int = mini(QUANTUM, process.remaining_time)
	var segment_start: int = end_time - (
		mini(QUANTUM, process.remaining_time)
	)

	gantt_chart.add_execution_segment(
		process,
		segment_start,
		end_time
	)
	
	process.remaining_time -= executed_time
	current_process = null

	if process.remaining_time > 0:
		process.state = "ready"
		ready_queue.append(process)

		print(
			"P", process.pid,
			" → QUANTUM ENCERRADO | Restante: ",
			process.remaining_time
		)

		_update_queue_positions()
	else:
		process.state = "finished"

		var student: Student = students[process.pid]
		student.is_moving = false
		student.velocity = Vector2.ZERO
		student.visible = false

		print("P", process.pid, " → FINALIZADO")

	_update_hud()


func _create_students(process_list: Array[Process]) -> void:
	var spawn_points: Array[Marker2D] = [
		$StudentSpawn1,
		$StudentSpawn2,
		$StudentSpawn3
	]

	for i in range(process_list.size()):
		var student := STUDENT_SCENE.instantiate() as Student
		$Students.add_child(student)

		student.global_position = spawn_points[i].global_position
		student.setup(process_list[i])
		student.student_selected.connect(_on_student_selected)

		students[process_list[i].pid] = student


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


func _on_student_selected(process: Process) -> void:
	if not waiting_for_selection:
		return

	if ready_queue.is_empty():
		return

	var expected_process: Process = ready_queue[0]

	if process == expected_process:
		hud.show_feedback(
			"Correto! P%d é o próximo da fila Round Robin." % process.pid,
			true
		)

		selected_process = process
		waiting_for_selection = false
	else:
		hud.show_feedback(
			"Incorreto! P%d é o próximo da fila." % expected_process.pid,
			false
		)


func _update_hud() -> void:
	var final_time: int = 0

	for segment in timeline:
		final_time = maxi(final_time, segment["end"])

	hud.update_time(simulation_time, final_time)
	hud.update_cpu(current_process)
	hud.update_queue(ready_queue)


func _on_results_continue_pressed() -> void:
	print("Round Robin concluído!")
