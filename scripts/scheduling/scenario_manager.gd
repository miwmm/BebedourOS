class_name ScenarioManager
extends RefCounted

# Cada processo contém:
# [PID, tempo de chegada, tempo de execução]

const SCENARIOS := {
	"FCFS": [
		# Cenário 1: básico - 3 alunos
		[
			[1, 0, 4],
			[2, 1, 3],
			[3, 2, 2]
		],

		# Cenário 2: intermediário - 4 alunos
		[
			[1, 2, 3],
			[2, 0, 4],
			[3, 1, 2],
			[4, 3, 5]
		],

		# Cenário 3: avançado - 5 alunos
		[
			[1, 1, 3],
			[2, 0, 5],
			[3, 1, 2],
			[4, 3, 4],
			[5, 2, 6]
		]
	],

	"SJF": [
		# Cenário 1: básico - 3 alunos
		[
			[1, 0, 5],
			[2, 0, 3],
			[3, 0, 2]
		],

		# Cenário 2: intermediário - 4 alunos
		[
			[1, 0, 4],
			[2, 0, 2],
			[3, 0, 6],
			[4, 0, 3]
		],

		# Cenário 3: avançado - 5 alunos
		[
			[1, 0, 4],
			[2, 1, 2],
			[3, 2, 1],
			[4, 3, 5],
			[5, 4, 3]
		]
	],

	"RR": [
		# Cenário 1: básico - 3 alunos
		[
			[1, 0, 5],
			[2, 1, 3],
			[3, 2, 2]
		],

		# Cenário 2: intermediário - 4 alunos
		[
			[1, 0, 2],
			[2, 1, 5],
			[3, 2, 3],
			[4, 3, 4]
		],

		# Cenário 3: avançado - 5 alunos
		[
			[1, 0, 6],
			[2, 2, 4],
			[3, 3, 1],
			[4, 4, 5],
			[5, 5, 3]
		]
	]
}


# Retorna os processos de um cenário.
static func get_processes(
	algorithm: String,
	scenario_index: int
) -> Array[Process]:

	var result: Array[Process] = []

	if not SCENARIOS.has(algorithm):
		push_error("Algoritmo desconhecido: " + algorithm)
		return result

	var scenarios: Array = SCENARIOS[algorithm]

	if scenario_index < 0 or scenario_index >= scenarios.size():
		push_error("Cenário inválido: " + str(scenario_index))
		return result

	for data in scenarios[scenario_index]:
		var process := Process.new(
			data[0],
			data[1],
			data[2]
		)

		result.append(process)

	return result


# Retorna a quantidade de cenários disponíveis.
static func get_scenario_count(algorithm: String) -> int:
	if not SCENARIOS.has(algorithm):
		return 0

	return SCENARIOS[algorithm].size()
