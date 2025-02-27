extends Node2D

var player_scene = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var tile_scene = preload("res://Tile.tscn")
var move_pattern_scene = preload("res://move_patterns.gd")
signal confirm_move
signal confirm_attack

@onready
var rng = RandomNumberGenerator.new()
@onready
var player = player_scene.instantiate()
@onready
var player_start = Vector2i(2,2)
@onready
var active_entity = player
@onready
var enemy_count = 5
@onready
var enemies = []
@onready
var BOARD_SIZE = Vector2i(5,5)
@onready
var terrain = []
@onready
var rock_count = 3
@onready
var board = []
@onready
var move_patterns = move_pattern_scene.new()
@onready
var grid

func _ready():
	grid = AStarGrid2D.new()
	move_patterns.grid = grid
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	for i in range(BOARD_SIZE[1]):
		var row = []
		var navi_row = []
		for j in range(BOARD_SIZE[0]):
			var tile = tile_scene.instantiate()
			tile.position = Vector2i(j * 16, i * 16)
			tile.board_position = Vector2i(j, i)
			tile.get_child(1).self_modulate.a = 0
			tile.get_node("BlinkSquare").self_modulate.a = 0
			tile.connect("click", _on_tile_click.bind(tile))
			terrain_layer.add_child(tile)
			row.append(tile)
			navi_row.append(null)
		terrain.append(row)
		board.append(navi_row)
	for i in range(rock_count):
		terrain[rng.randi_range(0, BOARD_SIZE[1] - 1)][rng.randi_range(0, BOARD_SIZE[0] - 1)].get_node("Sprite2D").texture.region = Rect2(96, 32, 16, 16)
	player.hp = 3
	player.damage = 1
	player.range = 1
	player.board_position = player_start
	player.position = player_start * 16
	navigation_layer.add_child(player)
	board[player_start[0]][player_start[1]] = player
	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		enemy.hp = 3
		enemy.damage = 1
		enemy.board = board
		enemy.board_position = Vector2i(-1,-1)
		enemies.append(enemy)
		while enemy.board_position == Vector2i(-1,-1) or board[enemy.board_position[0]][enemy.board_position[1]] != null:
			enemy.board_position = Vector2i(rng.randi_range(0, BOARD_SIZE[1] - 1), rng.randi_range(0, BOARD_SIZE[0] - 1))
		enemy.position = enemy.board_position * 16
		board[enemy.board_position[0]][enemy.board_position[1]] = enemy
		navigation_layer.add_child(enemy)
	grid.size = Vector2i(BOARD_SIZE[0], BOARD_SIZE[1])
	grid.cell_size = Vector2(16,16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	
func is_valid_position(board_position):
	if board_position[0] < 0 or board_position[0] > len(board) - 1 or board_position[1] < 0 or board_position[1] > len(board) - 1:
		return false
	else:
		return true

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
	var tween = create_tween()
	tween.set_parallel(false)
	clear_dead()
	remove_target_highlights(player.board_position)
	for enemy in enemies:
		enemy.has_moved = false
	for i in range(len(enemies)):
		if i >= len(enemies):
			break
		var enemy = enemies[i]
		if enemy == null:
			continue
		var dest = move_patterns.shift_one_targeted(enemy, player.board_position)
		if dest != null:
			move(enemy, dest, tween)
		var attack_target = enemy.find_targets(player)
		if attack_target != null:
			damage(attack_target, enemy.damage)
		clear_dead()

func clear_dead():
	var dead_idx = []
	for i in range(len(enemies)):
		if enemies[i] == null:
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		enemies.remove_at(dead_idx[-i-1])

func damage(target, amount):
	target.hp -= amount
	if target.hp > 0:
		var health = get_node("Navigation/%s/Path2D/PathFollow2D/Label" % target.name)
		health.text = str(target.hp)
	else:
		target.free()

func move(entity, target, tween):
	var prev_position = entity.board_position
	var current_board_position = get_board_position(entity.position)
	if entity == player:
		remove_target_highlights(current_board_position)
	if target[0] < 0 or target[0] > BOARD_SIZE[1] - 1 or target[1] < 0 or target[1] > BOARD_SIZE[0] - 1:
		return
	if board[target[0]][target[1]] == null:
		tween.tween_property(entity, "position", Vector2(target * 16), 0.2)
		board[current_board_position[0]][current_board_position[1]] = null
		board[target[0]][target[1]] = entity
		entity.board_position = target
		entity.has_moved = true
	if entity == player:
		player.prev_board_position = prev_position

func attack(entity, target):
	if !is_in_range(entity.board_position, target, entity.range):
		return
	var attacker_board_position = get_board_position(entity.position)
	if board[target[0]][target[1]] != null and board[target[0]][target[1]] != entity:
		damage(board[target[0]][target[1]], entity.damage)
	entity.has_moved = false
	take_enemy_turns()

func _on_tile_click(tile):
	if active_entity != player or player.board_position == tile.board_position:
		return
	var tween = create_tween()
	if !active_entity.has_moved and board[tile.board_position[0]][tile.board_position[1]] == null:
		move(active_entity, tile.board_position, tween)
		highlight_targets(active_entity.board_position)
	else:
		attack(active_entity, tile.board_position)

func _on_tile_right_click():
	if active_entity != player:
		return
	var tween = create_tween()
	if active_entity.has_moved:
		revert_move(tween)

func highlight_targets(board_position):
	var offsets = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]
	for offset in offsets:
		var target = board_position - offset
		if is_valid_position(target):
			highlight_tile(target)
			
func remove_target_highlights(board_position):
	var offsets = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]
	for offset in offsets:
		var target = board_position - offset
		if is_valid_position(target):
			remove_highlight_tile(target)

func highlight_tile(board_position):
	terrain[board_position[1]][board_position[0]].get_node("BlinkSquare").self_modulate.a = .6

func remove_highlight_tile(board_position):
	terrain[board_position[1]][board_position[0]].get_node("BlinkSquare").self_modulate.a = 0

func revert_move(tween):
	move(player, player.prev_board_position, tween)
	player.has_moved = false
