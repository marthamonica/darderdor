extends Node2D

@onready var tile_map : TileMap = $TileMap

const INVALID_CELL : int = -1
const BOMB_ATLAS_COORD : Vector2i = Vector2i (6,5)
const BOMB_COUNT_INC_POWER_UP_ATLAS_COORD : Vector2i = Vector2i (7,8)
const BOMB_RADIUS_INC_POWER_UP_ATLAS_COORD : Vector2i = Vector2i (8,9)
const PLAYER_SPEED_INC_POWER_UP_ATLAS_COORD : Vector2i = Vector2i (20,8)
const BRICK_ATLAS_COORD : Vector2i = Vector2i(25, 8)
const WALL_ATLAS_COORD : Vector2i = Vector2i(11, 3)

var ground_layer : int = 0
var power_up_layer : int = 1
var tile_source_id : int = 0

#grid
var grid_x : int = 17
var grid_y : int = 11

#power up
var bomb_timer : float = 1.5

var initial_bomb_radius : int = 1
var initial_bomb_count : int = 1
var initial_player_speed : float = 1

var player_speed_modifier : float = 0.5
var bomb_radius_modifier : int = 1
var bomb_placed_count : int = 0

var additional_bomb_power_up_count : int = 0
var player_speed_power_up_count : int = 0
var bomb_radius_power_up_count : int = 0

#player inventory
var life_count : int = 3

#spawn point
const spawn_pos = [Vector2i(1,1), Vector2i(1,11), Vector2i(17,1), Vector2i(17,11)]

var is_destructible_custom_data = "is_destructible"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("Label").text = "Life = " + str(life_count) + "\n" + "Bomb count = " + str(initial_bomb_count + additional_bomb_power_up_count) + "\n" + "Bomb radius = " + str(initial_bomb_radius + (bomb_radius_power_up_count * bomb_radius_modifier)) + "\n" + "Player speed = " + str(initial_player_speed + (player_speed_power_up_count * player_speed_modifier))

func _input(event):
	if Input.is_action_just_pressed("click"):
		
		#get mouse position
		var mouse_pos : Vector2 = get_global_mouse_position()
		var tile_coord : Vector2i = tile_map.local_to_map(mouse_pos)
		
		#check if it's not empty tiles
		if (tile_map.get_cell_source_id(ground_layer, tile_coord) == INVALID_CELL):
			#check if powerup layer has anything to add
			var power_up_atlas_coord : Vector2i = tile_map.get_cell_atlas_coords(power_up_layer, tile_coord)
			
			match power_up_atlas_coord:
				BOMB_COUNT_INC_POWER_UP_ATLAS_COORD:
					additional_bomb_power_up_count += 1
					tile_map.set_cell(power_up_layer, tile_coord, -1)
				BOMB_RADIUS_INC_POWER_UP_ATLAS_COORD:
					bomb_radius_power_up_count += 1
					tile_map.set_cell(power_up_layer, tile_coord, -1)
				PLAYER_SPEED_INC_POWER_UP_ATLAS_COORD:
					player_speed_power_up_count += 1
					tile_map.set_cell(power_up_layer, tile_coord, -1)
				_:
					#if there is no power up place bomb and we have more bomb to place
					if (bomb_placed_count < (initial_bomb_count + additional_bomb_power_up_count)): 
						bomb_placed_count += 1
						tile_map.set_cell(ground_layer, tile_coord, tile_source_id, BOMB_ATLAS_COORD)
						trigger_bomb_timer(tile_coord, bomb_timer, initial_bomb_radius + (bomb_radius_power_up_count * bomb_radius_modifier))


func trigger_bomb_timer(tile_coord, time, radius):
	await get_tree().create_timer(time).timeout
	
	#after timeout, we delete the bomb
	tile_map.set_cell(ground_layer, tile_coord, -1)
	bomb_placed_count -= 1
	
	#remove all destructible tile within radius
	var tile_coord_x : int = tile_coord.x
	var tile_coord_y : int = tile_coord.y
	for x in range(tile_coord_x - radius, tile_coord_x + radius + 1):
		var curr_coord : Vector2i = Vector2i(x, tile_coord_y)
		remove_destructable(curr_coord)
		check_player_in_coord(curr_coord)
		
	for y in range(tile_coord_y - radius, tile_coord_y + radius + 1):
		var curr_coord : Vector2i = Vector2i(tile_coord_x, y)
		remove_destructable(Vector2i(tile_coord_x, y))
		check_player_in_coord(curr_coord)
			
	
func remove_destructable(tile_coord):
	#remove all destructible on ground layer
	var tile_data : TileData = tile_map.get_cell_tile_data(ground_layer, tile_coord)
	
	if tile_data:
		var is_destructible = tile_data.get_custom_data(is_destructible_custom_data)
		
		if is_destructible:
			tile_map.set_cell(ground_layer, tile_coord, -1)
			
	#remove all power up within radius
	else:
		tile_map.set_cell(power_up_layer, tile_coord, -1)
		
func get_player_coord():
	return tile_map.local_to_map($Player.get_position())

func check_player_in_coord(tile_coord):
	if (get_player_coord() == tile_coord):
		reset_game()

func reset_game():
	life_count -= 1
		
	#pick a new starting pos
	var new_pos : Vector2i = spawn_pos[randi() % spawn_pos.size()]
	$Player.set_position(tile_map.map_to_local(new_pos))
	
	#reset player power up
	sprinkle_power_up()
	
	if (life_count == 0):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func is_valid_position_for_power_up(tile_coord):
	#check if it's the player position
	if (get_player_coord() == tile_coord):
		return false
		
	#check if the tile is available on ground layer
	if (tile_map.get_cell_source_id(ground_layer, tile_coord) != INVALID_CELL):
		return false
	
	#check if tile is available on power up layer
	if (tile_map.get_cell_source_id(power_up_layer, tile_coord) != INVALID_CELL):
		return false
		
	return true
	
func find_valid_power_up_loc():
	var pos_x : int = randi_range(1, grid_x)
	var pos_y : int = randi_range(1, grid_y)
	var pos : Vector2i = Vector2i(pos_x, pos_y)
	
	while (!is_valid_position_for_power_up(pos)):
		pos_x = randi_range(1, grid_x)
		pos_y = randi_range(1, grid_y)
		pos = Vector2i(pos_x, pos_y)
	
	return pos
	
func sprinkle_power_up():
	#sprinkle additional bomb power up and reset
	for x in additional_bomb_power_up_count:
		tile_map.set_cell(power_up_layer, find_valid_power_up_loc(), tile_source_id, BOMB_COUNT_INC_POWER_UP_ATLAS_COORD)
	additional_bomb_power_up_count = 0
	
	#sprinkle bomb radius power up and reset
	for x in bomb_radius_power_up_count:
		tile_map.set_cell(power_up_layer, find_valid_power_up_loc(), tile_source_id, BOMB_RADIUS_INC_POWER_UP_ATLAS_COORD)
	bomb_radius_power_up_count = 0
	
	#sprinkle player speed power up and reset
	for x in player_speed_power_up_count:
		tile_map.set_cell(power_up_layer, find_valid_power_up_loc(), tile_source_id, PLAYER_SPEED_INC_POWER_UP_ATLAS_COORD)
	player_speed_power_up_count = 0

func spawn_bomb(bomb_instance: Node, pos: Vector2):
	var tile_coord = tile_map.local_to_map(pos)
	bomb_instance.position = tile_map.map_to_local(tile_coord)
	bomb_instance.connect("destroy", _on_bomb_destroy)
	add_child(bomb_instance)

func _on_bomb_destroy(pos: Vector2):
	var tile_coord = tile_map.local_to_map(pos)
	remove_destructable(tile_coord)

func _on_player_dead():
	reset_game()
