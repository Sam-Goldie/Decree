extends Node2D

var player_scene = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var tile_scene = preload("res://Tile.tscn")
signal confirm_move
signal confirm_attack

@onready
var player = player_scene.instantiate()
@onready
var active_entity = player
@onready
var enemies = [enemy_scene.instantiate(), enemy_scene.instantiate()]
@onready
var board = [[enemies[0], null, null, null], [null, player, null, null], [null, null, null, null],[null, null, null, enemies[1]]]

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	player.hp = 3
	for enemy in enemies:
		enemy.hp = 3
		enemy.damage = 1
		enemy.board = board
	for i in range(board.size()):
		for j in range(board[i].size()):
			var current = board[j][i]
			var tile = tile_scene.instantiate()
			tile.position = Vector2(j * 16, i * 16)
			terrain_layer.add_child(tile)
			if current != null:
				current.position = Vector2(i * 16, j * 16)
				current.board_position = Vector2(i, j)
				navigation_layer.add_child(current)
				
				


#func move_player(position):
	#board[player.position[0]][player.position[1]] = null
	#if board[position[0]][position[1]] == null:
		#board[position[0]][position[1]] = player
	#player.position = position

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = int_position - (int_position % Vector2i(16,16))
	return snapped_position / 16
	
func is_in_range(position1, position2, range):
	if abs(position1[0] - position2[0]) + abs(position1[1] - position2[1]) <= range:
		return true
	else:
		return false 
	

#func _on_tile_pressed(target):
	#clear_dead()
	#var board_position = player.global_position / 16
	#var board_dest = target / 16
	#if board[board_dest[1]][board_dest[0]] == null:
		#board[board_position[1]][board_position[0]] = null
		#board[board_dest[1]][board_dest[0]] = player
		#player.position = target
		#player.board_position = target / 16
	#player.select_target()
	#take_enemy_turns()

func take_enemy_turns():
	for i in range(len(enemies)):
		var enemy = enemies[i]
		active_entity = enemy
		board[enemy.board_position[0]][enemy.board_position[1]] = null 
		enemy.move(player.board_position)
		board[enemy.board_position[0]][enemy.board_position[1]] = enemy
		var attack_target = enemy.find_targets(player)
		print(player.board_position)
		if attack_target != null:
			damage(attack_target, enemy.damage)
			if attack_target.hp <= 0:
				attack_target.queue_free()
			else:
				var nodes = attack_target.get_children()
				var health = nodes[1]
				health.text = str(attack_target.hp)
	active_entity = player

func clear_dead():
	var dead_idx = []
	for i in range(len(enemies)):
		if enemies[i] == null:
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		enemies.remove_at(dead_idx[-i-1])

func damage(target, amount):
	target.hp -= amount
	if target.hp <= 0:
		target.queue_free()


func move(entity, target):
	var current_board_position = get_board_position(entity.position)
	if board[target[0]][target[1]] == null:
		entity.position = target * 16
		board[current_board_position[0]][current_board_position[1]] = null
		board[target[0]][target[1]] = entity
		entity.has_moved = true

func attack(entity, target):
	var attacker_board_position = get_board_position(entity.position)
	if board[target[0]][target[1]] != null and board[target[0]][target[1]] != entity:
		damage(board[target[0]][target[1]], entity.damage)
		entity.has_moved = false
		take_enemy_turns()
	
func _input(event):
	if active_entity != player:
		return
	if event is InputEventMouseButton and event.pressed:
		var mouse_position = get_global_mouse_position()
		if mouse_position[0] > 64 or mouse_position[0] < 0 or mouse_position[1] > 64 or mouse_position[1] < 0:
			return
		var board_position = get_board_position(mouse_position)
		if !active_entity.has_moved:
			move(active_entity, board_position)
		else:
			attack(active_entity, board_position)
		
