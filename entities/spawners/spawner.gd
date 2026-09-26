class_name Spawner
extends Node2D

enum ObstacleDirection {RIGHT = 1, LEFT = -1}

@export var start_timer: float
@export var direction: ObstacleDirection = ObstacleDirection.RIGHT
@export var speed_per_second = 32
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
	_item_count = spawn_sequence.items.size()

	# time caching
	for item_i in range(_item_count):
		sequence_total_time += spawn_sequence.items[item_i].time_to_wait_next
		_sequence_item_times.push_back(sequence_total_time)
	
	# first spawn
	var item_i = 0
	sequence_total_time = 0.0
	while !sequence_index_found:
		sequence_total_time += spawn_sequence.items[item_i].time_to_wait_next
		# normalizing time
		if sequence_total_time > _sequence_item_times[_item_count-1]:
			sequence_total_time -= _sequence_item_times[_item_count-1]
			_timer -= _sequence_item_times[_item_count-1]
		
		if !sequence_index_found:
			_sequence_i = item_i
			spawn_obstacle_at_start()
			if _timer <= sequence_total_time:
				sequence_index_found = true
		item_i = (item_i + 1) % _item_count
	
func update(delta: float) -> void:
	_timer += delta
	
	if delta > 0:
		var sequence_timer = _sequence_item_times[_sequence_i]
		if _timer >= sequence_timer:
			_sequence_i = (_sequence_i + 1) % _item_count
			if _sequence_i == 0:
				_timer = _timer - sequence_timer
			spawn_obstacle_at_start()
	
	elif delta < 0:
		var prev_sequence_i = (_sequence_i + _item_count - 1) % _item_count
		var prev_sequence_timer = _sequence_item_times[prev_sequence_i] \
				if prev_sequence_i != _item_count-1 else 0.0
		if _timer <= prev_sequence_timer:
			spawn_obstacle_at_end()
			_sequence_i = prev_sequence_i
			if _sequence_i == _item_count-1:
				_timer = _sequence_item_times[_item_count-1] - abs(_timer)
	
	for obstacle in _obstacles:
		obstacle.update(delta)
	
	#TODO for performance: clear up obstacle out of view and reuse it to spawn

func spawn_obstacle_at_start() -> void:
	var spawn_position = end_spawn.position if direction == ObstacleDirection.LEFT else start_spawn.position
	var obstacle = spawn_obstacle_at(spawn_position)
	if direction == ObstacleDirection.LEFT:
		obstacle.position.x += obstacle.get_x_size()

	_obstacles.push_back(obstacle)

func spawn_obstacle_at_end() -> void:
	var spawn_position = end_spawn.position if direction == ObstacleDirection.RIGHT else start_spawn.position
	var obstacle = spawn_obstacle_at(spawn_position)
	if direction == ObstacleDirection.RIGHT:
		obstacle.position.x += obstacle.get_x_size()
	
	_obstacles.push_front(obstacle)

func spawn_obstacle_at(spawn_pos: Vector2) -> Obstacle:
	var curr_spawn_item: SpawnSequenceItem = spawn_sequence.items[_sequence_i]
	var obstacle: Obstacle = curr_spawn_item.obstacleToSpawn.instantiate()
	add_child(obstacle)
	obstacle.speed_per_second = speed_per_second if direction == ObstacleDirection.RIGHT else -speed_per_second

	var prev_sequence_i = (_sequence_i + _item_count - 1) % _item_count
	var prev_sequence_timer = _sequence_item_times[prev_sequence_i] \
				if prev_sequence_i != _item_count-1 else 0.0
	var spawn_desync = _timer - prev_sequence_timer

	spawn_pos.x += obstacle.speed_per_second * spawn_desync
	obstacle.position = spawn_pos

	return obstacle
