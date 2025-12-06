@tool
extends Area2D
class_name BasicGap

@export var size: Vector2 = Vector2(100, 100):
	set(value):
		size = value
		_update_collision()
		queue_redraw()

@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D

#func _ready():
	#_update_collision()
	#queue_redraw()

func _update_collision():
	if collision and collision.shape is RectangleShape2D:
		collision.shape.size = size
	if sprite:
		sprite.scale = Vector2(size.x / 100, size.y / 100)
