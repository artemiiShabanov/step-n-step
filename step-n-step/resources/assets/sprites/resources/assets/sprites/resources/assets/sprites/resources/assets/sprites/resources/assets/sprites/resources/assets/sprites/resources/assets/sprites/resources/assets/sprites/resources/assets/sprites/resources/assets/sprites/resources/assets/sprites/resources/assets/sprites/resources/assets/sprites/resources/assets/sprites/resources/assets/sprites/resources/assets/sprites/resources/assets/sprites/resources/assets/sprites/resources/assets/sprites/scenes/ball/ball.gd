extends StaticBody2D

# Ball properties
@export var move_speed: float = 800.0 # Horizontal move speed
@export var max_scale: float = 2  # Max scale at bounce top
@export var min_scale: float = 1      # Min scale at bounce bottom
@export var bounce_speed: float = 3.0   # How fast the ball bounces
@export var force_speed: float = 3.0   # Additional speed applyed on force

# Bounce state variables
var is_bouncing: bool = true
var bounce_timer: float = 0.0
var current_scale: float = 1.0
# Force variables 
var is_forcing: bool = false
var force_progress: float = 0.0
# Extra speed
var extra_speed = 0

# Movement
var target_x: float = 0.0
var is_moving: bool = false
const movement_tolerance: float = 10.0  # How close to target before stopping

# Lane system
enum Lane { LEFT, CENTER, RIGHT }
var current_lane: Lane = Lane.CENTER

# Lane positions (customize these based on your game layout)
const lane_positions = {
	Lane.LEFT: 200.0,
	Lane.CENTER: 500.0, 
	Lane.RIGHT: 800.0
}

# Collisions



# API


func move_left():
	match current_lane:
		Lane.LEFT:
			print("Already at leftmost lane")
		Lane.CENTER:
			_move_to_lane(Lane.LEFT)
		Lane.RIGHT:
			_move_to_lane(Lane.CENTER)

func move_right():
	match current_lane:
		Lane.LEFT:
			_move_to_lane(Lane.CENTER)
		Lane.CENTER:
			_move_to_lane(Lane.RIGHT)
		Lane.RIGHT:
			print("Already at rightmost lane")

func force():
	if !is_forcing:
		extra_speed = force_speed
		is_forcing = true
		force_progress = 0.0
		print("Force activated - forcing ball down")


# Internaal


func _ready():
	# Start with ball at center lane
	current_lane = Lane.CENTER
	target_x = lane_positions[Lane.CENTER]
	position.x = target_x
	current_scale = (max_scale + min_scale) / 2.0
	_update_scale()

func _process(delta):
	# Handle movement
	_handle_movement(delta)
	
	# Handle bouncing animation
	_handle_bouncing(delta)
	
	# Update scale
	_update_scale()

func _handle_movement(delta):
	if is_moving:
		var direction = sign(target_x - position.x)
		var distance = abs(target_x - position.x)
		
		# Move towards target
		position.x += direction * move_speed * delta
		
		# Stop if close enough to target
		if distance <= movement_tolerance:
			position.x = target_x
			is_moving = false

func _handle_bouncing(delta):
	if is_forcing:
		force_progress += delta * (extra_speed + bounce_speed)
		
		# When force is complete, return to normal bouncing
		if force_progress >= 1.0:
			is_forcing = false
			force_progress = 0.0
			bounce_timer = 1.5 * PI  # Start from bottom position
		else: 
			var x = lerp(current_scale, min_scale, force_progress)
			current_scale = x
	
	elif is_bouncing:
		# Normal bouncing animation
		bounce_timer += delta * (bounce_speed + extra_speed)
		
		# Calculate scale using sine wave
		var bounce_progress = sin(bounce_timer)
		current_scale = remap(bounce_progress, -1.0, 1.0, min_scale, max_scale)
		
		# Reset bounce cycle when complete
		if bounce_timer >= 2 * PI:
			bounce_timer = 0.0
			extra_speed = 0.0

func _update_scale():
	scale = Vector2(current_scale, current_scale)

func _move_to_lane(lane: Lane):
	current_lane = lane
	target_x = lane_positions[lane]
	is_moving = true
