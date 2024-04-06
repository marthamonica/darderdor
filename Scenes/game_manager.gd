extends Node

class_name GameManager

signal toggle_game_paused(is_paused : bool)
var is_game_paused : bool = false:
	get:
		return is_game_paused
	set(value):
		is_game_paused = value
		get_tree().paused = is_game_paused
		emit_signal("toggle_game_paused", is_game_paused)

func _input(event : InputEvent):
	if (event.is_action_pressed("ui_cancel")):
		is_game_paused = !is_game_paused
