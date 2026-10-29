class_name RRScheduler
extends RefCounted

var quantum: int = 2


func _init(time_quantum: int = 2) -> void:
	quantum = maxi(time_quantum, 1)


func schedule(processes: Array[Process]) -> Array[Dictionary]:
	var timeline: Array[Dictionary] = []
	var pending: Array[Process] = processes.duplicate()
	var ready_queue: Array[Process] = []
	var current_time: int = 0

	pending.sort_custom(
		func(a: Process, b: Process) -> bool:
			if a.arrival_time == b.arrival_time:
				return a.pid < b.pid
			return a.arrival_time < b.arrival_time
	)

	for process in processes:
		process.remaining_time = process.burst_time
		process.start_time = -1
		process.completion_time = -1
		process.waiting_time = 0
		process.turnaround_time = 0

	while not pending.is_empty() or not ready_queue.is_empty():

		# Adiciona os processos que já chegaram.
		while not pending.is_empty() and pending[0].arrival_time <= current_time:
			ready_queue.append(pending.pop_front())

		# CPU ociosa: avança até a próxima chegada.
		if ready_queue.is_empty():
			current_time = pending[0].arrival_time
			continue

		var process: Process = ready_queue.pop_front()

		if process.start_time == -1:
			process.start_time = current_time

		var execution_time: int = mini(quantum, process.remaining_time)
		var end_time: int = current_time + execution_time

		timeline.append({
			"process": process,
			"start": current_time,
			"end": end_time
		})

		process.remaining_time -= execution_time
		current_time = end_time

		# Processos que chegaram durante a execução
		# entram na fila antes do processo interrompido.
		while not pending.is_empty() and pending[0].arrival_time <= current_time:
			ready_queue.append(pending.pop_front())

		if process.remaining_time > 0:
			ready_queue.append(process)
		else:
			process.completion_time = current_time
			process.turnaround_time = (
				process.completion_time - process.arrival_time
			)
			process.waiting_time = (
				process.turnaround_time - process.burst_time
			)

	return timeline
