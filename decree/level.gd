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
var enemies = [enemy_scene.instantiate(), enemy_scene.instantiate(), enemy_scene.instantiate(), enemy_scene.instantiate()]
@onready
var board = [[null, null, null, enemies[0]], [enemies[1], player, null, null], [null, null, null, enemies[2]],[null, null, enemies[3], null]]
@onready
var grid = AStarGrid2D.new()

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
			tile.position = Vector2i(i * 16, j * 16)
			tile.board_position = Vector2i(i, j)
			tile.get_child(1).self_modulate.a = 0
			tile.connect("click", _on_tile_click.bind(tile.board_position))
			terrain_layer.add_child(tile)
			if current != null:
				current.position = Vector2i(i * 16, j * 16)
				current.board_position = Vector2i(i, j)
				navigation_layer.add_child(current)
	grid.size = Vector2i(4,4)
	grid.cell_size = Vector2(16,16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = (int_position - (int_position % Vector2i(16,16))) / 16
	return snapped_position
	
func is_in_range(position1, position2, range):
	if abs(position1[0] - position2[0]) + abs(position1[1] - position2[1]) <= range:
		return true
	else:
		return false 

func take_enemy_turns():
	clear_dead()
	for enemy in enemies:
		enemy.has_moved = false
	for i in range(len(enemies)):
		if i >= len(enemies):
			break
		active_entity = enemies[i]
		if active_entity == null:
			continue
		for enemy in enemies:
			if active_entity != enemy:
				grid.set_point_solid(enemy.board_position)
		var path = grid.get_id_path(active_entity.board_position, player.board_position, true)
		if len(path) > 2:
			var dest = path[1]
			move(active_entity, dest)
		var attack_target = active_entity.find_targets(player)
		if attack_target != null:
			damage(attack_target, active_entity.damage)
		clear_dead()
		for enemy in enemies:
			grid.set_point_solid(enemy.board_position, false)
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
	else:
		var nodes = target.get_children()
		var health = nodes[1]
		health.text = str(target.hp)


func move(entity, target):
	if grid.is_dirty():
		grid.update()
	var current_board_position = get_board_position(entity.position)
	if target[0] < 0 or target[0] > 3 or target[1] < 0 or target[1] > 3:
		return
	if board[target[1]][target[0]] == null:
		entity.position = target * 16
		board[current_board_position[1]][current_board_position[0]] = null
		board[target[1]][target[0]] = entity
		entity.board_position = target
		entity.has_moved = true

func attack(entity, target):
	if !is_in_range(entity.board_position, target, entity.range):
		return
	var attacker_board_position = get_board_position(entity.position)
	if board[target[1]][target[0]] != null and board[target[1]][target[0]] != entity:
		damage(board[target[1]][target[0]], entity.damage)
	entity.has_moved = false
	take_enemy_turns()

func _on_tile_click(board_position):
	if active_entity != player:
		return
	if !active_entity.has_moved:
		move(active_entity, board_position)
	else:
		attack(active_entity, board_position)
