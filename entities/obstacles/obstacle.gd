class_name Obstacle
extends Area2D

@export var dangerous = false
@export var carrying = true

var speed_per_second = 32.0

@onready var _shape = $CollisionShape2D.shape

func _ready() -> void:
	pass # Replace with function body.

func get_x_size() -> float:
	return _shape.get_rect().size.x

func update(delta: float) -> void:
	position.x += speed_per_second * delta
