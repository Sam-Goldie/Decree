extends Node2D

var player_scene = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var archer_scene = preload("res://archer.tscn")
var bull_scene = preload("res://bull.tscn")
var rock_scene = preload("res://rock.tscn")
var tile_scene = preload("res://Tile.tscn")
var move_pattern_scene = preload("res://move_patterns.gd")

@onready
var rng = RandomNumberGenerator.new()
@onready
var player = player_scene.instantiate()
@onready
var player_start = Vector2i(2,2)
@onready
var is_player_turn = true
@onready
var warrior_count = 3
@onready
var archer_count = 2
@onready
var bull_count = 1
@onready
var enemies = []
@onready
var enemy_idx = 0
@onready
var terrain = []
@onready
var rock_count = 22
@onready
var rocks = []
@onready
var board = []
@onready
var move_patterns = move_pattern_scene.new()
@onready
var grid


func _ready():
	$EndScreen.connect("restart", _restart_game)
	player.connect("lose", _on_player_lose)
	grid = AStarGrid2D.new()
	grid.size = Vector2i(Globals.BOARD_SIZE[0], Globals.BOARD_SIZE[1])
	grid.cell_size = Vector2(16,16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	move_patterns.grid = grid
	move_patterns.board = board
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	for i in range(Globals.BOARD_SIZE[0]):
		var navi_row = []
		var terrain_row = []
		for j in range(Globals.BOARD_SIZE[1]):
			navi_row.append(null)
			terrain_row.append(null)
		board.append(navi_row)
		terrain.append(terrain_row)
	player.hp = 5
	player.damage = 1
	player.range = 1
	player.speed = 2
	player.board_position = player_start
	player.position = player_start * 16
	player.is_enemy = false
	navigation_layer.add_child(player)
	board[player_start[0]][player_start[1]] = player
	for i in range(rock_count):
		var x = rng.randi_range(0, Globals.BOARD_SIZE[0] - 1)
		var y = rng.randi_range(0, Globals.BOARD_SIZE[1] - 1)
		if board[x][y] != null:
			i -= 1
			continue
		var tile = tile_scene.instantiate()
		tile.position = Vector2i(x * 16, y * 16)
		tile.board_position = Vector2i(x, y)
		tile.get_node("TileSelector").self_modulate.a = 0
		tile.get_node("BlinkSquare").self_modulate.a = 0
		tile.connect("click", _on_tile_click.bind(tile))
		tile.get_node("Sprite2D").texture.region = Rect2(96, 32, 16, 16)
		terrain_layer.add_child(tile)
		terrain[x][y] = tile
		var rock = rock_scene.instantiate()
		rock.board_position = Vector2i(x,y)
		rock.position = Vector2i(x * 16, y * 16)
		rock.hp = 2
		rock.grid = grid
		rock.type = "rock"
		rock.connect("destroy_rock", destroy_rock.bind(x, y))
		rock.is_enemy = false
		board[x][y] = rock 
		navigation_layer.add_child(rock)
		rocks.append(rock)
	for i in range(Globals.BOARD_SIZE[0]):
		for j in range(Globals.BOARD_SIZE[1]):
			if board[i][j] != null and board[i][j] != player:
				continue
			var tile = tile_scene.instantiate()
			tile.position = Vector2i(i * 16, j * 16)
			tile.board_position = Vector2i(i, j)
			tile.get_child(1).self_modulate.a = 0
			tile.get_node("BlinkSquare").self_modulate.a = 0
			tile.connect("click", _on_tile_click.bind(tile))
			terrain[i][j] = tile
			terrain_layer.add_child(tile)
	for i in range(warrior_count):
		var warrior = enemy_scene.instantiate()
		warrior.type = "warrior"
		warrior.hp = 3
		warrior.damage = 1
		warrior.range = 1
		warrior.speed = 1
		warrior.board = board
		warrior.enemies = enemies
		warrior.player = player
		warrior.board_position = Vector2i(-1,-1)
		warrior.is_enemy = true
		enemies.append(warrior)
		while warrior.board_position == Vector2i(-1,-1) or board[warrior.board_position[0]][warrior.board_position[1]] != null:
			warrior.board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		warrior.position = warrior.board_position * 16
		board[warrior.board_position[0]][warrior.board_position[1]] = warrior
		navigation_layer.add_child(warrior)
	for i in range(archer_count):
		var archer = archer_scene.instantiate()
		archer.type = "archer"
		archer.hp = 3
		archer.damage = 1
		archer.range = 100
		archer.speed = 1
		archer.board = board
		archer.enemies = enemies
		archer.player = player
		archer.board_position = Vector2i(-1,-1)
		archer.is_enemy = true
		enemies.append(archer)
		while archer.board_position == Vector2i(-1,-1) or board[archer.board_position[0]][archer.board_position[1]] != null:
			archer.board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		archer.position = archer.board_position * 16
		board[archer.board_position[0]][archer.board_position[1]] = archer
		navigation_layer.add_child(archer)
	for i in range(bull_count):
		var bull = bull_scene.instantiate()
		bull.grid = grid
		bull.type = "bull"
		bull.hp = 5
		bull.damage = 2
		bull.range = 100
		bull.speed = 100
		bull.board = board
		bull.enemies = enemies
		bull.player = player
		bull.board_position = Vector2i(-1,-1)
		bull.is_enemy = true
		enemies.append(bull)
		while bull.board_position == Vector2i(-1,-1) or board[bull.board_position[0]][bull.board_position[1]] != null:
			bull.board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		bull.position = bull.board_position * 16
		board[bull.board_position[0]][bull.board_position[1]] = bull
		navigation_layer.add_child(bull)
	grid.update()

func _process(_delta):
	var pos = get_global_mouse_position()
	var board_pos = get_board_position(pos)
	if is_valid_position(board_pos) and board[board_pos[0]][board_pos[1]] != null and board[board_pos[0]][board_pos[1]].is_enemy:
		show_turn_order()
	else:
		hide_turn_order()

func is_valid_position(board_position):
	if board_position[0] < 0 or board_position[0] > Globals.BOARD_SIZE[0] - 1 or board_position[1] < 0 or board_position[1] > Globals.BOARD_SIZE[1] - 1:
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

func take_enemy_turn():
	for i in range(Globals.BOARD_SIZE[0]):
		for j in range(Globals.BOARD_SIZE[1]):
			if board[i][j] == null:
				grid.set_point_weight_scale(Vector2i(i, j), 1)
			else:
				grid.set_point_weight_scale(Vector2i(i, j), 1.5)
	if len(enemies) == 0:
		_on_player_win()
		return
	if enemy_idx > len(enemies) - 1:
		enemy_idx = 0
		clear_dead()
		is_player_turn = true
		return
	#for entity in enemies:
		#grid.set_point_solid(entity.board_position)
	#for rock in rocks:
		#grid.set_point_solid(rock.board_position)
	var tween = create_tween()
	remove_target_highlights(player.board_position)
	var enemy = enemies[enemy_idx]
	var anim_player = enemy.get_node("AnimationPlayer")
	enemy_idx += 1
	if enemy == null:
		take_enemy_turn()
	var dest
	match enemy.type:
		"warrior":
			dest = move_patterns.shift_chase(enemy, player.board_position)
		"archer":
			dest = move_patterns.shift_chase_axis(enemy, player.board_position)
		"bull":
			dest = move_patterns.charge(enemy, player.board_position)
	var next
	if len(dest) > 0:
		var target = dest[0]
		for j in range(1, enemy.speed + 1):
			if j > len(dest) - 1:
				break
			var current = dest[j]
			if board[current[0]][current[1]] == null:
				target = current
				if j < len(dest) - 1:
					next = dest[j + 1]
			else:
				if j < len(dest) - 1:
					next = current
				break
				
		var move_success = move(enemy, target, tween)
		if move_success:
			await tween.finished
	var attack_target
	match enemy.type:
		"warrior":
			attack_target = enemy.find_targets(next)
		"archer":
			attack_target = enemy.find_targets(player)
		"bull":
			attack_target = enemy.find_targets(player)
	var did_attack = false
	if attack_target != null:
		attack(enemy, attack_target, tween)
		await anim_player.animation_finished
		did_attack = true
	#for entity in enemies:
		#grid.set_point_solid(entity.board_position, false)
	#for rock in rocks:
		#grid.set_point_solid(rock.board_position, false)
	take_enemy_turn()
	
func clear_dead():
	var dead_idx = []
	for i in range(len(enemies)):
		if enemies[i] == null or enemies[i].is_queued_for_deletion():
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		enemies.remove_at(dead_idx[-i-1])
	dead_idx = []
	for i in range(len(rocks)):
		if rocks[i] == null or rocks[i].is_queued_for_deletion():
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		rocks.remove_at(dead_idx[-i-1])

func damage(target, amount):
	target.hp -= amount
	if target.hp > 0:
		var health = target.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").reduce_health(amount)
	else:
		board[target.board_position[0]][target.board_position[1]] = null
		target.destroy()
		clear_dead()
		if len(enemies) == 0:
			_on_player_win()

func move(entity, target, tween):
	var did_move = false
	var prev_position = entity.board_position
	if entity == player:
		remove_target_highlights(prev_position)
	if target[0] < 0 or target[0] > Globals.BOARD_SIZE[0] - 1 or target[1] < 0 or target[1] > Globals.BOARD_SIZE[1] - 1:
		return did_move
	if board[target[0]][target[1]] == null:
		tween.tween_property(entity, "position", Vector2(target * 16), 0.2)
		board[prev_position[0]][prev_position[1]] = null
		board[target[0]][target[1]] = entity
		entity.board_position = target
		entity.has_moved = true
		did_move = true
	if entity == player:
		player.prev_board_position = prev_position
	if did_move:
		grid.set_point_solid(prev_position, false)
	return did_move

func attack(entity, target, tween):
	var entity_pos = entity.board_position
	var target_pos = target.board_position
	if !is_in_range(entity_pos, target_pos, entity.range):
		return
	player.has_moved = false
	if board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != entity:
		#await get_tree().create_timer(1.5).timeout
		damage(board[target_pos[0]][target_pos[1]], entity.damage)
		var anim_player = entity.get_node("AnimationPlayer")
		if anim_player != null:
			var offset = entity_pos - target_pos
			if abs(offset[0]) > abs(offset[1]):
				if offset[0] < 0:
					anim_player.play("attack_right")
				else:
					anim_player.play("attack_left")
			else:
				if offset[1] < 0:
					anim_player.play("attack_down")
				else:
					anim_player.play("attack_up")

func _on_tile_click(tile):
	if !is_player_turn or player.board_position == tile.board_position:
		return
	var tween = create_tween()
	#for rock in rocks:
		#grid.set_point_solid(rock.board_position)
	#for entity in enemies:
		#grid.set_point_solid(entity.board_position)
	if !player.has_moved and board[tile.board_position[0]][tile.board_position[1]] == null and !grid.is_point_solid(tile.board_position):
		if is_in_range(player.board_position, tile.board_position, player.speed):
			var dest = move_patterns.shift_target(player, tile.board_position)
			if dest != null:
				var did_move = move(player, tile.board_position, tween)
				if did_move:
					highlight_targets(player.board_position)
					await tween.finished
		#for rock in rocks:
			#grid.set_point_solid(rock.board_position, false)
		#for entity in enemies:
			#grid.set_point_solid(entity.board_position)
	elif player.has_moved:
		attack(player, tile, tween)
		if player.has_moved:
			return
		var anim_player = player.get_node("AnimationPlayer")
		if anim_player.is_playing():
			await anim_player.animation_finished
		player.has_moved = false
		#for rock in rocks:
			#grid.set_point_solid(rock.board_position, false)
		#for entity in enemies:
			#grid.set_point_solid(entity.board_position)
		take_enemy_turn()

func _on_tile_right_click():
	if !is_player_turn:
		return
	var tween = create_tween()
	if player.has_moved:
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
	terrain[board_position[0]][board_position[1]].get_node("BlinkSquare").self_modulate.a = .6

func remove_highlight_tile(board_position):
	terrain[board_position[0]][board_position[1]].get_node("BlinkSquare").self_modulate.a = 0

func revert_move(tween):
	move(player, player.prev_board_position, tween)
	player.has_moved = false

func destroy_rock(x, y):
	terrain[x][y].get_node("Sprite2D").texture.region = Rect2(48, 0, 16, 16)

func _on_player_lose():
	$EndScreen/TextEdit.text = "YOU LOSE YOU LOSE YOU LOSE"
	$EndScreen.visible = true
	
func _on_player_win():
	$EndScreen/TextEdit.text = "YOU WIN YOU WIN YOU WIN"
	$EndScreen.visible = true
	
func _restart_game():
	get_tree().reload_current_scene()

func show_turn_order():
	if grid.is_dirty():
		grid.update()
	clear_dead()
	for i in range(len(enemies)):
		var enemy = enemies[i]
		var turn_display = enemy.get_node(Globals.TURN_ORDER_PATH)
		turn_display.text = str(i + 1)
		if turn_display.visible == true:
			return
		else:
			turn_display.visible = true
			
func hide_turn_order():
	for enemy in enemies:
		var turn_display = enemy.get_node(Globals.TURN_ORDER_PATH)
		if turn_display.visible == false:
			return
		else:
			turn_display.visible = false
