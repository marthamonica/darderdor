extends Node2D

@export var type: String = "core"
@export var direction: float = 0

func _ready():
	$AnimatedSprite2D.rotate(direction)
	$AnimatedSprite2D.play(type)

func _on_spawn_timer_timeout():
	queue_free()
