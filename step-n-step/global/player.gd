extends Node

const MAX_SCORE_KEY = "max_score"

signal max_score_updated
signal score_updated

var rng = RandomNumberGenerator.new()

var max_score: int

var previous_score: int = 0
var previous_was_best: bool = false

var current_score: int:
	set(value):
		current_score = value
		if current_score - max_score > 100:
			save_score_if_needed()
var heal_checkpoint = 0

func _ready() -> void:
	Storage.load_from_cache()
	max_score = Storage.get_value(MAX_SCORE_KEY, 0)


func reset():
	previous_score = current_score
	current_score = 0
	score_updated.emit()


func add(value):
	current_score += value
	score_updated.emit()


func finish():
	save_score_if_needed()


func save_score_if_needed():
	if current_score > max_score:
		previous_was_best = true
		max_score = current_score
		Storage.set_value(MAX_SCORE_KEY, max_score)
		max_score_updated.emit()
		Storage.save_to_cache()
