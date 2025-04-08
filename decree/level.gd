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
var archer_count = 0
@onready
var bull_count = 0
@onready
var enemies = []
@onready
var enemy_idx = 0
@onready
var enemy_stack = []
@onready
var terrain = []
@onready
var rock_count = 0
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
@onready
var preview_board = Globals.PREVIEW_BOARD
@onready
var preview_entities = []
@onready
var is_previewing

func _ready():
	$EndScreen.connect("restart", _restart_game)
	player.connect("lose", _on_player_lose)
	board = Globals.BOARD
	var terrain_layer = $Terrain
	var navigation_layer = $Navigation
	for i in range(Globals.BOARD_SIZE[0]):
		var navi_row = []
		var preview_row = []
		var terrain_row = []
		for j in range(Globals.BOARD_SIZE[1]):
			navi_row.append(null)
			preview_row.append(null)
			terrain_row.append(null)
		board.append(navi_row)
		preview_board.append(preview_row)
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
	player.preview = player.duplicate()
	player.preview.preview = null
	navigation_layer.add_child(player.preview)
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
		bull.initialize(board_position, 5, 2, false, 100, 1, true, enemies, "bull")
		bulls.append(bull)
		bull.position = bull.board_position * 16
		board[bull.board_position[0]][bull.board_position[1]] = bull
		navigation_layer.add_child(bull)
	for i in range(warrior_count):
		var warrior = enemy_scene.instantiate()
		warrior.initialize(Vector2i(-1,-1), 3, 1, false, 1, 1, true, enemies, "warrior")
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
		archer.initialize(board_position, 3, 1, false, 1, 100, true, enemies, "archer")
		enemies.append(archer)
		archer.position = archer.board_position * 16
		board[archer.board_position[0]][archer.board_position[1]] = archer
		navigation_layer.add_child(archer)

func _process(_delta):
	var pos = get_viewport().get_mouse_position()
	var board_pos = get_board_position(pos)
	if !is_valid_position(board_pos) or !is_in_range(player.board_position, board_pos, player.speed): 
		clear_preview()
		hide_turn_order()
		hide_preview()
		is_previewing = false
		return
	if is_previewing:
		return
	is_previewing = true
	var target = board[board_pos[0]][board_pos[1]]
	if is_player_turn and is_valid_position(board_pos) and is_in_range(player.board_position, board_pos, player.speed + 1) and board_pos != player.board_position:
		if target == null and is_in_range(player.board_position, board_pos, player.speed):
			preview_board[player.preview.board_position[0]][player.preview.board_position[1]] = null
			player.preview.board_position = board_pos
			player.preview.position = board_pos * 16
			preview_board[board_pos[0]][board_pos[1]] = player.preview
			preview_enemy_turns(player.preview)
		elif target != null and target.is_enemy:
			var dests = []
			var offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
			for offset in offsets:
				var dest = board_pos + offset
				if is_valid_position(dest) and is_in_range(player.board_position, dest, player.speed) and board[dest[0]][dest[1]] == null:
					dests.append(dest)
			var closest_dest
			var distance = INF
			for dest in dests:
				if pos.distance_to(dest * 16) < distance:
					distance = pos.distance_to(dest * 16)
					closest_dest = dest
			if closest_dest != null:
				preview_board[player.preview.board_position[0]][player.preview.board_position[1]] = null
				player.preview.board_position = closest_dest
				player.preview.position = closest_dest * 16
				preview_board[closest_dest[0]][closest_dest[1]] = player.preview
				preview_enemy_turns(player.preview)
				show_turn_order()
				show_preview()
	else:
		clear_preview()
		hide_turn_order()
		hide_preview()
		is_previewing = false

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

func show_preview():
	for entity in preview_entities:
		if is_instance_valid(entity):
			entity.visible = true

func hide_preview():
	for entity in preview_entities:
		if is_instance_valid(entity):
			entity.visible = false

func take_turn(enemy, board, target_player):
	if !is_instance_valid(enemy) or enemy == null:
		return null
	var tween = create_tween()
	var dest
	match enemy.type:
		"warrior":
			dest = move_patterns.shift_chase(enemy, target_player.board_position)
		"archer":
			dest = move_patterns.shift_chase_axis(enemy, target_player.board_position)
		"bull":
			dest = move_patterns.charge(enemy, target_player.board_position)
	var target
	if dest != null and dest != enemy.board_position:
		if board[dest[0]][dest[1]] == null:
			await move(board, enemy, dest, tween)
		else:
			target = board[dest[0]][dest[1]]
	if target == null and is_instance_valid(enemy):
		target = enemy.find_targets(board, target_player)
	if target != null and is_instance_valid(enemy):
		await attack(enemy, target, tween, board)
			
func take_enemy_turns():
	for enemy in enemies:
		enemy_stack.insert(0, enemy)
	while len(enemy_stack) > 0:
		var enemy = enemy_stack.pop_back()
		if !is_instance_valid(enemy) or enemy == null:
			continue
		await take_turn(enemy, board, player)
		clear_dead(enemies)
		if len(enemies) == 0:
			_on_player_win()
	is_player_turn = true
	preview_enemy_turns(player.board_position)

func clear_preview():
	player.preview.visible = false
	for entity in preview_entities:
		if entity != player.preview and is_instance_valid(entity):
			entity.free()

func preview_enemy_turns(target):
	await clear_preview()
	player.preview.visible = true
	for i in range(Globals.BOARD_SIZE[0]):
		for j in range(Globals.BOARD_SIZE[1]):
			preview_board[i][j] = null
	preview_board[player.preview.board_position[0]][player.preview.board_position[1]] = player.preview
	preview_entities = [player.preview]
	for i in range(Globals.BOARD_SIZE[0]):
		for j in range(Globals.BOARD_SIZE[1]):
			var node
			if board[i][j] != null and board[i][j] != player:
				node = board[i][j].duplicate()
				$Navigation.add_child(node)
				preview_entities.append(node)
				node.modulate.a = .5
				preview_board[i][j] = node
	for entity in preview_entities:
		if is_instance_valid(entity) and entity != null and entity.is_enemy:
			enemy_stack.insert(0, entity)
	while len(enemy_stack) > 0:
		var enemy = enemy_stack.pop_back()
		await take_turn(enemy, preview_board, player.preview)
	is_previewing = false
		#clear_dead(preview_)
	
func dup_board(board):
	return board.duplicate()

func clear_dead(entity_list):
	var dead_idx = []
	for i in range(len(entity_list)):
		if entity_list[i] == null or entity_list[i].is_queued_for_deletion():
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		var dead_entity = entity_list.pop_at(dead_idx[-i-1])
		
	dead_idx = []
	for i in range(len(rocks)):
		if rocks[i] == null or rocks[i].is_queued_for_deletion():
			dead_idx.append(i)
	for i in range(len(dead_idx)):
		rocks.remove_at(dead_idx[-i-1])

func damage(target, amount, board):
	if !is_instance_valid(target) or target == null:
		return
	target.hp -= amount
	if target.hp > 0:
		var health = target.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").reduce_health(amount)
	elif target != player.preview:
		board[target.board_position[0]][target.board_position[1]] = null
		target.destroy()

func move(board, entity, target, tween):
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
			for enemy in enemy_stack:
				if enemy == bull:
					is_queued = true
					break
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
				enemy_stack.append(bull)
	if entity == player:
		player.prev_board_position = prev_position
	return did_move

func attack(entity, target, tween, board):
	var entity_pos = entity.board_position
	var target_pos = target.board_position
	if !is_instance_valid(entity) or !is_in_range(entity_pos, target_pos, entity.range):
		return
	player.has_moved = false
	if board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != entity:
		var anim_player = entity.get_node("AnimationPlayer")
		if anim_player != null:
			await animate_attack(entity.board_position, target.board_position, anim_player)
		damage(target, entity.damage, board)

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
				var did_move = await move(board, player, tile.board_position, tween)
				is_player_turn = false
				take_enemy_turns()
				
				#if did_move:
					#highlight_targets(player.board_position)
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
		take_enemy_turns()

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
	clear_dead(enemies)
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

func push(entity, offset, distance):
	for i in range(distance):
		var dest = entity.board_position + offset
		if is_valid_position(dest) and board[dest[0]][dest[1]] != null:
			break
		await move(board, entity, dest, create_tween())
