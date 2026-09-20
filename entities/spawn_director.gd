class_name SpawnDirector
extends Node2D

var reversed = false

@onready var spawners: Array = get_children()

func _input(event):
	if event.is_action_pressed("reverse_time"):
		reversed = true
	elif event.is_action_released("reverse_time"):
		reversed = false
	
func _process(delta: float) -> void:
	if reversed: delta = -delta
	
	for spawner in spawners:
		spawner.update(delta)
