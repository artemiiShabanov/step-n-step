extends Node

enum TYPE {
	TAP,
	MOVE
}

func vibrate(type: TYPE):
	match type:
		TYPE.TAP:
			Input.vibrate_handheld(60, 0.2)
		TYPE.MOVE:
			Input.vibrate_handheld(20, 0.7)
