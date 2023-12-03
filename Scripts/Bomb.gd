extends Node2D

signal explode

const LAYER_BOMB = 0
const LAYER_BANG = 1

func _ready():
	pass
	
func _on_ticking_timer_timeout():
	emit_signal("explode")
	$TileMap.set_layer_enabled(LAYER_BANG, true)
	$TileMap.set_layer_enabled(LAYER_BOMB, false)
	$BangTimer.start()

func _on_bang_timer_timeout():
	queue_free()
