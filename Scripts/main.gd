extends Node2D

@onready var tile_map : TileMap = $TileMap

const INVALID_CELL : int = -1
const BOMB_ATLAS_COORD : Vector2i = Vector2i (6,5)
const BOMB_COUNT_INC_POWER_UP_ATLAS_COORD : Vector2i = Vector2i (7,8)
const BOMB_RADIUS_INC_POWER_UP_ATLAS_COORD : Vector2i = Vector2i (8,9)
const PLAYER_SPEED_INC_POWER_UP_ATLAS_COORD : Vector2i = Vector2i (20,8)

var ground_layer : int = 0
var power_up_layer : int = 1
var tile_source_id : int = 0
var bomb_timer : float = 1.5
var bomb_radius : int = 1
var bomb_count : int = 1
var player_speed : float = 1
var player_speed_modifier : float = 0.5
var bomb_placed_count : int = 0

var is_destructible_custom_data = "is_destructible"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("Label").text = "Bomb count = " + str(bomb_count) + "\n" + "Bomb radius = " + str(bomb_radius) + "\n" + "Player speed = " + str(player_speed) 

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
					bomb_count += 1
					tile_map.set_cell(power_up_layer, tile_coord, -1)
				BOMB_RADIUS_INC_POWER_UP_ATLAS_COORD:
					bomb_radius += 1
					tile_map.set_cell(power_up_layer, tile_coord, -1)
				PLAYER_SPEED_INC_POWER_UP_ATLAS_COORD:
					player_speed += 0.5
					tile_map.set_cell(power_up_layer, tile_coord, -1)
				_:
					#if there is no power up place bomb and we have more bomb to place
					if (bomb_placed_count < bomb_count): 
						bomb_placed_count += 1
						tile_map.set_cell(ground_layer, tile_coord, tile_source_id, BOMB_ATLAS_COORD)
						trigger_bomb_timer(tile_coord, bomb_timer, bomb_radius)


func trigger_bomb_timer(tile_coord, time, radius):
	await get_tree().create_timer(time).timeout
	
	#after timeout, we delete the bomb
	tile_map.set_cell(ground_layer, tile_coord, -1)
	bomb_placed_count -= 1
	
	#remove all destructible tile within radius
	var tile_coord_x : int = tile_coord.x
	var tile_coord_y : int = tile_coord.y
	for x in range(tile_coord_x - radius, tile_coord_x + radius + 1):
		for y in range(tile_coord_y - radius, tile_coord_y + radius + 1):
			var curr_coord : Vector2i = Vector2i(x, y)
			
			#remove all destructible on ground layer
			var tile_data : TileData = tile_map.get_cell_tile_data(ground_layer, curr_coord)
			
			if tile_data:
				var is_destructible = tile_data.get_custom_data(is_destructible_custom_data)
				
				if is_destructible:
					tile_map.set_cell(ground_layer, curr_coord, -1)
					
			#remove all power up within radius
			else:
				tile_map.set_cell(power_up_layer, curr_coord, -1)
			
	
	
	
