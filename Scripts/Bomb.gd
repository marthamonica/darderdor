extends Node2D

signal explode
signal destroy(pos: Vector2)

enum Direction { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }

@export var reach: int = 3
@onready var blast_up = $BlastCast_up
@onready var blast_down = $BlastCast_down
@onready var blast_right = $BlastCast_right
@onready var blast_left = $BlastCast_left

var flame = preload("res://Scenes/flame.tscn")

func _ready():
	blast_up.target_position = reach * 16 * Vector2.UP
	blast_down.target_position = reach * 16 * Vector2.DOWN
	blast_left.target_position = reach * 16 * Vector2.LEFT
	blast_right.target_position = reach * 16 * Vector2.RIGHT
	

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
			flame_instance.position = ref + 16 * Vector2.UP
		Direction.RIGHT:
			flame_instance.position = ref + 16 * Vector2.RIGHT
		Direction.DOWN:
			flame_instance.position = ref + 16 * Vector2.DOWN
		Direction.LEFT:
			flame_instance.position = ref + 16 * Vector2.LEFT
	
	if (n > 0):
		flame_instance.type = "strand"
		extend_blaze(flame_instance.position, n, direction)
	else:
		flame_instance.type = "edge"
		
	get_parent().add_child(flame_instance)

func project_blasts() -> Array[int]:
	var up = reach
	var right = reach
	var down = reach
	var left = reach
	const collision_threshold = 1 # prevent wrong rounding to tile coordinates

	if (blast_up.is_colliding()):
		var y_collision = abs(blast_up.get_collision_point().y - position.y)
		up = ceil(y_collision / 16)
		emit_signal("destroy", blast_up.get_collision_point() + collision_threshold * Vector2.UP)
	
	if (blast_down.is_colliding()):
		var y_collision = abs(blast_down.get_collision_point().y - position.y)
		down = ceil(y_collision / 16)
		emit_signal("destroy", blast_down.get_collision_point() + collision_threshold * Vector2.DOWN)
	
	if (blast_left.is_colliding()):
		var x_collision = abs(blast_left.get_collision_point().x - position.x)
		left = ceil(x_collision / 16)
		emit_signal("destroy", blast_left.get_collision_point() + collision_threshold * Vector2.LEFT)
	
	if (blast_right.is_colliding()):
		var x_collision = abs(blast_right.get_collision_point().x - position.x)
		right = ceil(x_collision / 16)
		emit_signal("destroy", blast_right.get_collision_point() + collision_threshold * Vector2.RIGHT)
	
	return [up, right, down, left]
	
	
func _on_ticking_timer_timeout():
	emit_signal("explode")
	blaze()
	var blast_reaches = project_blasts()
	extend_blaze(position, blast_reaches[0], Direction.UP)
	extend_blaze(position, blast_reaches[1], Direction.RIGHT)
	extend_blaze(position, blast_reaches[2], Direction.DOWN)
	extend_blaze(position, blast_reaches[3], Direction.LEFT)
	queue_free()
