extends Node2D

@export var type: String = "core"
@export var direction: float = 0

func _ready():
	$AnimatedSprite2D.rotate(direction)
	$AnimatedSprite2D.play(type)
	if (type == "core"):
		$AudioBoom.play()

func _on_spawn_timer_timeout():
	queue_free()

func _on_flame_area_area_entered(area: Area2D):
	if (area.get_parent().is_in_group("mortal")):
		area.get_parent().die()
