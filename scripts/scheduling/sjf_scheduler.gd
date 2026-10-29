class_name SJFScheduler
extends RefCounted


func schedule(processes: Array[Process]) -> Array[Process]:
	var pending: Array[Process] = processes.duplicate()
	var execution_order: Array[Process] = []
	var current_time: int = 0

	while not pending.is_empty():
		var available: Array[Process] = []

		# Verifica quais processos já chegaram.
		for process in pending:
			if process.arrival_time <= current_time:
				available.append(process)

		# Se nenhum chegou, avança até a próxima chegada.
		if available.is_empty():
			var next_arrival: int = pending[0].arrival_time

			for process in pending:
				next_arrival = mini(next_arrival, process.arrival_time)

			current_time = next_arrival
			continue

		# Escolhe o processo com menor tempo de execução.
		# Em caso de empate, prioriza a chegada e depois o PID.
		available.sort_custom(
			func(a: Process, b: Process) -> bool:
				if a.burst_time != b.burst_time:
					return a.burst_time < b.burst_time

				if a.arrival_time != b.arrival_time:
					return a.arrival_time < b.arrival_time

				return a.pid < b.pid
		)

		var selected: Process = available[0]

		selected.start_time = current_time
		selected.completion_time = current_time + selected.burst_time

		selected.waiting_time = (
			selected.start_time - selected.arrival_time
		)

		selected.turnaround_time = (
			selected.completion_time - selected.arrival_time
		)

		execution_order.append(selected)
		pending.erase(selected)

		current_time = selected.completion_time

	return execution_order
