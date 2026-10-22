class_name Student
extends CharacterBody2D

@export var movement_speed: float = 100.0

var target_position: Vector2
var is_moving: bool = false

var process: Process

@onready var process_label: Label = $ProcessLabel


func setup(new_process: Process) -> void:
	process = new_process
	process_label.text = "P%d" % process.pid

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
