extends Node2D

@onready var ball = $Ball

func _ready() -> void:
	Controller.left.connect(handle_left)
	Controller.right.connect(handle_right)
	Controller.force.connect(handle_force)

func handle_left():
	ball.move_left()
	print("left")
	
	
func handle_right():
	ball.move_right()
	print("right")
	
	
func handle_force():
	ball.force()
	print("force")
