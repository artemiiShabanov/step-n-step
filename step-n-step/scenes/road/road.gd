extends Node2D

# Signals
signal tile_activated(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D)
signal gap_activated(colliding_body: Node2D)

# Chunk scenes - preload these in the inspector
var chunk_scenes: Array[PackedScene] = [
	preload("res://scenes/chunks/RunningChunk/running_chunk.tscn"),
	preload("res://scenes/chunks/ZebraChunk/zebra_chunk.tscn"),
	preload("res://scenes/chunks/CheckersChunk/checkers_chunk.tscn")
]

# Basic configuration
@export var scroll_speed: float = 400.0
@export var chunk_height: float = 3400
@export var chunk_buffer: int = 2

# Difficulty configuration
@export_group("Difficulty Settings")
@export var max_difficulty: float = 10.0
@export var difficulty_increase_rate: float = 0.1  # Per chunk
@export var speed_increase_multiplier: float = 1.2  # Final speed = base * this
@export var max_scroll_speed: float = 500.0

# Difficulty curve - use a Curve resource for precise control
@export var difficulty_curve: Curve

# Chunk weights - control how chunk frequency changes with difficulty
var chunk_weights: Array[float] = [1.0, 1.0, 1.0]  # Should match chunk_scenes size

# Runtime variables
var active_chunks: Array[Node2D] = []
var current_difficulty: float = 0.0
var chunks_spawned: int = 0
var base_scroll_speed: float

func _ready():
	base_scroll_speed = scroll_speed
	spawn_initial_chunks()

func _process(delta):
	move_chunks(delta)
	manage_chunks()

func move_chunks(delta):
	# Move all chunks downward (inverted movement)
	for chunk in active_chunks:
		chunk.position.y += scroll_speed * delta

func manage_chunks():
	spawn_chunks_above()
	remove_chunks_below()

func spawn_initial_chunks():
	for i in range(chunk_buffer + 1):
		spawn_chunk()

func spawn_chunks_above():
	if active_chunks.is_empty():
		spawn_chunk()
		return
	
	# Get the topmost chunk
	var top_chunk = active_chunks.back()
	var top_chunk_bottom_edge = top_chunk.position.y + chunk_height
	
	# Spawn new chunk when we're close to the top of the highest one
	if top_chunk_bottom_edge > 0:
		spawn_chunk()

func remove_chunks_below():
	if active_chunks.is_empty():
		return
	
	var viewport_height = get_viewport().size.y
	
	# Remove chunks that are completely below the viewport
	for i in range(active_chunks.size() - 1, -1, -1):
		var chunk = active_chunks[i]
		var chunk_top_edge = chunk.position.y
		
		# If the chunk's top edge is below the viewport bottom, remove it
		if chunk_top_edge > viewport_height + chunk_height:
			chunk.queue_free()
			active_chunks.remove_at(i)

func spawn_chunk():
	if chunk_scenes.is_empty():
		push_error("No chunk scenes assigned!")
		return
	
	# Update difficulty before spawning
	update_difficulty()
	
	# Select chunk based on current difficulty
	var selected_chunk_index = select_chunk_by_difficulty()
	var new_chunk = chunk_scenes[selected_chunk_index].instantiate()
	
	# Position the new chunk above the current highest chunk
	if active_chunks.is_empty():
		new_chunk.position.y = 0
	else:
		var top_chunk = active_chunks.back()
		new_chunk.position.y = top_chunk.position.y - chunk_height
	
	# Pass difficulty information to the chunk (if it has a method for it)
	if new_chunk.has_method("set_difficulty"):
		new_chunk.set_difficulty(current_difficulty)
	
	add_child(new_chunk)
	connect_chunk(new_chunk)
	active_chunks.append(new_chunk)
	chunks_spawned += 1

func connect_chunk(chunk: Chunk):
	chunk.tile_activated.connect(_handle_tile_signal)
	chunk.gap_activated.connect(_handle_gap_signal)

func _handle_tile_signal(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D):
	tile_activated.emit(tile_id, tile_type, meta, colliding_body)
	
func _handle_gap_signal(colliding_body):
	gap_activated.emit(colliding_body)

func update_difficulty():
	# Increase difficulty
	current_difficulty = min(max_difficulty, chunks_spawned * difficulty_increase_rate)
	
	# Apply difficulty curve if available
	var curved_difficulty = current_difficulty
	if difficulty_curve:
		curved_difficulty = difficulty_curve.sample(current_difficulty / max_difficulty) * max_difficulty
	
	# Update scroll speed based on difficulty
	update_scroll_speed(curved_difficulty)

func update_scroll_speed(difficulty: float):
	var difficulty_ratio = difficulty / max_difficulty
	scroll_speed = base_scroll_speed + (max_scroll_speed - base_scroll_speed) * difficulty_ratio
	
	# Alternative: exponential speed increase
	# scroll_speed = base_scroll_speed * pow(speed_increase_multiplier, difficulty_ratio)

func select_chunk_by_difficulty() -> int:
	if chunk_scenes.size() != chunk_weights.size():
		push_warning("Chunk scenes and weights arrays don't match! Using equal weights.")
		return randi() % chunk_scenes.size()
	
	# Adjust weights based on difficulty
	var adjusted_weights = calculate_adjusted_weights()
	
	# Weighted random selection
	var total_weight = 0.0
	for weight in adjusted_weights:
		total_weight += weight
	
	var random_value = randf() * total_weight
	var cumulative_weight = 0.0
	
	for i in range(adjusted_weights.size()):
		cumulative_weight += adjusted_weights[i]
		if random_value <= cumulative_weight:
			return i
	
	return adjusted_weights.size() - 1

func calculate_adjusted_weights() -> Array:
	var adjusted_weights = []
	var difficulty_ratio = current_difficulty / max_difficulty
	
	for i in range(chunk_weights.size()):
		var base_weight = chunk_weights[i]
		var adjusted_weight = base_weight
		
		# Example: Make harder chunks more likely as difficulty increases
		# You can customize this logic based on your chunk types
		match i:
			0: # Easy chunk - decrease weight with difficulty
				adjusted_weight = base_weight * (1.0 - difficulty_ratio * 0.5)
			1: # Medium chunk - keep mostly constant
				adjusted_weight = base_weight
			2: # Hard chunk - increase weight with difficulty
				adjusted_weight = base_weight * (1.0 + difficulty_ratio * 2.0)
		
		adjusted_weights.append(max(0.1, adjusted_weight))  # Prevent zero weights
	
	return adjusted_weights

# Public API for difficulty control
func set_difficulty_multiplier(multiplier: float):
	difficulty_increase_rate *= multiplier

func set_difficulty_level(level: float):
	current_difficulty = clamp(level, 0.0, max_difficulty)
	update_scroll_speed(current_difficulty)

func get_difficulty_level() -> float:
	return current_difficulty

func get_difficulty_progress() -> float:
	return current_difficulty / max_difficulty

func reset_difficulty():
	current_difficulty = 0.0
	chunks_spawned = 0
	scroll_speed = base_scroll_speed

## Optional: Save/Load difficulty state
#func save_difficulty_state() -> Dictionary:
	#return {
		#"current_difficulty": current_difficulty,
		#"chunks_spawned": chunks_spawned,
		#"scroll_speed": scroll_speed
	#}
#
#func load_difficulty_state(state: Dictionary):
	#current_difficulty = state.get("current_difficulty", 0.0)
	#chunks_spawned = state.get("chunks_spawned", 0)
	#scroll_speed = state.get("scroll_speed", base_scroll_speed)
