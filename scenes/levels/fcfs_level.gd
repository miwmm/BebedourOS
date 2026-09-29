extends Node2D


func _ready() -> void:
	var processes: Array[Process] = [
		Process.new(1, 4, 5),
		Process.new(2, 0, 3),
		Process.new(3, 2, 7)
	]

	var scheduler := FCFSScheduler.new()
	var execution_order := scheduler.schedule(processes)
	scheduler.calculate_metrics(execution_order)
	print("=== TESTE FCFS ===")

	for process in execution_order:
		print(
			"P", process.pid,
			" | Chegada: ", process.arrival_time,
			" | Execução: ", process.burst_time,
			" | Início: ", process.start_time,
			" | Término: ", process.completion_time,
			" | Espera: ", process.waiting_time,
			" | Turnaround: ", process.turnaround_time
		)
