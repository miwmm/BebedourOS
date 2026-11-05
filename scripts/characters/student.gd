
class_name Student
extends CharacterBody2D

signal student_selected(process: Process)

var process: Process

@onready var process_label: Label = $ProcessLabel

@export var movement_speed: float = 100.0

var target_position: Vector2
var is_moving: bool = false
var movement_path: Array[Vector2] = []
var has_entered_queue: bool = false
var is_entering_queue: bool = false

func _ready() -> void:
	$ClickArea.input_event.connect(_on_click_area_input_event)


# Configura o processo associado ao aluno.
func setup(new_process: Process) -> void:
	process = new_process

	process_label.text = "P%d\n%du" % [
		process.pid,
		process.burst_time
	]


# Atualiza o tempo restante de execução.
# Utilizado pelo Round Robin.
func update_remaining_time() -> void:
	if process == null:
		return

	process_label.text = "P%d\n%du" % [
		process.pid,
		process.remaining_time
	]


# Movimenta o aluno diretamente até um destino.
func move_to(destination: Vector2) -> void:
	movement_path.clear()
	movement_path.append(destination)
	_start_next_movement()


# Movimenta o aluno por vários pontos intermediários.
func move_along_path(points: Array[Vector2]) -> void:
	movement_path = points.duplicate()
	is_entering_queue = true
	_start_next_movement()

# Atualiza o destino final sem interromper o percurso.
func update_queue_destination(destination: Vector2) -> void:
	if not movement_path.is_empty():
		movement_path[movement_path.size() - 1] = destination
	elif is_moving:
		target_position = destination
	else:
		move_to(destination)

# Inicia o movimento até o próximo ponto.
func _start_next_movement() -> void:
	if movement_path.is_empty():
		is_moving = false
		is_entering_queue = false
		velocity = Vector2.ZERO
		return

	target_position = movement_path.pop_front()
	is_moving = true


# Executa a movimentação do aluno.
func _physics_process(delta: float) -> void:
	if not is_moving:
		velocity = Vector2.ZERO
		return

	var distance := global_position.distance_to(target_position)

	if distance <= movement_speed * delta:
		global_position = target_position
		velocity = Vector2.ZERO

		_start_next_movement()
		return

	var direction := global_position.direction_to(target_position)

	velocity = direction * movement_speed
	move_and_slide()


# Detecta quando o jogador clica no aluno.
func _on_click_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if process != null and process.state == "ready":
				student_selected.emit(process)
