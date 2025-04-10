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
var warrior_count = 2
@onready
var archer_count = 1
@onready
var bull_count = 1
@onready
var enemies = []
@onready
var enemy_idx = 0
@onready
var terrain = []
@onready
var rock_count = 9
@onready
var rocks = []
@onready
var bulls = []
@onready
var bull_queue = []
@onready
var board
@onready
var move_patterns = move_pattern_scene.new()

func _ready():
	$EndScreen.connect("restart", _restart_game)
	player.connect("lose", _on_player_lose)
	board = Globals.BOARD
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
	player.prev_board_position = Vector2i(-1,-1)
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
		terrain_layer.add_child(tile)
		terrain[x][y] = tile
		var rock = rock_scene.instantiate()
		rock.initialize(Vector2i(x, y), 2, false, "rock")
		rock.position = Vector2i(x * 16, y * 16)
		rock.connect("destroy_rock", destroy_rock.bind(x, y))
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
	for i in range(bull_count):
		var bull = bull_scene.instantiate()
		var board_position = Vector2i(-1,-1)
		while board_position == Vector2i(-1,-1) or board[board_position[0]][board_position[1]] != null:
			board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		bull.initialize(board_position, 5, 2, false, board, 100, 1, true, enemies, player, "bull")
		bulls.append(bull)
		bull.position = bull.board_position * 16
		board[bull.board_position[0]][bull.board_position[1]] = bull
		navigation_layer.add_child(bull)
	for i in range(warrior_count):
		var warrior = enemy_scene.instantiate()
		warrior.initialize(Vector2i(-1,-1), 3, 1, false, board, 1, 1, true, enemies, player, "warrior")
		enemies.append(warrior)
		while warrior.board_position == Vector2i(-1,-1) or board[warrior.board_position[0]][warrior.board_position[1]] != null:
			warrior.board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		warrior.position = warrior.board_position * 16
		board[warrior.board_position[0]][warrior.board_position[1]] = warrior
		navigation_layer.add_child(warrior)
	for i in range(archer_count):
		var archer = archer_scene.instantiate()
		var board_position = Vector2i(-1,-1)
		while board_position == Vector2i(-1,-1) or board[board_position[0]][board_position[1]] != null:
			board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		archer.initialize(board_position, 3, 1, false, board, 1, 100, true, enemies, player, "archer")
		enemies.append(archer)
		archer.position = archer.board_position * 16
		board[archer.board_position[0]][archer.board_position[1]] = archer
		navigation_layer.add_child(archer)

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

func action_delay(_duration):
	if _duration != null:
		$Timer.start(_duration)
	else:
		$Timer.start()
	await $Timer.timeout

func take_enemy_turn():
	await action_delay(null)
	if enemy_idx > len(enemies) - 1 and len(bull_queue) == 0:
		enemy_idx = 0
		clear_dead()
		if len(enemies) == 0:
			_on_player_win()
		is_player_turn = true
		return
	var tween = create_tween()
	var enemy
	if len(bull_queue) > 0:
		enemy = bull_queue.pop_at(len(bull_queue) - 1)
	else:
		enemy = enemies[enemy_idx]
		enemy_idx += 1
	if enemy == null:
		take_enemy_turn()
		return
	var dest
	match enemy.type:
		"warrior":
			dest = move_patterns.shift_chase(enemy, player.board_position)
		"archer":
			dest = move_patterns.shift_chase_axis(enemy, player.board_position)
		"bull":
			dest = move_patterns.charge(enemy)
	if dest != null and dest != enemy.board_position and board[dest[0]][dest[1]] != null:
		await attack(enemy, board[dest[0]][dest[1]], create_tween())
	elif dest == enemy.board_position:
		var target = enemy.find_targets()
		if target != null:
			await attack(enemy, target, create_tween())
	else:
		await move(enemy, dest, create_tween())
		var target = enemy.find_targets()
		if target != null:
			await action_delay(null)
			await attack(enemy, target, create_tween())
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
		if entity.is_enemy or entity == player:
			entity.has_moved = true
		did_move = true
		if tween.is_running:
			await tween.finished
			
		for i in range(len(bulls)):
			var bull = bulls[i]
			var is_queued = false
			for queued_bull in bull_queue:
				if queued_bull == bull:
					is_queued = true
					continue
			if is_queued:
				continue
			if bull == entity:
				continue
			if bull.board_position[0] == target[0] or bull.board_position[1] == target[1]:
				if bull.board_position[0] < target[0]:
					bull.direction = "right"
				elif bull.board_position[0] > target[0]:
					bull.direction = "left"
				elif bull.board_position[1] < target[1]:
					bull.direction = "down"
				elif bull.board_position[1] > target[1]:
					bull.direction = "up"
				bull_queue.append(bull)
	if entity == player:
		player.prev_board_position = prev_position
	return did_move

func attack(entity, target, tween):
	var entity_pos = entity.board_position
	var target_pos = target.board_position
	if !is_in_range(entity_pos, target_pos, entity.range):
		return
	player.has_moved = false
	if board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != entity:
		var anim_player = entity.get_node("AnimationPlayer")
		if anim_player != null:
			await animate_attack(entity.board_position, target.board_position, anim_player)
		damage(board[target_pos[0]][target_pos[1]], entity.damage)

func animate_attack(entity_pos, target_pos, anim_player):
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
	await anim_player.animation_finished

func _on_tile_click(tile):
	if !is_player_turn or player.board_position == tile.board_position:
		return
	var tween = create_tween()
	if !player.has_moved and board[tile.board_position[0]][tile.board_position[1]] == null:
		if is_in_range(player.board_position, tile.board_position, player.speed):
			var dest = move_patterns.shift_target(player, tile.board_position)
			if dest != null:
				var did_move = await move(player, tile.board_position, tween)
				if did_move:
					highlight_targets(player.board_position)
	elif player.has_moved:
		var offset
		if player.board_position[0] < tile.board_position[0]:
			offset = Vector2i(1,0)
		elif player.board_position[0] > tile.board_position[0]:
			offset = Vector2i(-1,0)
		elif player.board_position[1] < tile.board_position[1]:
			offset = Vector2i(0,1)
		else:
			offset = Vector2i(0,-1)
		var target_entity = board[tile.board_position[0]][tile.board_position[1]]
		if target_entity != null:
			await push(board[tile.board_position[0]][tile.board_position[1]], offset, 2)
		var anim_player = player.get_node("AnimationPlayer")
		player.has_moved = false
		is_player_turn = false
		remove_target_highlights(player.board_position)
		take_enemy_turn()

func _on_tile_right_click():
	if !is_player_turn:
		return
	if player.has_moved:
		await revert_move(create_tween())

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
	var did_move = false
	var player_pos = player.board_position
	var prev = player.prev_board_position
	remove_target_highlights(player_pos)
	if board[prev[0]][prev[1]] == null:
		tween.tween_property(player, "position", Vector2(prev * 16), 0.2)
		board[player_pos[0]][player_pos[1]] = null
		board[prev[0]][prev[1]] = player
		player.board_position = prev
		did_move = true
		if tween.is_running:
			await tween.finished
	player.prev_board_position = Vector2i(-1,-1)
	player.has_moved = false
	if did_move:
		#grid.set_point_solid(player_pos, false)
		while !bull_queue.is_empty():
			bull_queue.remove_at(len(bull_queue) - 1)
	return did_move

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
		if enemy == null:
			continue
		var turn_display = enemy.get_node(Globals.TURN_ORDER_PATH)
		if turn_display.visible == false:
			return
		else:
			turn_display.visible = false

#func solidify_grid():
	#for i in range(Globals.BOARD_SIZE[0]):
		#for j in range(Globals.BOARD_SIZE[1]):
			#if board[i][j] != null and board[i][j] != player:
				#grid.set_point_solid(Vector2i(i,j))
#
#func clear_grid():
	#for i in range(Globals.BOARD_SIZE[0]):
		#for j in range(Globals.BOARD_SIZE[1]):
			#grid.set_point_solid(Vector2i(i,j), false)

func push(entity, offset, distance):
	for i in range(distance):
		var dest = entity.board_position + offset
		if is_valid_position(dest) and board[dest[0]][dest[1]] != null:
			break
		await move(entity, dest, create_tween())
