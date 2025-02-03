extends Node2D

var player_scene = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var tile_scene = preload("res://Tile.tscn")

@onready
var player = player_scene.instantiate()
@onready
var enemies = [enemy_scene.instantiate(), enemy_scene.instantiate()]
@onready
var board = [[enemies[0], enemies[1], null, null], [null, player, null, null], [null, null, null, null],[null, null, null, null]]

func _ready():
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	player.hp = 3
	for enemy in enemies:
		enemy.hp = 3
	for i in range(board.size()):
		for j in range(board[i].size()):
			var current = board[j][i]
			var tile = tile_scene.instantiate()
			tile.position = Vector2(j * 16, i * 16)
			tile.connect("pressed", _on_tile_pressed.bind(tile.position))
			terrain_layer.add_child(tile)
			if current != null:
				current.position = Vector2(j * 16, i * 16)
				current.board_position = Vector2(j, i)
				navigation_layer.add_child(current)
				
				


#func move_player(position):
	#board[player.position[0]][player.position[1]] = null
	#if board[position[0]][position[1]] == null:
		#board[position[0]][position[1]] = player
	#player.position = position


func _on_tile_pressed(target):
	clear_dead()
	var board_position = player.position / 16
	var board_dest = target / 16
	if board[board_dest[1]][board_dest[0]] == null:
		board[board_position[1]][board_position[0]] = null
		board[board_dest[1]][board_dest[0]] = player
		player.position = target
		player.board_position = target / 16
	take_enemy_turns()

func take_enemy_turns():
	for i in range(len(enemies)):
		var enemy = enemies[i]
		board[enemy.board_position[0]][enemy.board_position[1]] = null 
		enemy.move(player.board_position, board)
		board[enemy.board_position[0]][enemy.board_position[1]] = enemy
		var attack_target = enemy.find_targets(board, player)
		print(player.board_position)
		if attack_target != null:
			attack_target.hp -= 1
			if attack_target.hp <= 0:
				attack_target.queue_free()
			else:
				var nodes = attack_target.get_children()
				var health = nodes[1]
				health.text = str(attack_target.hp)

func clear_dead():
	var dead_idx = []
	for i in range(len(enemies)):
		if enemies[i] == null:
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		enemies.remove_at(dead_idx[-i-1])
