extends Node

enum ONCE_SOUND {
	MOVE,
	TAP
}

var once_sounds = {
	#ONCE_SOUND.MOVE: preload("res://Resourses/Sounds/321.mp3"),
	#ONCE_SOUND.TAP: preload("res://Resourses/Sounds/gear.mp3"),
}

enum LASTING_SOUND {
	MUSIC,
}

var lasting_sounds = {
	#LASTING_SOUND.MUSIC: preload("res://Resourses/Sounds/321.mp3"),
}

var once_audio_player: AudioStreamPlayer
var lasting_players: Dictionary
var surface_players: Dictionary

func _ready():
	once_audio_player = AudioStreamPlayer.new()
	once_audio_player.volume_db = 20
	add_child(once_audio_player)
	#init_lasting_players()

func init_lasting_players():
	for sound in LASTING_SOUND:
		var asp = AudioStreamPlayer.new()
		asp.stream = lasting_sounds[LASTING_SOUND[sound]]
		add_child(asp)
		lasting_players[LASTING_SOUND[sound]] = asp

func play_once_sound(sound: ONCE_SOUND):
	once_audio_player.stream = once_sounds[sound]
	once_audio_player.play()

func start_lasting_sound(sound: LASTING_SOUND):
	lasting_players[sound].play()
	
func stop_lasting_sound(sound: LASTING_SOUND):
	lasting_players[sound].stop()
