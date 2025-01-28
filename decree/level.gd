extends Node2D

var player_class = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var tile_scene = preload("res://Tile.tscn")

@onready
var player = player_class.instantiate()
@onready
var board = [[enemy_scene.instantiate(), null, null, null], [null, player, null, null], [null, null, enemy_scene.instantiate(), null],[null, null, null, null]]
@onready
var enemy1 = board[0][0]

func _ready():
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	for i in range(board.size()):
		for j in range(board[i].size()):
			var current = board[i][j]
			var tile = tile_scene.instantiate()
			tile.position = Vector2(i * 16, j * 16)
			tile.connect("pressed", _on_tile_pressed.bind(tile.position))
			terrain_layer.add_child(tile)
			if current != null:
				current.position = Vector2(i * 16, j * 16)
				navigation_layer.add_child(current)
				
				


#func move_player(position):
	#board[player.position[0]][player.position[1]] = null
	#if board[position[0]][position[1]] == null:
		#board[position[0]][position[1]] = player
	#player.position = position


func _on_tile_pressed(target):
	var board_position = player.position / 16
	var board_dest = target / 16
	if board[board_dest[1]][board_dest[0]] == null:
		board[board_position[1]][board_position[0]] = null
		board[board_dest[1]][board_dest[0]] = player
		player.position = target
	board[0][0].move(player.position)
	var attack_target = enemy1.find_targets(board, player)
	if attack_target != null:
		attack_target.queue_free()
		
