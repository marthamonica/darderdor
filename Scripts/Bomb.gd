extends Node2D

signal explode
signal destroy(pos: Vector2)

enum Direction { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }

@export var reach: int = 1
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

	if (blast_up.is_colliding()):
		var y_collision = abs(blast_up.get_collision_point().y - position.y)
		up = floor(y_collision / 16)
			
		var collider = blast_up.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", blast_up.get_collision_point() + collision_threshold * Vector2.UP)
	
	if (blast_down.is_colliding()):
		var y_collision = abs(blast_down.get_collision_point().y - position.y)
		down = floor(y_collision / 16)
			
		var collider = blast_down.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", blast_down.get_collision_point() + collision_threshold * Vector2.DOWN)
	
	if (blast_left.is_colliding()):
		var x_collision = abs(blast_left.get_collision_point().x - position.x)
		left = floor(x_collision / 16)
			
		var collider = blast_left.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", blast_left.get_collision_point() + collision_threshold * Vector2.LEFT)
	
	if (blast_right.is_colliding()):
		var x_collision = abs(blast_right.get_collision_point().x - position.x)
		right = floor(x_collision / 16)
		
		var collider = blast_right.get_collider()
		if collider.is_in_group("explosive"):
			collider.get_parent().detonate()
		else:	
			emit_signal("destroy", blast_right.get_collision_point() + collision_threshold * Vector2.RIGHT)
	
	return [up, right, down, left]

func detonate():
	$TickingTimer.stop()
	$Area2D.remove_from_group("explosive")
	
	emit_signal("explode")
	$AnimatedSprite2D.play("explode")
	var blast_reaches = project_blasts()
	extend_blaze(blast_reaches[0], Vector2.UP)
	extend_blaze(blast_reaches[1], Vector2.RIGHT)
	extend_blaze(blast_reaches[2], Vector2.DOWN)
	extend_blaze(blast_reaches[3], Vector2.LEFT)
	
	
func _on_ticking_timer_timeout():
	detonate()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "explode":
		queue_free()
