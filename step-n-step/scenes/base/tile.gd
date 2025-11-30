extends Area2D
class_name Tile

signal tile_activated(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D)

@export var tile_id: String = ""
@export var target_collision_layer: int = 1

# Internal

func _ready():
	if tile_id.is_empty():
		tile_id = str(get_instance_id())
	
	area_entered.connect(_on_body_entered)
	collision_mask = 1 << (target_collision_layer - 1)
	add_to_group("tiles")

func _on_body_entered(body: Node2D):
	if body.collision_layer & (1 << (target_collision_layer - 1)):
		tile_activated.emit(tile_id, _get_tile_type(), _get_meta(), body)
		_on_tile_activated(body)

# Virtual functions for subclasses

func _on_tile_activated(body: Node2D):
	pass

func _get_tile_type() -> String:
	return ""

func _get_meta() -> Array:
	return []
