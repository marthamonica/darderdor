extends Area2D

signal explode

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	animation.play("ticking")
	
func _on_timer_timeout():
	emit_signal("explode")
	queue_free()
