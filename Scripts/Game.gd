extends Node2D

@onready var tile_map : TileMap = $TileMap

const INVALID_CELL : int = -1
const BRICK_ATLAS_COORD : Vector2i = Vector2i(4, 3)

var ground_layer : int = 0
var tile_source_id : int = 0

#grid
var grid_x : int = 17
var grid_y : int = 12

#spawn point
const spawn_pos = [Vector2i(1,2), Vector2i(1,12), Vector2i(17,2), Vector2i(17,12)]
var power_up_pos : Dictionary = {}

#player
var players : Array

var is_destructible_custom_data = "is_destructible"
const player = preload("res://Scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var gameState = get_node("/root/GameState") 
	if (!gameState):
		print_debug("Game can't be started. No game setting found.")
		return
		
	if (gameState.number_of_player < 0 || gameState.number_of_player > 4):
		print_debug("Game can't be started. Game only allowed 1-4 players.")
		return
	
	for idx in gameState.number_of_player:
		spawn_player(idx)
		
	init_power_up()
	
func _process(delta):
	var i : int = 1
	for player in players:
		var life_count : int = player.life_count if is_instance_valid(player) else 0
		var labelId : String = "P" + str(i)
		get_node(labelId).text = labelId + ":" + str(life_count)
		i += 1

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

func check_reset_game():
	var gameState = get_node("/root/GameState")
	if (gameState.number_of_player == 1):
		if (!is_instance_valid(players[0]) || !players[0].is_alive):
			get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
	else:
		#check if at least one player still alive
		var players_alive : int = 0
		for player in players:
			if (is_instance_valid(player) && player.is_alive):
				players_alive += 1
		
		if (players_alive <= 1):
			get_tree().change_scene_to_file("res://Scenes/gameover.tscn")

func is_valid_position_for_power_up(tile_coord : Vector2i, is_init : bool):
	#check if it's the player position
	for player in players:
		if ((player.is_alive) && (tile_map.local_to_map(player.get_position()) == tile_coord)):
			return false
		
	#avoid any player starting pos
	if (spawn_pos.has(tile_coord)):
		return false
		
	#check if the tile is available
	if (!is_init && (tile_map.get_cell_source_id(ground_layer, tile_coord) != INVALID_CELL)):
		return false
		
	if (is_init && ((tile_map.get_cell_atlas_coords(ground_layer, tile_coord) != BRICK_ATLAS_COORD) || power_up_pos.find_key(tile_coord))):
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
	
func init_power_up():
	var gameSetting = get_tree().root.get_node("Game/Level/GameSetting") as GameSetting
	if (gameSetting):
		for item in gameSetting.power_up_distributions:
			for x in gameSetting.power_up_distributions[item]:
				power_up_pos[find_valid_power_up_loc(true)] = item
					
func sprinkle_power_up(power_ups: Dictionary):
	for item in power_ups:
		for x in power_ups[item]:
			var pu = find_power_up_resources_by_name(item)
			pu.position = tile_map.map_to_local(find_valid_power_up_loc(false))
			add_child(pu)
	
func find_power_up_resources_by_name(power_up_name: String):
	var gameSetting = get_tree().root.get_node("Game/Level/GameSetting") as GameSetting
	if (gameSetting):
		for item in gameSetting.power_up_distributions:
			var item_instance = item.instantiate()
			if item_instance.display_name == power_up_name:
				return item_instance
	
func spawn_player(player_idx: int):
	var player_instance = player.instantiate()
	var tile_coord = spawn_pos[player_idx]
	player_instance.player_idx = player_idx
	player_instance.position = tile_map.map_to_local(tile_coord)
	player_instance.starting_pos = tile_map.map_to_local(tile_coord)
	player_instance.connect("dead", _on_player_dead)
	add_child(player_instance)
	players.append(player_instance)

func spawn_bomb(bomb_instance: Node, pos: Vector2):
	var tile_coord = tile_map.local_to_map(pos)
	bomb_instance.position = tile_map.map_to_local(tile_coord)
	bomb_instance.connect("destroy", _on_bomb_destroy)
	add_child(bomb_instance)

func _on_bomb_destroy(pos: Vector2):
	var tile_coord = tile_map.local_to_map(pos)
	remove_destructable(tile_coord)

func _on_player_dead(power_ups: Dictionary = {}):
	sprinkle_power_up(power_ups)
	check_reset_game()
