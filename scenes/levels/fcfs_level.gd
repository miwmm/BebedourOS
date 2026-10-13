extends Node2D


const STUDENT_SCENE := preload("res://scenes/characters/student.tscn")

func _ready() -> void:
	var processes: Array[Process] = [
		Process.new(1, 4, 5),
		Process.new(2, 0, 3),
		Process.new(3, 2, 7)
	]

	var scheduler := FCFSScheduler.new()
	var execution_order := scheduler.schedule(processes)
	scheduler.calculate_metrics(execution_order)
	_create_students(processes)
	print("=== TESTE FCFS ===")

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
