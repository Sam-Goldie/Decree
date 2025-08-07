extends Node2D

var board_position : Vector2i
var hp : int = 5
var damage : int
var has_moved : bool
var range : int
var speed : int
var is_enemy : bool
var preview : Node2D
#var tween : Tween
var prev_pos : Vector2
var entity_actions
var running_tweens : Dictionary
var preview_board
var bulls
var enemies
var preview_enemies

signal turn_finished
signal attack(entity, target)
signal end_turn
signal lose

func initialize(board_position, hp, has_moved, speed, range, is_enemy, preview):
	self.board_position = board_position
	self.hp = hp
	self.has_moved = has_moved
	self.speed = speed
	self.range = range
	self.is_enemy = is_enemy
	self.preview = preview
	self.enemies = Globals.ENEMIES
	self.preview_enemies = Globals.PREVIEW_ENEMIES

func _ready():
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)
	entity_actions = load("res://entity_actions.tscn").instantiate()
	running_tweens = Globals.RUNNING_TWEENS
	preview_board = Globals.PREVIEW_BOARD
	bulls = Globals.BULLS

func take_turn(board, target_player, stack, target_pos):
	var pos = get_viewport().get_mouse_position()
	var target_content = board[target_pos[0]][target_pos[1]]
	var in_short_range = is_in_range(board_position, target_pos, speed)
	var in_long_range = is_in_range(board_position, target_pos, speed + 1)
	var target
	if target_pos != null and board[target_pos[0]][target_pos[1]] == null and in_short_range:
		await move(board, self, target_pos, stack)
	elif target_pos != null and board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != self and in_long_range:
		var dests = []
		var offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		for offset in offsets:
			var dest = target_pos + offset
			if is_valid_position(dest) and is_in_range(board_position, dest, speed) and board[dest[0]][dest[1]] == null:
				dests.append(dest)
		var closest_dest
		var distance = -1
		for dest in dests:
			var dest_distance
			var horizonality = abs(int(pos[0]) % 16)
			var verticality = abs(int(pos[1]) % 16)
			if dest[0] < target_pos[0]:
				dest_distance = horizonality
			elif dest[0] > target_pos[0]:
				dest_distance = 16 - horizonality
			elif dest[1] < target_pos[1]:
				dest_distance = verticality
			else:
				dest_distance = 16 - verticality
			if dest_distance < distance or distance == -1:
				closest_dest = dest
				distance = dest_distance
		if closest_dest != null and is_in_range(closest_dest, target_player.board_position, target_player.speed):
			await move(board, self, closest_dest, stack)
			var push_offset = get_push_offset(self, board, target_pos)
			await push(board[target_pos[0]][target_pos[1]], push_offset, 2, board, stack, target_pos)
	queue_enemy_turns(stack, enemies if target_player.preview else preview_enemies)
	if preview == null:
		Globals.IS_PLAYER_TURN = true
	turn_finished.emit()

func queue_enemy_turns(stack, enemies):
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.has_moved = false
			stack.insert(0, enemy)
	return stack

func move(board, entity, target, stack):
	#active_turns[target[0]][target[1]] = tween
	prev_pos = entity.board_position
	if !is_valid_position(target):
		return
	if board[target[0]][target[1]] == null:
		var tween = create_tween()
		var new_pos = Vector2(target * 16)
		if !entity.preview:
			entity_actions.show_preview()
		else:
			entity_actions.hide_preview()
		running_tweens[tween] = entity
		tween.tween_property(entity, "position", new_pos, 0.2)
		if tween.is_running():
			await tween.finished
		running_tweens.erase(tween)
		print(tween.is_running())
		board[prev_pos[0]][prev_pos[1]] = null
		board[target[0]][target[1]] = entity
		prev_pos = target
		if preview:
			preview.prev_pos = new_pos
		if !is_instance_valid(entity):
			return
		entity.board_position = target
		if entity.preview:
			entity.preview.position = entity.position
			entity.preview.board_position = entity.board_position
			preview_board[target[0]][target[1]] = entity.preview
		if entity.is_enemy or entity == self or entity == preview:
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

func push(entity, offset, distance, board, stack, board_pos):
	for i in range(distance):
		if !is_instance_valid(entity):
			return
		var dest = entity.board_position + offset
		if is_valid_position(dest) and board[dest[0]][dest[1]] != null:
			break
		await move(board, entity, dest, stack)

func get_push_offset(player, board, target_pos):
	var offset
	if board_position[0] < target_pos[0]:
		offset = Vector2i(1,0)
	elif board_position[0] > target_pos[0]:
		offset = Vector2i(-1,0)
	elif board_position[1] < target_pos[1]:
		offset = Vector2i(0,1)
	else:
		offset = Vector2i(0,-1)
	return offset
	
func is_valid_position(board_position):
	if board_position[0] < 0 or board_position[0] > Globals.BOARD_SIZE[0] - 1 or board_position[1] < 0 or board_position[1] > Globals.BOARD_SIZE[1] - 1:
		return false
	else:
		return true

func is_in_range(position1, position2, range):
	if abs(position1[0] - position2[0]) + abs(position1[1] - position2[1]) <= range:
		return true
	else:
		return false 

func _on_level_confirm_move():
	has_moved = true

func _on_level_confirm_attack():
	has_moved = false
	end_turn.emit()

func destroy():
	if preview != null:
		lose.emit()
	else:
		get_node("Crossout").visible = true
