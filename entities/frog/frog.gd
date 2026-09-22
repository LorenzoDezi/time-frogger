class_name Frog
extends Area2D

@export var step = 32.0
@export var time_to_perform_step = 0.5
@export var dead_frog_scene: PackedScene

@onready var frog_shape = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D
@onready var preventive_raycast: RayCast2D = $CollisionShape2D/PreventiveRaycast

var is_performing_step = false
var curr_step_time = 0.0
var start_position: Vector2
var curr_position = Vector2()
var next_position = Vector2()

func _ready() -> void:
	curr_position = position
	start_position = curr_position
	animated_sprite.play("Idle")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	_process_movement(delta)

func _on_area_entered(area: Area2D) -> void:
	if area is Obstacle:
		var obstacle = area as Obstacle
		if obstacle.dangerous:
			var dead_frog = dead_frog_scene.instantiate()
			get_parent().add_child(dead_frog)
			dead_frog.position = position
			dead_frog.rotation = rotation
			if is_performing_step:
				_end_step()
			position = start_position
			frog_shape.rotation = Vector2.RIGHT.angle()
			#TODO: reset input or a small delay
	else:
		#TODO
		pass

func _process_movement(delta: float) -> void:
	if is_performing_step:
		curr_step_time += delta
		if curr_step_time > time_to_perform_step:
			_end_step()
		position = curr_position.lerp(
				next_position, curr_step_time / time_to_perform_step
		)
	else:
		var target_position: Vector2 = position
		if Input.is_action_pressed("movement_left"):
			target_position.x -= step
			_process_step(target_position)
		elif Input.is_action_pressed("movement_right"):
			target_position.x += step
			_process_step(target_position)
		elif Input.is_action_pressed("movement_up"):
			target_position.y -= step
			_process_step(target_position)
		elif Input.is_action_pressed("movement_down"):
			target_position.y += step
			_process_step(target_position)

func _process_step(target_position: Vector2) -> void:
	frog_shape.rotation = Vector2.UP.angle_to(position.direction_to(target_position))

	preventive_raycast.force_raycast_update()
	if preventive_raycast.is_colliding():
		#TODO: If used for more than just the wall, check if it is a wall
		return
	
	_start_step(target_position)

func _start_step(target_position: Vector2) -> void:
	is_performing_step = true
	curr_step_time = 0.0
	curr_position = position
	next_position = target_position
	animated_sprite.play("Jump")

func _end_step() -> void:
	is_performing_step = false
	curr_step_time = time_to_perform_step
	animated_sprite.play("Idle")
