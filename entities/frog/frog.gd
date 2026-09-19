class_name Frog
extends Area2D

@export var step = 32.0
@export var time_to_perform_step = 0.5

@onready var animated_sprite = $AnimatedSprite2D

var is_performing_step = false
var curr_step_time = 0.0
var curr_position = Vector3()
var next_position = Vector3()

func _ready() -> void:
	curr_position = position
	animated_sprite.play("Idle")

func _physics_process(delta: float) -> void:
	if is_performing_step:
		curr_step_time += delta
		if curr_step_time > time_to_perform_step:
			_end_step()
		position = curr_position.lerp(
				next_position, curr_step_time / time_to_perform_step
		)
	else:
		next_position = position
		if Input.is_action_pressed("movement_left"):
			next_position.x -= step
			_start_step()
		elif Input.is_action_pressed("movement_right"):
			next_position.x += step
			_start_step()
		elif Input.is_action_pressed("movement_up"):
			next_position.y -= step
			_start_step()
		elif Input.is_action_pressed("movement_down"):
			next_position.y += step
			_start_step()

func _start_step() -> void:
	is_performing_step = true
	curr_step_time = 0.0
	curr_position = position
	animated_sprite.rotation = Vector2.UP.angle_to(curr_position.direction_to(next_position))
	animated_sprite.play("Jump")

func _end_step() -> void:
	is_performing_step = false
	curr_step_time = time_to_perform_step
	animated_sprite.play("Idle")
