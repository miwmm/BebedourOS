
extends Node2D

const STUDENT_SCENE := preload("res://scenes/characters/student.tscn")

# Cada unidade lógica terá 2 segundos reais para facilitar as animações.
@export var seconds_per_unit: float = 2.0

var simulation_time: int = 0
var students: Dictionary = {}
var queue_order: Array[Process] = []
var completed_processes: Array[Process] = []

var current_process: Process = null

@onready var fountain_point: Marker2D = $Classroom/WaterFountain/InteractionPoint


func _ready() -> void:
	var processes: Array[Process] = [
		Process.new(1, 4, 5),
		Process.new(2, 0, 3),
		Process.new(3, 2, 7)
	]

	var scheduler := FCFSScheduler.new()

	queue_order = scheduler.schedule(processes)
	scheduler.calculate_metrics(queue_order)

	_create_students(processes)
	_print_process_metrics()

	for student in students.values():
		student.visible = false

	_run_simulation()


func _run_simulation() -> void:
	var final_time: int = 0

	for process in queue_order:
		final_time = maxi(final_time, process.completion_time)

	while simulation_time <= final_time:
		print("Tempo atual: ", simulation_time)

		_check_arrivals()
		_check_execution_events()

		if simulation_time == final_time:
			break

		await get_tree().create_timer(seconds_per_unit).timeout
		simulation_time += 1

	print("Simulação finalizada no tempo ", simulation_time)


func _check_arrivals() -> void:
	for process in queue_order:
		if process.arrival_time == simulation_time:
			var student: Student = students[process.pid]

			student.visible = true
			process.state = "ready"

			print("P", process.pid, " → PRONTO")

			_move_student_to_queue(process)


func _check_execution_events() -> void:
	# Primeiro encerra o processo anterior.
	for process in queue_order:
		if process.completion_time == simulation_time:
			_finish_process(process)

	# Depois inicia o próximo processo.
	for process in queue_order:
		if process.start_time == simulation_time:
			_start_process(process)


func _start_process(process: Process) -> void:
	current_process = process
	process.state = "running"

	print("P", process.pid, " → EXECUTANDO")

	var student: Student = students[process.pid]
	student.move_to(fountain_point.global_position)


func _finish_process(process: Process) -> void:
	process.state = "finished"
	completed_processes.append(process)

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

		students[processes[i].pid] = student


func _move_student_to_queue(process: Process) -> void:
	var queue_positions: Array[Marker2D] = [
		$QueuePositions/QueuePosition1,
		$QueuePositions/QueuePosition2,
		$QueuePositions/QueuePosition3
	]

	var queue_index := queue_order.find(process)

	if queue_index == -1:
		return

	var student: Student = students[process.pid]

	student.move_to(
		queue_positions[queue_index].global_position
	)


func _print_process_metrics() -> void:
	print("\n===== RESULTADOS FCFS =====")

	for process in queue_order:
		print(
			"P", process.pid,
			" | Chegada: ", process.arrival_time,
			" | Início: ", process.start_time,
			" | Término: ", process.completion_time,
			" | Espera: ", process.waiting_time,
			" | Retorno: ", process.turnaround_time
		)
