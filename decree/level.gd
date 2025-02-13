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
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	player.hp = 3
	player.damage = 1
	player.range = 1
	for enemy in enemies:
		enemy.hp = 3
		enemy.damage = 1
		enemy.board = board
	for i in range(board.size()):
		for j in range(board[i].size()):
			var current = board[j][i]
			var tile = tile_scene.instantiate()
			tile.position = Vector2(i * 16, j * 16)
			tile.board_position = Vector2(i, j)
			terrain_layer.add_child(tile)
			if current != null:
				current.position = Vector2(i * 16, j * 16)
				current.board_position = Vector2(i, j)
				navigation_layer.add_child(current)

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = int_position - (int_position % Vector2i(16,16))
	return snapped_position / 16
	
func is_in_range(position1, position2, range):
	if abs(position1[0] - position2[0]) + abs(position1[1] - position2[1]) <= range:
		return true
	else:
		return false 

func take_enemy_turns():
	for i in range(len(enemies)):
		if i >= len(enemies):
			break
		var enemy = enemies[i]
		active_entity = enemy
		var dest = enemy.plan_move(player.board_position)
		if dest != enemy.board_position:	
			board[enemy.board_position[0]][enemy.board_position[1]] = null 
			board[dest[0]][dest[1]] = enemy
			enemy.position = dest * 16
			enemy.board_position = dest
		var attack_target = enemy.find_targets(player)
		if attack_target != null:
			damage(attack_target, enemy.damage)
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
		target.free()
		clear_dead()
	else:
		var nodes = target.get_children()
		var health = nodes[1]
		health.text = str(target.hp)


func move(entity, target):
	var current_board_position = get_board_position(entity.position)
	if board[target[0]][target[1]] == null:
		entity.position = target * 16
		board[current_board_position[0]][current_board_position[1]] = null
		board[target[0]][target[1]] = entity
		entity.board_position = target
		entity.has_moved = true

func attack(entity, target):
	if !is_in_range(entity.board_position, target, entity.range):
		return
	var attacker_board_position = get_board_position(entity.position)
	if board[target[0]][target[1]] != null and board[target[0]][target[1]] != entity:
		damage(board[target[0]][target[1]], entity.damage)
	entity.has_moved = false
	take_enemy_turns()
	
func _input(event):
	if active_entity != player:
		return
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		var mouse_position = active_entity.get_global_mouse_position()
		var board_position = get_board_position(mouse_position)
		if !active_entity.has_moved:
			move(active_entity, board_position)
		else:
			attack(active_entity, board_position)
