class_name Spawner
extends Node2D

@export var start_timer: float
var _timer: float = start_timer
var _sequence_item_times: Array[float] = []
var _item_count: int

@export var start_spawn: Node2D
@export var end_spawn: Node2D

@export var spawn_sequence: SpawnSequence
var _sequence_i: int = 0
var _obstacles: Array[Obstacle] = []

func _ready() -> void:
	_timer = start_timer
	var sequence_total_time = 0.0
	var sequence_index_found = false
	for item_i in range(spawn_sequence.items.size()):
		sequence_total_time += spawn_sequence.items[item_i].time_to_wait_next
		_sequence_item_times.push_back(sequence_total_time)
		if !sequence_index_found and _timer <= sequence_total_time:
			_sequence_i = item_i
			sequence_index_found = true
	_item_count = _sequence_item_times.size()
	
func update(delta: float) -> void:
	#TODO: this accumulates error with delta. we should account for log positioning
	#based on timer?
	_timer += delta
	
	if delta > 0:
		var sequence_timer = _sequence_item_times[_sequence_i]
		if _timer >= sequence_timer:
			_sequence_i = (_sequence_i + 1) % _item_count
			spawn_obstacle_at_start()
			if _sequence_i == 0:
				_timer = _timer - sequence_timer
	
	elif delta < 0:
		var prev_sequence_i = (_sequence_i + _item_count - 1) % _item_count
		var prev_sequence_timer = _sequence_item_times[prev_sequence_i] \
				if prev_sequence_i != _item_count-1 else 0
		if _timer <= prev_sequence_timer:
			spawn_obstacle_at_end()
			_sequence_i = prev_sequence_i
			if _sequence_i == _item_count-1:
				_timer = _sequence_item_times[_item_count-1] - abs(_timer)
	
	for obstacle in _obstacles:
		obstacle.update(delta)
	
	#TODO: Clear up obstacle out of view

func spawn_obstacle_at_start() -> void:
	_obstacles.push_back(spawn_obstacle_at(start_spawn.position))

func spawn_obstacle_at_end() -> void:
	var obstacle = spawn_obstacle_at(end_spawn.position)
	obstacle.position.x += obstacle.get_x_size()
	_obstacles.push_front(obstacle)

func spawn_obstacle_at(spawn_pos: Vector2) -> Obstacle:
	var curr_spawn_item = spawn_sequence.items[_sequence_i]
	var obstacle: Obstacle = curr_spawn_item.obstacleToSpawn.instantiate()
	add_child(obstacle)
	obstacle.position = spawn_pos
	obstacle.speed_per_second = curr_spawn_item.speed_per_second
	print("Spawned ", obstacle.name, " at", spawn_pos)
	return obstacle
