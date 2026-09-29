class_name FCFSScheduler
extends RefCounted


func schedule(processes: Array[Process]) -> Array[Process]:
	var ordered_processes: Array[Process] = processes.duplicate()

	ordered_processes.sort_custom(
		func(a: Process, b: Process) -> bool:
			return a.arrival_time < b.arrival_time
	)

	return ordered_processes


func calculate_metrics(processes: Array[Process]) -> void:
	var current_time: int = 0

	for process in processes:
		if current_time < process.arrival_time:
			current_time = process.arrival_time

		process.start_time = current_time
		process.completion_time = current_time + process.burst_time

		process.waiting_time = process.start_time - process.arrival_time
		process.turnaround_time = process.completion_time - process.arrival_time

		current_time = process.completion_time
