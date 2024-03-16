extends Node2D

signal explode
signal destroy(pos: Vector2)

enum Direction { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }

@export var reach: int = 1

var flame = preload("res://Scenes/flame.tscn")

func _ready():
	$BlastCast_up.target_position = reach * 16 * Vector2.UP
	$BlastCast_down.target_position = reach * 16 * Vector2.DOWN
	$BlastCast_left.target_position = reach * 16 * Vector2.LEFT
	$BlastCast_right.target_position = reach * 16 * Vector2.RIGHT

func start_blaze():
	var flame_instance = flame.instantiate()
	flame_instance.position = position
	get_parent().add_child(flame_instance)

func extend_blaze(n: int, direction: Vector2):
	assert( n >= 0, "ERROR: Bomb reach cannot be negative value" )
	if (n > 0):
		var flame_instance = flame.instantiate()
		flame_instance.direction = atan2(direction.x, -direction.y)
		flame_instance.position = position + (16 * n * direction)
		flame_instance.type = "edge" if n == reach else "strand"
		get_parent().add_child(flame_instance)
		extend_blaze(n-1, direction)

func project_blasts() -> Array[int]:
	var up = reach
	var right = reach
	var down = reach
	var left = reach
	const collision_threshold = 1 # prevent wrong rounding to tile coordinates

	if ($BlastCast_up.is_colliding()):
		var y_collision = abs($BlastCast_up.get_collision_point().y - position.y)
		up = floor(y_collision / 16)
			
		var collider = $BlastCast_up.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", $BlastCast_up.get_collision_point() + collision_threshold * Vector2.UP)
	
	if ($BlastCast_down.is_colliding()):
		var y_collision = abs($BlastCast_down.get_collision_point().y - position.y)
		down = floor(y_collision / 16)
			
		var collider = $BlastCast_down.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", $BlastCast_down.get_collision_point() + collision_threshold * Vector2.DOWN)
	
	if ($BlastCast_left.is_colliding()):
		var x_collision = abs($BlastCast_left.get_collision_point().x - position.x)
		left = floor(x_collision / 16)
			
		var collider = $BlastCast_left.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", $BlastCast_left.get_collision_point() + collision_threshold * Vector2.LEFT)
	
	if ($BlastCast_right.is_colliding()):
		var x_collision = abs($BlastCast_right.get_collision_point().x - position.x)
		right = floor(x_collision / 16)
		
		var collider = $BlastCast_right.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", $BlastCast_right.get_collision_point() + collision_threshold * Vector2.RIGHT)
	
	return [up, right, down, left]

func detonate():
	$TickingTimer.stop()
	$BombArea.remove_from_group("explosive")
	
	emit_signal("explode")
	var blast_reaches = project_blasts()
	start_blaze()
	extend_blaze(blast_reaches[0], Vector2.UP)
	extend_blaze(blast_reaches[1], Vector2.RIGHT)
	extend_blaze(blast_reaches[2], Vector2.DOWN)
	extend_blaze(blast_reaches[3], Vector2.LEFT)
	
	queue_free()
	
	
func _on_ticking_timer_timeout():
	detonate()
