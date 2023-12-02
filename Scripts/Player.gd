extends CharacterBody2D

@export var speed: int = 100
var n_bomb: int = 2
@onready var animation: AnimationPlayer = $AnimationPlayer

var bomb = preload("res://Scenes/bomb.tscn")

func handleInput():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
		
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE && event.pressed:
			if n_bomb > 0: spawn_bomb()

func updateAnimation():
	if velocity.length() == 0 && animation.is_playing():
		animation.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		
		animation.play("walk" + direction)

func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()

func spawn_bomb():
	n_bomb -= 1
	var bomb_instance = bomb.instantiate()
	bomb_instance.position = position
	bomb_instance.connect("explode", _on_bomb_explode)
	get_parent().add_child(bomb_instance)
	
func _on_bomb_explode():
	n_bomb += 1

