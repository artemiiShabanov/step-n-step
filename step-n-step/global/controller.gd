extends Node

# Signal definitions
signal left
signal right
signal force

# Constants
enum SwipeDirection { LEFT, RIGHT, UP, DOWN }

# Configuration
var swipe_min_distance = 50  # Minimum distance in pixels for a swipe
var tap_max_duration = 0.3   # Maximum time in seconds for a tap

# Touch tracking variables
var touch_start_position: Vector2
var touch_start_time: float
var is_touching = false

func _ready():
	set_process_input(true)

func _input(event):
	if Input.is_action_just_pressed("left"):
		left.emit()
	
	if Input.is_action_just_pressed("right"):
		right.emit()
	
	if Input.is_action_just_pressed("force"):
		force.emit()
	
	if event is InputEventScreenTouch: # Handle touch events for tap
		_handle_touch_event(event)

func _handle_touch_event(event: InputEventScreenTouch):
	if event.pressed:
		# Touch started
		touch_start_position = event.position
		touch_start_time = Time.get_time_dict_from_system()["second"]
		is_touching = true
	else:
		# Touch ended
		var touch_end_position = event.position
		var touch_end_time = Time.get_time_dict_from_system()["second"]
		is_touching = false
		
		# Process the touch gesture
		_process_touch_gesture(touch_end_position, touch_end_time)

func _process_touch_gesture(end_position: Vector2, end_time: float):
	var duration = end_time - touch_start_time
	var distance = touch_start_position.distance_to(end_position)
	
	# Check if it's a tap
	if distance < swipe_min_distance and duration < tap_max_duration:
		force.emit()
	# Check if it's a swipe (optional - for direction detection)
	elif distance >= swipe_min_distance:
		var direction = _get_swipe_direction(touch_start_position, end_position)
		if direction == SwipeDirection.LEFT:
			left.emit()
		elif direction == SwipeDirection.RIGHT:
			right.emit()
		elif direction == SwipeDirection.DOWN:
			force.emit()

func _get_swipe_direction(start_pos: Vector2, end_pos: Vector2) -> int:
	var dx = end_pos.x - start_pos.x
	var dy = end_pos.y - start_pos.y
	
	if abs(dx) > abs(dy):
		return SwipeDirection.LEFT if dx < 0 else SwipeDirection.RIGHT
	else:
		return SwipeDirection.UP if dy < 0 else SwipeDirection.DOWN
