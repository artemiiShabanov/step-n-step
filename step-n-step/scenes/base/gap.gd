extends Area2D
class_name Gap

signal tile_activated(colliding_body: Node2D)

@export var tile_id: String = ""
@export var target_collision_layer: int = 1

# Internal

func _ready():
	if tile_id.is_empty():
		tile_id = str(get_instance_id())
	
	area_entered.connect(_on_body_entered)
	collision_mask = 1 << (target_collision_layer - 1)
	add_to_group("gaps")

func _on_body_entered(body: Node2D):
	if body.collision_layer & (1 << (target_collision_layer - 1)):
		tile_activated.emit(body)
		_on_gap_activated(body)

# Virtual functions for subclasses

func _on_gap_activated(body: Node2D):
	pass
