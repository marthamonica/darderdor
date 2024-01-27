extends CharacterBody2D

signal dead

@export var initial_speed: int = 100
@export var bomb_count: int = 1
@onready var is_alive: bool = true

@onready var animation: AnimationPlayer = $AnimationPlayer

#power up effect
var additional_speed : int = 0
var additional_bomb_reach : int = 0

const power_up = preload("res://Scripts/PowerUp.gd")
var bomb = preload("res://Scenes/bomb.tscn")

func handleInput():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * (initial_speed + additional_speed)
		
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE && event.pressed:
			if (bomb_count > 0): spawn_bomb()

func updateAnimation():
	if velocity.length() == 0 && animation.is_playing():
		animation.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		
		animation.play("walk" + direction)

func handleDead():
	animation.play("dead")

func _physics_process(delta):
	if is_alive:
		handleInput()
		move_and_slide()
		updateAnimation()
	else:
		handleDead()

func spawn_bomb():
	bomb_count -= 1
	var world = get_tree().root.get_node("World") 
	var bomb_instance = bomb.instantiate()
	#bomb_instance.position = position
	bomb_instance.connect("explode", on_bomb_exploding)
	bomb_instance.reach += additional_bomb_reach
	world.spawn_bomb(bomb_instance, self.position)
	#get_parent().add_child(bomb_instance)
	
func on_bomb_exploding():
	bomb_count += 1

func _on_hurt_box_area_entered(area: Area2D):
	if area.is_in_group("hazard"):
		is_alive = false
		
	else:
		var powerup = area.get_parent() as PowerUp
		if (powerup):
			var inventory = find_child("Inventory")
	
			if (inventory):
				inventory.add_item(powerup.display_name)
				
				#apply power up effect
				additional_speed += powerup.additional_player_speed
				bomb_count += powerup.additional_bomb_count
				additional_bomb_reach += powerup.additional_bomb_reach
				
				powerup.destroy()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "dead":
		#emit_signal("dead")
		queue_free()
