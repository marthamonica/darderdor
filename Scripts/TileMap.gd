extends TileMap

const DESTROYED_WALL_ATLAS_COORD: Vector2i = Vector2i(5, 3)
const GROUND_LAYER: int = 1
const TILE_SOURCE_ID: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func remove_destructible(tile_coord: Vector2i):
	var tile_data : TileData = get_cell_tile_data(GROUND_LAYER, tile_coord)
	if tile_data:
		var is_destructible = tile_data.get_custom_data("is_destructible")
		if is_destructible:
			set_cell(GROUND_LAYER, tile_coord, TILE_SOURCE_ID, DESTROYED_WALL_ATLAS_COORD)
			await get_tree().create_timer(1.0).timeout
			set_cell(GROUND_LAYER, tile_coord, -1)
			
		
