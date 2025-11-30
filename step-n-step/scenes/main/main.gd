extends Node2D

@onready var ball = $Ball

func _ready() -> void:
	Controller.left.connect(handle_left)
	Controller.right.connect(handle_right)
	Controller.force.connect(handle_force)
	

func handle_left():
	ball.move_left()
	$CanvasLayer/VBoxContainer/Label.text += "L"
	
	
func handle_right():
	ball.move_right()
	$CanvasLayer/VBoxContainer/Label.text += "R"
	
	
func handle_force():
	ball.force()
	$CanvasLayer/VBoxContainer/Label.text += "F"


func _on_basic_tile_tile_activated(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D) -> void:
	$CanvasLayer/VBoxContainer/Label2.text += "+"


func _on_basic_gap_tile_activated(colliding_body: Node2D) -> void:
	$CanvasLayer/VBoxContainer/Label2.text += "-"
