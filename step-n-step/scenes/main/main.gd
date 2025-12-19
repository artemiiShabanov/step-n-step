extends Node2D

@onready var ball = $Ball
@onready var road = $Road

const canvas_width = 1179.0
const canvas_height = 2277.0
const ball_padding = 600.0

func _ready() -> void:
	Player.scan_failed.connect(_handle_scan_fail)
	_setup_controls()
	_layout()

func _setup_controls():
	Controller.left.connect(handle_left)
	Controller.right.connect(handle_right)
	Controller.force.connect(handle_force)

func _layout():
	var safe_area_rect = DisplayServer.get_display_safe_area()
	var bottom_safe_area_y = canvas_height - safe_area_rect.size.y - safe_area_rect.position.y
	ball.position.y = canvas_height - bottom_safe_area_y - ball_padding

func handle_left():
	ball.move_left()
	$CanvasLayer/VBoxContainer/Label.text += "L"
	
func handle_right():
	ball.move_right()
	$CanvasLayer/VBoxContainer/Label.text += "R"
	
func handle_force():
	ball.force()
	$CanvasLayer/VBoxContainer/Label.text += "F"

func _handle_scan_fail():
	$CanvasLayer/VBoxContainer/Label2.text += " FAIL "
	ball.hit()

func _on_basic_gap_tile_activated(colliding_body: Node2D) -> void:
	$CanvasLayer/VBoxContainer/Label2.text += "-"

func _on_ball_started_colliding() -> void:
	Player.start_scanning()

func _on_ball_stopped_colliding() -> void:
	Player.stop_scanning()

func _on_ball_crashed() -> void:
	pass # Replace with function body.


func _on_road_tile_activated(tile_id: String, tile_type: String, meta: Array, colliding_body: Node2D) -> void:
	$CanvasLayer/VBoxContainer/Label2.text += "+"
	Player.scanned()
