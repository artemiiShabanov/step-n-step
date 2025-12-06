extends Node2D
class_name Chunk

signal tile_activated(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D)
signal gap_activated(colliding_body: Node2D)

@export var chunk_id: String = ""
@export var target_collision_layer: int = 1

# Internal

func _ready():
	if chunk_id.is_empty():
		chunk_id = str(get_instance_id())
	
	add_to_group("chunks")
	
	# Connect signals from all existing children
	for child in get_children():
		_handle_child_entered_tree(child)
	
	# Also connect for any children added later
	child_entered_tree.connect(_handle_child_entered_tree)

func _handle_child_entered_tree(child):
	if child is Gap:
		child.gap_activated.connect(_handle_gap_signal)
	elif child is Tile:
		child.tile_activated.connect(_handle_tile_signal)

func _handle_tile_signal(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D):
	tile_activated.emit(tile_id, tile_type, meta, colliding_body)

func _handle_gap_signal(colliding_body):
	gap_activated.emit(colliding_body)

# Virtual functions for subclasses

func set_difficulty(difficulty: float):
	pass
