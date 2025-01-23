extends TileMapLayer

#var player_class = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var tile_scene = preload("res://Tile.tscn")

@onready
var player = $Player

var board = [[null, null, null, null], [null, player, null, null], [null, null, enemy_scene.instantiate(), null],[null, null, null, null]]

func _ready():
	for i in range(board.size()):
		for j in range(board[i].size()):
			var tile = tile_scene.instantiate()
			tile.position = Vector2(i * 16, j * 16)
			add_child(tile)
			
