extends Node2D

signal turn_finished

var move_pattern_scene = preload("res://move_patterns.gd")
var entity_actions_scene = preload("res://entity_actions.gd")
var board = Globals.BOARD
var preview_board = Globals.PREVIEW_BOARD

var board_position : Vector2i
var hp : int
var damage : int
var has_moved : bool
var speed : int
var range : int
var is_enemy : bool
var enemies : Array
var type : String
var direction : String
var preview : Node2D
var move_patterns = move_pattern_scene.new()
var active_turns = Globals.ACTIVE_TURNS
var running_tweens = Globals.RUNNING_TWEENS
var entity_actions = entity_actions_scene.new() 
var bulls = Globals.BULLS
var player = Globals.PLAYER

func _ready():
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)

func initialize(board_position, hp, damage, has_moved, speed, range, is_enemy, enemies, type, preview):
	self.board_position = board_position
	self.hp = hp
	self.damage = damage
	self.has_moved = has_moved
	self.speed = speed
	self.range = range
	self.is_enemy = is_enemy
	self.enemies = enemies
	self.type = type
	self.preview = preview

func is_valid_position(board_position):
	if board_position[0] < 0 or board_position[0] > Globals.BOARD_SIZE[0] - 1 or board_position[1] < 0 or board_position[1] > Globals.BOARD_SIZE[1] - 1:
		return false
	else:
		return true

func find_targets(board, _player):
	var offset
	match self.direction:
		"right":
			offset = Vector2i(1,0)
		"left":
			offset = Vector2i(-1,0)
		"down":
			offset = Vector2i(0,1)
		"up":
			offset = Vector2i(0,-1)
	var target_pos = self.board_position + offset
	if is_valid_position(target_pos) and board[target_pos[0]][target_pos[1]] != null:
		return board[target_pos[0]][target_pos[1]]
	#var x = board_position[0]
	#var y = board_position[1]
	#if x != player.board_position[0] and y != player.board_position[1]:
		#return null
	#if x < player.board_position[0]:
		#return board[x+1][y]
	#elif x > player.board_position[0]:
		#return board[x-1][y]
	#elif y < player.board_position[1]:
		#return board[x][y+1]
	#else:
		#return board[x][y-1]

func take_turn(board, target_player, stack, board_pos):
	var dest = plan_move(board, target_player)
	var target
	if dest != null and dest != board_position:
		has_moved = true
		if board[dest[0]][dest[1]] == null:
			await move(board, self, dest, stack, board_pos)
		else:
			target = board[dest[0]][dest[1]]
	if target == null:
		target = find_targets(board, target_player)
	if target != null:
		has_moved = true
		await attack(self, target, board, target_player, stack)
	turn_finished.emit()
	
func attack(entity, target, board, player, stack):
	var entity_pos = entity.board_position
	var target_pos = target.board_position
	if !is_instance_valid(entity) or !is_in_range(entity_pos, target_pos, entity.range):
		turn_finished.emit(stack)
		return
	#player.has_moved = false
	if board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != entity:
		var anim_player = entity.get_node("AnimationPlayer")
		if anim_player != null:
			await animate_attack(entity.board_position, target.board_position, anim_player)
			#target = player if entity.preview else player.preview
		if target != player.preview:
			entity_actions.damage(target, entity.damage, board, player)

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

func move(board, entity, target, stack, board_pos):
	#tween.tween_callback(entity.find_targets)
	var tween = create_tween()
	active_turns[board_pos[0]][board_pos[1]] = tween
	var prev_position = entity.board_position
	#if entity == player:
		#remove_target_highlights(prev_position)
	if !is_valid_position(target):
		return
	if board[target[0]][target[1]] == null:
		var new_pos = Vector2(target * 16)
		if !entity.preview:
			entity_actions.show_preview()
		else:
			entity_actions.hide_preview()
		running_tweens.append(tween)
		tween.tween_property(entity, "position", new_pos, 0.2)
		if tween.is_running():
			await tween.finished
		print(tween.is_running())
		#tween never finishes
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
		
func is_in_range(position1, position2, range):
	if abs(position1[0] - position2[0]) + abs(position1[1] - position2[1]) <= range:
		return true
	else:
		return false 

func plan_move(board, player):
	return move_patterns.charge(self, player, board)

func destroy():
	if preview:
		preview.queue_free()
		self.queue_free()
