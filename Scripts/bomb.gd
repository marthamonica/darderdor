extends Node2D

@onready var tile_map : TileMap = $TileMap

var tile_map_layer : int = 0
var tile_source_id : int = 0
var bomb_timer : float = 1.5
var bomb_radius : int = 1

var is_destructible_custom_data = "is_destructible"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_just_pressed("click"):
		
		#get mouse position
		var mouse_pos : Vector2 = get_global_mouse_position()
		var tile_coord : Vector2i = tile_map.local_to_map(mouse_pos)
		
		#when player is placed, add bomb tiles
		var bomb_atlas_coord : Vector2i = Vector2i (6,5)
		tile_map.set_cell(tile_map_layer, tile_coord, tile_source_id, bomb_atlas_coord)
		
		trigger_bomb_timer(tile_coord, bomb_timer, bomb_radius)


func trigger_bomb_timer(tile_coord, time, radius):
	await get_tree().create_timer(time).timeout
	
	#after timeout, we delete the bomb
	tile_map.set_cell(tile_map_layer, tile_coord, -1)
	
	#remove all destructible tile within radius
	var tile_coord_x : int = tile_coord.x
	var tile_coord_y : int = tile_coord.y
	for x in range(tile_coord_x - radius, tile_coord_x + radius + 1):
		for y in range(tile_coord_y - radius, tile_coord_y + radius + 1):
			var curr_coord : Vector2i = Vector2i(x, y)
			
			var tile_data : TileData = tile_map.get_cell_tile_data(tile_map_layer, curr_coord)
			
			if tile_data:
				var is_destructible = tile_data.get_custom_data(is_destructible_custom_data)
				
				if is_destructible:
					tile_map.set_cell(tile_map_layer, curr_coord, -1)
			
	
	
	
