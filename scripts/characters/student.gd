class_name Student
extends CharacterBody2D

signal student_selected(process: Process)

@export var movement_speed: float = 100.0

var target_position: Vector2
var is_moving: bool = false

var process: Process

@onready var process_label: Label = $ProcessLabel

func _ready() -> void:
	$ClickArea.input_event.connect(_on_click_area_input_event)
	print("Área clicável conectada!")
	
func setup(new_process: Process) -> void:
	process = new_process
	process_label.text = "P%d\n%du" % [
		process.pid,
		process.burst_time
	]

func move_to(destination: Vector2) -> void:
	target_position = destination
	is_moving = true

func wait_until_arrival() -> void:
	while is_moving:
		await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	if not is_moving:
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(target_position)
	var distance := global_position.distance_to(target_position)

	if distance <= movement_speed * delta:
		global_position = target_position
		velocity = Vector2.ZERO
		is_moving = false
		return

	velocity = direction * movement_speed
	move_and_slide()
	
func _on_click_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if process != null and process.state == "ready":
				student_selected.emit(process)
