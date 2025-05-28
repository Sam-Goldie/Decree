extends Node2D

var player_scene = preload("res://Player.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var archer_scene = preload("res://archer2.tscn")
var bull_scene = preload("res://bull_2.tscn")
var rock_scene = preload("res://rock.tscn")
var tile_scene = preload("res://Tile.tscn")
var move_pattern_scene = preload("res://move_patterns.gd")
var entity_actions_scene = preload("res://entity_actions.gd")

@onready
var rng = RandomNumberGenerator.new()
@onready
var player = Globals.PLAYER
@onready
var player_start = Vector2i(2,2)
@onready
var warrior_count = 2
@onready
var archer_count = 3
@onready
var bull_count = 1
@onready
var enemies = Globals.ENEMIES
@onready
var enemy_stack = []
@onready
var preview_stack = []
@onready
var terrain = []
@onready
var rock_count = 7
@onready
var rocks = Globals.ROCKS
@onready
var bulls = Globals.BULLS
@onready
var bull_queue = []
@onready
var board = Globals.BOARD
@onready
var move_patterns = move_pattern_scene.new()
@onready
var entity_actions = entity_actions_scene.new()
@onready
var preview_board = Globals.PREVIEW_BOARD
@onready
var preview_entities = []
@onready
var current_tile = Vector2i(-1,-1)
@onready
var running_tweens = Globals.RUNNING_TWEENS
@onready
var active_turns = Globals.ACTIVE_TURNS


#current problem: some tiles aren't firing off mouse entered signals (they appear to exist though)

func _ready():
	#entity_actions.connect("show_preview", show_preview)
	entity_actions.connect("did_move", _on_entity_move)
	#entity_actions.connect("turn_finished", _on_turn_finished)
	$EndScreen.connect("restart", _restart_game)
	if !is_instance_valid(player):
		Globals.PLAYER = player_scene.instantiate()
		player = Globals.PLAYER
	player.connect("lose", _on_player_lose)
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
	player.initialize(player_start, 5, false, 2, 1, false, player_scene.instantiate())
	player.preview.initialize(player_start, 5, false, 2, 1, false, null)
	player.position = player.board_position * 16
	player.preview.position = player.preview.board_position * 16
	navigation_layer.add_child(player)
	navigation_layer.add_child(player.preview)
	board[player_start[0]][player_start[1]] = player
	preview_board[player_start[0]][player_start[1]] = player.preview
	player.preview.modulate.a = 0.3
	for i in range(rock_count):
		var x = rng.randi_range(0, Globals.BOARD_SIZE[0] - 1)
		var y = rng.randi_range(0, Globals.BOARD_SIZE[1] - 1)
		if board[x][y] != null:
			i -= 1
			continue
		var rock = rock_scene.instantiate()
		rock.initialize(Vector2i(x, y), 2, false, "rock", rock_scene.instantiate())
		rock.preview.initialize(Vector2i(x, y), 2, false, "rock", null)
		rock.position = Vector2i(x * 16, y * 16)
		rock.preview.position = rock.position
		rock.connect("destroy_rock", destroy_rock.bind(x, y))
		rock.preview.modulate.a = 0.3
		#rock.connect("mouse_entered", _on_tile_mouse_entered)
		board[x][y] = rock
		preview_board[x][y] = rock.preview
		navigation_layer.add_child(rock)
		navigation_layer.add_child(rock.preview)
		rocks.append(rock)
	for i in range(Globals.BOARD_SIZE[0]):
		var active_row = []
		for j in range(Globals.BOARD_SIZE[1]):
			#if board[i][j] != null and board[i][j] != player:
				#continue
			var tile = tile_scene.instantiate()
			tile.position = Vector2i(i * 16, j * 16)
			tile.board_position = Vector2i(i, j)
			tile.get_child(1).self_modulate.a = 0
			active_row.append(null)
			tile.get_node("BlinkSquare").self_modulate.a = 0
			tile.connect("is_hovering", _on_tile_mouse_entered.bind(tile.board_position))
			#tile.pressed.connect(_on_tile_pressed.bind(tile.board_position))
			#tile.connect("is_hovering", _on_tile_hover.bind(tile))
			#tile.connect("mouse_exited", _on_tile_mouse_exited.bind(tile.board_position))
			tile.connect("click", _on_tile_pressed.bind(tile.board_position))
			terrain[i][j] = tile
			terrain_layer.add_child(tile)
		active_turns.append(active_row)
	for i in range(bull_count):
		var bull = bull_scene.instantiate()
		var board_position = Vector2i(-1,-1)
		while board_position == Vector2i(-1,-1) or board[board_position[0]][board_position[1]] != null:
			board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		bull.initialize(board_position, 5, 2, false, 100, 1, true, enemies, "bull", bull_scene.instantiate())
		bull.preview.initialize(board_position, 5, 2, false, 100, 1, true, enemies, "bull", null)
		bulls.append(bull)
		bull.position = bull.board_position * 16
		bull.preview.position = bull.position
		bull.connect("turn_finished", take_next_turn.bind(board, player, enemy_stack, bull.board_position))
		bull.preview.connect("turn_finished", take_next_turn.bind(preview_board, player.preview, preview_stack, bull.board_position))
		bull.preview.modulate.a = 0.3
		board[bull.board_position[0]][bull.board_position[1]] = bull
		preview_board[bull.board_position[0]][bull.board_position[1]] = bull.preview
		navigation_layer.add_child(bull)
		navigation_layer.add_child(bull.preview)
	for i in range(warrior_count):
		var warrior = enemy_scene.instantiate()
		warrior.initialize(Vector2i(-1,-1), 3, 1, false, 1, 1, true, enemies, "warrior", warrior.duplicate())
		warrior.preview.initialize(Vector2i(-1,-1), 3, 1, false, 1, 1, true, enemies, "warrior", null)
		warrior.preview.visible = false
		warrior.preview.modulate.a = 0.3
		enemies.append(warrior)
		preview_entities.append(warrior.preview)
		while warrior.board_position == Vector2i(-1,-1) or board[warrior.board_position[0]][warrior.board_position[1]] != null:
			warrior.board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
			warrior.preview.board_position = warrior.board_position
		warrior.position = warrior.board_position * 16
		warrior.preview.position = warrior.position
		warrior.connect("turn_finished", take_next_turn.bind(board, player, enemy_stack, warrior.board_position))
		warrior.preview.connect("turn_finished", take_next_turn.bind(preview_board, player.preview, preview_stack, warrior.board_position))
		board[warrior.board_position[0]][warrior.board_position[1]] = warrior
		preview_board[warrior.board_position[0]][warrior.board_position[1]] = warrior.preview
		navigation_layer.add_child(warrior)
		navigation_layer.add_child(warrior.preview)
	for i in range(archer_count):
		var archer = archer_scene.instantiate()
		var board_position = Vector2i(-1,-1)
		while board_position == Vector2i(-1,-1) or board[board_position[0]][board_position[1]] != null:
			board_position = Vector2i(rng.randi_range(0, Globals.BOARD_SIZE[0] - 1), rng.randi_range(0, Globals.BOARD_SIZE[1] - 1))
		archer.initialize(board_position, 3, 1, false, 1, 100, true, enemies, "archer", archer_scene.instantiate())
		archer.preview.initialize(board_position, 3, 1, false, 1, 100, true, enemies, "archer", null)
		preview_entities.append(archer.preview)
		enemies.append(archer)
		archer.connect("turn_finished", take_next_turn.bind(board, player, enemy_stack, board_position))
		archer.preview.connect("turn_finished", take_next_turn.bind(preview_board, player.preview, preview_stack, board_position))
		archer.preview.visible = false
		archer.preview.modulate.a = 0.3
		archer.position = archer.board_position * 16
		archer.preview.position = archer.position
		board[archer.board_position[0]][archer.board_position[1]] = archer
		preview_board[archer.preview.board_position[0]][archer.preview.board_position[1]] = archer.preview
		navigation_layer.add_child(archer)
		navigation_layer.add_child(archer.preview)

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
	player.preview.visible = true
	for enemy in enemies:
		if is_instance_valid(enemy) and is_instance_valid(enemy.preview):
			enemy.preview.visible = true
	for bull in bulls:
		if is_instance_valid(bull) and is_instance_valid(bull.preview):
			bull.preview.visible = true
	for rock in rocks:
		if is_instance_valid(rock) and is_instance_valid(rock.preview):
			rock.preview.visible = true

func hide_preview():
	player.preview.visible = false
	for enemy in enemies:
		if is_instance_valid(enemy) and is_instance_valid(enemy.preview):
			enemy.preview.visible = false
	for bull in bulls:
		if is_instance_valid(bull) and is_instance_valid(bull.preview):
			bull.preview.visible = false
	for rock in rocks:
		if is_instance_valid(rock) and is_instance_valid(rock.preview):
			rock.preview.visible = false

#sometimes this fires, sometimes not. What da heck?
#why is there a double turn by the enemy if I move just wrong
func take_next_turn(board, target_player, stack, board_pos):
	#await clear_dead([preview_entities, running_tweens, preview_stack, enemies, running_tweens, bulls])
	if len(stack) == 0:
		#for tween in running_tweens:
			#if tween.is_running():
				#await tween.finished
		Globals.IS_PLAYER_TURN = true
		return
	var enemy = stack.pop_back()
	if !is_instance_valid(enemy):
		take_next_turn(board, target_player, stack, board_pos)
		return
	enemy.take_turn(board, target_player, stack, board_pos)
	#var dest = enemy.plan_move(board, target_player)
	#var target
	#if dest != null and dest != enemy.board_position:
		#enemy.has_moved = true
		#if board[dest[0]][dest[1]] == null:
			#await enemy.move(board, enemy, dest, stack)
		#else:
			#target = board[dest[0]][dest[1]]
	#if enemy.type == "archer":
		#print("hello")
	#if target == null and is_instance_valid(enemy):
		#target = enemy.find_targets(board, target_player)
	#if target != null and is_instance_valid(enemy):
		#enemy.has_moved = true
		#await attack(enemy, target, board, board_pos)
	#take_next_turn(board, target_player, stack, board_pos)
			
func queue_enemy_turns(stack, enemies):
	for enemy in enemies:
		enemy.has_moved = false
		stack.insert(0, enemy)
	return stack	
	
func reset_health(entity, new_hp):
	entity.hp = new_hp
	entity.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").pips = []
	entity.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").initiate(new_hp)

func clear_preview():
	for active_tween in running_tweens:
		#if active_tween.is_running():
			#await active_tween.finished
		active_tween.kill()
	await clear_dead([preview_entities, preview_stack, enemies, running_tweens, rocks, bulls, active_turns, preview_board])
	#for i in range(Globals.BOARD_SIZE[0]):
		#for j in range(Globals.BOARD_SIZE[1]):
			#preview_board[i][j] = null
	for enemy in enemies:
		var preview = enemy.preview
		if is_instance_valid(preview):
			reset_health(preview, enemy.hp)
			preview.visible = false
			preview.position = enemy.position
			preview.board_position = enemy.board_position
			preview_board[preview.board_position[0]][preview.board_position[1]] = preview
	for rock in rocks:
		var preview = rock.preview
		if is_instance_valid(preview):
			reset_health(preview, rock.hp)
			preview.visible = false
			preview.position = rock.position
			preview.board_position = rock.board_position
			preview_board[preview.board_position[0]][preview.board_position[1]] = preview
	for bull in bulls:
		var preview = bull.preview
		if is_instance_valid(preview):
			reset_health(preview, bull.hp)
			preview.visible = false
			preview.position = bull.position
			preview.board_position = bull.board_position
			preview_board[preview.board_position[0]][preview.board_position[1]] = preview
	var state = [preview_stack, running_tweens]
	for element in state:
		element.clear()
#func preview_enemy_turns(target, tween):
	#for enemy in enemies:
		#if is_instance_valid(enemy) and enemy != null and is_instance_valid(enemy.preview):
			#enemy.preview.has_moved = false
			#preview_stack.insert(0, enemy.preview)
	#show_preview()
	#await take_turn(preview_board, player.preview, preview_stack)

func clear_dead(entity_lists):
	for list in entity_lists:
		if len(list) > 0 and typeof(list[0]) == TYPE_ARRAY:
			for sublist in list:
				for i in range(len(sublist)):
					if sublist[i] != null:
						if sublist[i].has_method("kill"):
							sublist[i].kill()
						sublist[i] = null
		else:
			var dead_idx = []
			for i in range(len(list)):
				if list[i] == null or list[i].is_queued_for_deletion() or !is_instance_valid(list[i]):
					dead_idx.append(i)
			for i in range(len(dead_idx)):
				list.remove_at(dead_idx[-i-1])

func damage(target, amount, board):
	if !is_instance_valid(target) or target == null:
		return
	target.hp -= amount
	if target.hp > 0:
		var health = target.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").reduce_health(amount)
	elif target != player.preview:
		board[target.board_position[0]][target.board_position[1]] = null
		target.destroy()

#read the damn debugger
func move(board, entity, target, stack, board_pos):
	var tween = create_tween()
	active_turns[board_pos[0]][board_pos[1]] = tween
	var prev_position = entity.board_position
	if entity == player:
		remove_target_highlights(prev_position)
	if !is_valid_position(target):
		return
	if board[target[0]][target[1]] == null:
		var new_pos = Vector2(target * 16)
		if !entity.preview:
			show_preview()
		else:
			hide_preview()
		running_tweens.append(tween)
		tween.tween_property(entity, "position", new_pos, 0.2)
		await tween.finished
		tween.stop()
		#how could target have changed from the tweening?
		board[prev_position[0]][prev_position[1]] = null
		board[target[0]][target[1]] = entity
		if !is_instance_valid(entity):
			return
		entity.board_position = target
		if entity.preview:
			entity.preview.position = entity.position
			entity.preview.board_position = entity.board_position
			preview_board[target[0]][target[1]] = entity.preview
		if entity.is_enemy or entity == player or entity == player.preview:
			entity.has_moved = true
		for i in range(len(bulls)):
			var bull = bulls[i] if entity.preview else bulls[i].preview
			var is_queued = false
			for enemy in stack:
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
				stack.append(bull)
	return
	
#why double moveeeee
func attack(entity, target, board, board_pos, tween):
	var entity_pos = entity.board_position
	var target_pos = target.board_position
	if !is_instance_valid(entity) or !is_in_range(entity_pos, target_pos, entity.range):
		take_next_turn(board, target, enemy_stack if entity.preview else preview_stack, board_pos)
		return
	#player.has_moved = false
	if board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != entity:
		var anim_player = entity.get_node("AnimationPlayer")
		if anim_player != null:
			await animate_attack(entity.board_position, target.board_position, anim_player, board_pos)
			#target = player if entity.preview else player.preview
		if target != player.preview:
			damage(target, entity.damage, board)
	#take_turn(board, player if entity.preview else player.preview, enemy_stack if entity.preview else preview_stack, board_pos)

func animate_attack(entity_pos, target_pos, anim_player, board_pos):
	var offset = entity_pos - target_pos
	if anim_player.is_playing():
		anim_player.stop()
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
	
func get_push_offset(player, board, tile):
	var offset
	if player.board_position[0] < tile.board_position[0]:
		offset = Vector2i(1,0)
	elif player.board_position[0] > tile.board_position[0]:
		offset = Vector2i(-1,0)
	elif player.board_position[1] < tile.board_position[1]:
		offset = Vector2i(0,1)
	else:
		offset = Vector2i(0,-1)
	return offset

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
	terrain[board_position[0]][board_position[1]].get_node("BlinkSquare").self_modulate.a = 0.6

func remove_highlight_tile(board_position):
	terrain[board_position[0]][board_position[1]].get_node("BlinkSquare").self_modulate.a = 0

func destroy_rock(x, y):
	terrain[x][y].get_node("Sprite2D").texture.region = Rect2(48, 0, 16, 16)

func _on_player_lose():
	$EndScreen/TextEdit.text = "YOU LOSE YOU LOSE YOU LOSE"
	$EndScreen.visible = true
	
func _on_player_win():
	$EndScreen/TextEdit.text = "YOU WIN YOU WIN YOU WIN"
	$EndScreen.visible = true

func _on_entity_move():
	return
	
#func _on_turn_finished(board, target_player, tween, stack):
	#take_turn(board, target_player, stack, board_pos)
	
func _restart_game():
	get_tree().reload_current_scene()

func show_turn_order():
	clear_dead([enemies, rocks])
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

func push(entity, offset, distance, board, stack, board_pos):
	for i in range(distance):
		if !is_instance_valid(entity):
			return
		var dest = entity.board_position + offset
		if is_valid_position(dest) and board[dest[0]][dest[1]] != null:
			break
		await move(board, entity, dest, stack, board_pos)

#why are some tiles randomly not firing mouse entered?
#some sort of disagreement about state between actual tiles and the state variables
func _on_tile_mouse_entered(board_pos):
	if board_pos == Vector2i(1,3):
		print("hello")
	var pos = get_viewport().get_mouse_position()
	if !Globals.IS_PLAYER_TURN or board_pos == current_tile:
		return
	player.preview.visible = false
	player.preview.position = player.position
	player.preview.board_position = player.board_position
	await clear_preview()
	preview_board[player.preview.board_position[0]][player.preview.board_position[1]] = player.preview
	if active_turns[board_pos[0]][board_pos[1]]:
		return
	#active_turns[str(board_pos)] = true
	if !is_valid_position(board_pos):
		current_tile = Vector2i(-1,-1)
		return
	var target = preview_board[board_pos[0]][board_pos[1]]
	if (!is_in_range(player.board_position, board_pos, player.speed) and target == null) or (!is_in_range(player.board_position, board_pos, player.speed + 1) and target != null): 
		current_tile = Vector2i(-1,-1)
		hide_turn_order()
		hide_preview()
		return
	current_tile = board_pos
	show_preview()
	if is_in_range(player.board_position, board_pos, player.speed) and target == null:
		await move(preview_board, player.preview, board_pos, preview_stack, board_pos)
		var input_stack = await queue_enemy_turns(preview_stack, preview_entities)
		take_next_turn(preview_board, player.preview, input_stack, board_pos)
	elif is_in_range(player.board_position, board_pos, player.speed + 1) and target != null and target != player.preview:
		var dests = []
		var offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		for offset in offsets:
			var dest = board_pos + offset
			if is_valid_position(dest) and is_in_range(player.board_position, dest, player.speed) and (board[dest[0]][dest[1]] == null):
				dests.append(dest)
		var closest_dest
		var distance = -1
		for dest in dests:
			var dest_distance
			var horizonality = abs(int(pos[0]) % 16)
			var verticality = abs(int(pos[1]) % 16)
			if dest[0] < board_pos[0]:
				dest_distance = horizonality
			elif dest[0] > board_pos[0]:
				dest_distance = 16 - horizonality
			elif dest[1] < board_pos[1]:
				dest_distance = verticality
			else:
				dest_distance = 16 - verticality
			if dest_distance < distance or distance == -1:
				closest_dest = dest
				distance = dest_distance
		if closest_dest != null:
			await move(preview_board, player.preview, closest_dest, preview_stack, board_pos)
			var offset = get_push_offset(player.preview, preview_board, target)
			await push(target, offset, 2, preview_board, preview_stack, board_pos)
			var input_stack = await queue_enemy_turns(preview_stack, preview_entities)
			take_next_turn(preview_board, player.preview, input_stack, board_pos)
	else:
		hide_turn_order()
		hide_preview()
		clear_preview()
	active_turns[board_pos[0]][board_pos[1]] = null


func _on_tile_pressed(board_pos):
	hide_preview()
	if !Globals.IS_PLAYER_TURN or player.board_position == board_pos:
		return
	clear_preview()
	var target_content = board[board_pos[0]][board_pos[1]]
	var in_short_range = is_in_range(player.board_position, board_pos, player.speed)
	var in_long_range = is_in_range(player.board_position, board_pos, player.speed + 1)
	if board[board_pos[0]][board_pos[1]] == null and is_in_range(player.board_position, board_pos, player.speed):
		var dest = move_patterns.shift_target(player, board_pos)
		if dest != null:
			Globals.IS_PLAYER_TURN = false
			await move(board, player, board_pos, enemy_stack, board_pos)
			var input_stack = await queue_enemy_turns(enemy_stack, enemies)
			take_next_turn(board, player, input_stack, board_pos)
	elif board[board_pos[0]][board_pos[1]] != null and is_in_range(player.board_position, board_pos, player.speed + 1):
		var pos = get_viewport().get_mouse_position()
		var dests = []
		var offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		for offset in offsets:
			var dest = board_pos + offset
			if is_valid_position(dest) and is_in_range(player.board_position, dest, player.speed) and board[dest[0]][dest[1]] == null:
				dests.append(dest)
		var closest_dest
		var distance = -1
		for dest in dests:
			var dest_distance
			var horizonality = abs(int(pos[0]) % 16)
			var verticality = abs(int(pos[1]) % 16)
			if dest[0] < board_pos[0]:
				dest_distance = horizonality
			elif dest[0] > board_pos[0]:
				dest_distance = 16 - horizonality
			elif dest[1] < board_pos[1]:
				dest_distance = verticality
			else:
				dest_distance = 16 - verticality
			if dest_distance < distance or distance == -1:
				closest_dest = dest
				distance = dest_distance
		if closest_dest != null:
			Globals.IS_PLAYER_TURN = false
			hide_turn_order()
			await move(board, player, closest_dest, enemy_stack, board_pos)
			var push_offset = get_push_offset(player, board, board[board_pos[0]][board_pos[1]])
			await push(board[board_pos[0]][board_pos[1]], push_offset, 2, board, enemy_stack, board_pos)
			var input_stack = await queue_enemy_turns(enemy_stack, enemies)
			take_next_turn(board, player, input_stack, board_pos)
	else:
		print("hello world")
		
func _on_tile_mouse_exited(board_pos):
	if active_turns[board_pos[0]][board_pos[1]] and active_turns[board_pos[0]][board_pos[1]]:
		active_turns[board_pos[0]][board_pos[1]].kill()
