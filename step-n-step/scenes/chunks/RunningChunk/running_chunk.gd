extends Chunk

class_name RunningChunk

const canvas_size: Vector2 = Vector2(1179, 3400)

@export var line_count: int = 5
var total_count = line_count * 2 - 1
@export var line_padding: int = -50
@export var width_proportion: float = 0.5
@export var margin: Vector2 = Vector2(50, 50)
@export var run_speed: float = 200.0
const node_type_tile = preload("res://scenes/tiles/BasicTile/basic_tile.tscn")
#const node_type_gap = preload("res://scenes/tiles/BasicGap/basic_gap.tscn")

var cell_size: Vector2
#var available_width: float
var min_x: float
var max_x: float

var tiles: Array
var dirs: Array

var rng = RandomNumberGenerator.new()

func _ready():
	calculate_cell_size()
	create_checkerboard()
	super._ready()

func _process(delta: float) -> void:
	for i in tiles.size():
		var tile = tiles[i]
		var dir = dirs[i]
		tile.position.x += run_speed * delta * dir
		if tile.position.x > max_x:
			dirs[i] = -1
		if tile.position.x < min_x:
			dirs[i] = 1

func calculate_cell_size():
	var available_width = canvas_size.x - margin.x * 2
	var tile_width = available_width * width_proportion
	var available_height = canvas_size.y - ((total_count - 1) * line_padding) - margin.y * 2
	
	cell_size = Vector2(
		tile_width,
		available_height / total_count
	)
	
	min_x = margin.x + cell_size.x / 2
	max_x = available_width - margin.x - cell_size.x / 2

func create_checkerboard():
	var start_position = Vector2.ZERO
	start_position += margin
	
	for i in total_count:
		var is_line = i % 2 == 0
		if is_line:
			var cell_node = node_type_tile.instantiate()
		#if is_line and node_type_tile:
			#cell_node = node_type_tile.instantiate()
		#elif node_type_gap:
			#cell_node = node_type_gap.instantiate()
		#else:
			#continue
			add_child(cell_node)
			
			var pos_x: float
			var new_cell_size = cell_size
			var y_shift = 0
			#if !is_line:
				#new_cell_size.y += line_padding * 2
				#new_cell_size.x = available_width
				#y_shift = -line_padding
				#pos_x = start_position.x + new_cell_size.x / 2
			#else:
			tiles.append(cell_node)
			pos_x = rng.randf_range(min_x, max_x)
			dirs.append(1 if (max_x - pos_x) > (pos_x - min_x) else -1)
			
			var pos_y = start_position.y + i * (cell_size.y + line_padding) + new_cell_size.y / 2 + y_shift
			cell_node.position = Vector2(pos_x, pos_y)
			
			if cell_node.has_method("set_size"):
				cell_node.set_size(new_cell_size)
			elif "size" in cell_node:
				cell_node.size = new_cell_size

func get_cell_size() -> Vector2:
	return cell_size

func update_grid():
	calculate_cell_size()
	create_checkerboard()
