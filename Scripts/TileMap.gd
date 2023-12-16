extends TileMap

func _ready():
	connect("destroy", _on_bomb_destroy)

func _on_bomb_destroy(pos: Vector2):
	print(pos)
