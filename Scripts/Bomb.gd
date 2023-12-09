extends Node2D

signal explode

enum Direction { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }

@export var reach: int = 1

var flame = preload("res://Scenes/flame.tscn")

func _ready():
	pass

func blaze():
	var flame_instance = flame.instantiate()
	flame_instance.position = position
	get_parent().add_child(flame_instance)
	
func extend_blaze(ref: Vector2, n: int, direction: Direction):
	assert( n > 0, "ERROR: Bomb reach should be greater than 0" )
	n -= 1
	var flame_instance = flame.instantiate()
	flame_instance.direction = direction * 90
	match direction: 
		Direction.UP:
			flame_instance.position = ref + Vector2(0, -16)
		Direction.RIGHT:
			flame_instance.position = ref + Vector2(16, 0)
		Direction.DOWN:
			flame_instance.position = ref + Vector2(0, 16)
		Direction.LEFT:
			flame_instance.position = ref + Vector2(-16, 0)
	
	if (n > 0):
		flame_instance.type = "strand"
		extend_blaze(flame_instance.position, n, direction)
	else:
		flame_instance.type = "edge"
		
	get_parent().add_child(flame_instance)
	
func _on_ticking_timer_timeout():
	emit_signal("explode")
	blaze()
	extend_blaze(position, reach, Direction.UP)
	extend_blaze(position, reach, Direction.RIGHT)
	extend_blaze(position, reach, Direction.DOWN)
	extend_blaze(position, reach, Direction.LEFT)
	queue_free()
