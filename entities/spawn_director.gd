class_name SpawnDirector
extends Node2D

@export var reversed = false

@onready var spawners: Array = get_children()
	
func _process(delta: float) -> void:
	if reversed: delta = -delta
	for spawner in spawners:
		spawner.update(delta)
