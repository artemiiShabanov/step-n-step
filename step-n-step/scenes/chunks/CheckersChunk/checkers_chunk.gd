extends Chunk

class_name CheckersChunk

const canvas_size: Vector2 = Vector2(1179, 3400)

@export var grid_size: Vector2i = Vector2i(3, 8)
@export var padding: Vector2 = Vector2(20, 20)
@export var margin: Vector2 = Vector2(50, 50)
const node_type = preload("res://scenes/tiles/BasicTile/basic_tile.tscn")
#const node_type2 = preload("res://scenes/tiles/BasicGap/basic_gap.tscn")
@export var center_grid: bool = true

var cell_size: Vector2
var total_grid_size: Vector2

func _ready():
	calculate_cell_size()
	create_checkerboard()
	super._ready()

func calculate_cell_size():
	var available_width = canvas_size.x - ((grid_size.x - 1) * padding.x) - margin.x * 2
	var available_height = canvas_size.y - ((grid_size.y - 1) * padding.y) - margin.y * 2
	
	cell_size = Vector2(
		available_width / grid_size.x,
		available_height / grid_size.y
	)
	
	total_grid_size = Vector2(
		(grid_size.x * cell_size.x) + ((grid_size.x - 1) * padding.x),
		(grid_size.y * cell_size.y) + ((grid_size.y - 1) * padding.y)
	)

func create_checkerboard():
	# Clear existing children
	#for child in get_children():
		#child.queue_free()
	
	# Calculate starting position (with optional centering)
	var start_position = Vector2.ZERO
	#if center_grid and get_parent() is Node2D:
		#var parent_size = get_viewport().get_visible_rect().size
		#start_position = (parent_size - (total_grid_size + margin * 2)) * 0.5
	start_position += margin
	
	# Create grid
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			# Checker pattern logic
			var is_node = (x + y) % 2 == 0
			
			if is_node:
				var cell_node = node_type.instantiate()
			
			# Instantiate node
			#var cell_node
			#if is_type1 and node_type1:
			#elif node_type2:
				#cell_node = node_type2.instantiate()
			#else:
				#continue
			
				add_child(cell_node)
			
				# Calculate position with padding
				var pos_x = start_position.x + x * (cell_size.x + padding.x) + cell_size.x / 2
				var pos_y = start_position.y + y * (cell_size.y + padding.y) + cell_size.y / 2
				cell_node.position = Vector2(pos_x, pos_y)
				
				# Optionally set size if the node has a size property
				if cell_node.has_method("set_size"):
					cell_node.set_size(cell_size)
				elif "size" in cell_node:
					cell_node.size = cell_size

# Optional: Helper function to get cell center position
func get_cell_center_position(grid_x: int, grid_y: int) -> Vector2:
	var start_position = margin
	if center_grid and get_parent() is Node2D:
		var parent_size = get_viewport().get_visible_rect().size
		start_position = (parent_size - (total_grid_size + margin * 2)) * 0.5 + margin
	
	return Vector2(
		start_position.x + grid_x * (cell_size.x + padding.x) + cell_size.x * 0.5,
		start_position.y + grid_y * (cell_size.y + padding.y) + cell_size.y * 0.5
	)

# Optional: Convert screen position to grid coordinates
func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var start_position = margin
	if center_grid and get_parent() is Node2D:
		var parent_size = get_viewport().get_visible_rect().size
		start_position = (parent_size - (total_grid_size + margin * 2)) * 0.5 + margin
	
	var relative_pos = screen_pos - start_position
	var grid_x = int(relative_pos.x / (cell_size.x + padding.x))
	var grid_y = int(relative_pos.y / (cell_size.y + padding.y))
	
	# Clamp to grid bounds
	grid_x = clamp(grid_x, 0, grid_size.x - 1)
	grid_y = clamp(grid_y, 0, grid_size.y - 1)
	
	return Vector2i(grid_x, grid_y)

# Optional: Get the cell size (useful for other scripts)
func get_cell_size() -> Vector2:
	return cell_size

# Optional: Get the total grid dimensions (including padding)
func get_total_grid_size() -> Vector2:
	return total_grid_size

# Optional: Update grid if parameters change
func update_grid():
	calculate_cell_size()
	create_checkerboard()

# Optional: Draw debug visualization
#func _draw():
	#if not Engine.is_editor_hint():
		#return
		#
	## Draw canvas boundary
	#var start_position = margin
	#if center_grid and get_parent() is Node2D:
		#var parent_size = get_viewport().get_visible_rect().size
		#start_position = (parent_size - (total_grid_size + margin * 2)) * 0.5 + margin
	#
	## Draw canvas rectangle
	#draw_rect(Rect2(start_position, total_grid_size), Color(0.5, 0.5, 1, 0.3), false, 2.0)
	#
	## Draw margin rectangle
	#draw_rect(Rect2(start_position - margin, total_grid_size + margin * 2), Color(1, 0, 0, 0.2), false, 1.0)
	#
	## Draw each cell boundary
	#for y in range(grid_size.y):
		#for x in range(grid_size.x):
			#var pos_x = start_position.x + x * (cell_size.x + padding.x)
			#var pos_y = start_position.y + y * (cell_size.y + padding.y)
			#draw_rect(Rect2(pos_x, pos_y, cell_size.x, cell_size.y), Color(0, 1, 0, 0.1), false, 1.0)
