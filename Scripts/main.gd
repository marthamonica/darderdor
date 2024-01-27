extends Node2D

@onready var tile_map : TileMap = $TileMap

const INVALID_CELL : int = -1
const BRICK_ATLAS_COORD : Vector2i = Vector2i(4, 3)

var ground_layer : int = 0
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
var power_up_pos : Dictionary = {}

var is_destructible_custom_data = "is_destructible"
const player = preload("res://Scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var levelSetting = find_child("LevelSetting")
	if (!levelSetting):
		print_debug("Game can't be started. No level setting found.")
		return
	
	for idx in levelSetting.number_of_player:
		spawn_player(spawn_pos[idx])
		
	sprinkle_power_up(true)

func remove_destructable(tile_coord : Vector2i):
	#remove all destructible on ground layer
	var tile_data : TileData = tile_map.get_cell_tile_data(ground_layer, tile_coord)
	
	if tile_data:
		var is_destructible = tile_data.get_custom_data(is_destructible_custom_data)
		
		if is_destructible:
			tile_map.set_cell(ground_layer, tile_coord, -1)
			if (power_up_pos.has(tile_coord)):
				var pu = power_up_pos[tile_coord].instantiate()
				pu.position = tile_map.map_to_local(tile_coord)
				add_child(pu)
				
				power_up_pos.erase(tile_coord)
		
func get_player_coord():
	return tile_map.local_to_map($Player.get_position())

func check_player_in_coord(tile_coord):
	if (get_player_coord() == tile_coord):
		reset_game()

func reset_game():
	life_count -= 1
		
	#pick a new starting pos
	#var new_pos : Vector2i = spawn_pos[randi() % spawn_pos.size()]
	#$Player.set_position(tile_map.map_to_local(new_pos))
	
	#reset player power up
	sprinkle_power_up(false)
	
	if (life_count == 0):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func is_valid_position_for_power_up(tile_coord : Vector2i, is_init : bool):
	#check if it's the player position
	if (get_player_coord() == tile_coord):
		return false
		
	#check if the tile is available on ground layer
	if (!is_init && (tile_map.get_cell_source_id(ground_layer, tile_coord) != INVALID_CELL)):
		return false
		
	if (is_init && (tile_map.get_cell_atlas_coords(ground_layer, tile_coord) != BRICK_ATLAS_COORD)):
		return false
		
	return true
	
func find_valid_power_up_loc(is_init : bool):
	var pos_x : int = randi_range(1, grid_x)
	var pos_y : int = randi_range(1, grid_y)
	var pos : Vector2i = Vector2i(pos_x, pos_y)
	
	while (!is_valid_position_for_power_up(pos, is_init)):
		pos_x = randi_range(1, grid_x)
		pos_y = randi_range(1, grid_y)
		pos = Vector2i(pos_x, pos_y)
	
	return pos
	
func sprinkle_power_up(is_init : bool):
	if (is_init):
		var levelSetting = find_child("LevelSetting")
		if (levelSetting):
			for item in levelSetting.power_up_distributions:
				for x in levelSetting.power_up_distributions[item]:
					power_up_pos[find_valid_power_up_loc(true)] = item
	else:
		var inventory = find_child("Inventory")
		if (inventory):
			print_debug(inventory.power_ups)
			#sprinkle power up from player inventory
	
func spawn_player(tile_coord: Vector2):
	var player_instance = player.instantiate()
	player_instance.position = tile_map.map_to_local(tile_coord)
	add_child(player_instance)

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
