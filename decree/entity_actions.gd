extends Node2D

signal turn_finished
signal did_move

var preview_board = Globals.PREVIEW_BOARD
var player = Globals.PLAYER
var enemies = Globals.ENEMIES
var bulls = Globals.BULLS
var running_tweens = Globals.RUNNING_TWEENS
var rocks = Globals.ROCKS
var active_turns = Globals.ACTIVE_TURNS

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

#investigate tween callback
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
			show_preview()
		else:
			hide_preview()
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
			
#func move(board, entity, target):
	#var tween = $Navigation.create_tween()
	##var tween = create_tween()
	##var did_move = false
	#var prev_position = entity.board_position
	#if !is_valid_position(target):
		#return did_move
	#if board[target[0]][target[1]] == null:
		#var new_pos = Vector2(target * 16)
		##entity.position = target * 16
		#tween.tween_property(entity, "position", new_pos, 0.2)
		#await tween.finished
		#tween.stop()
		##if entity.position != new_pos:
			##return
		#board[prev_position[0]][prev_position[1]] = null
		#board[target[0]][target[1]] = entity
		#entity.board_position = target
		#if entity.preview:
			#entity.preview.position = entity.position
			#entity.preview.board_position = entity.board_position
			#preview_board[target[0]][target[1]] = entity.preview
		#if entity.is_enemy or entity == player:
			#entity.has_moved = true
		#did_move.emit()
			#
		##for i in range(len(bulls)):
			##var bull = bulls[i]
			##var is_queued = false
			##for enemy in enemy_stack:
				##if enemy == bull:
					##is_queued = true
					##break
			##if is_queued:
				##continue
			##if bull == entity:
				##continue
			##if bull.board_position[0] == target[0] or bull.board_position[1] == target[1]:
				##if bull.board_position[0] < target[0]:
					##bull.direction = "right"
				##elif bull.board_position[0] > target[0]:
					##bull.direction = "left"
				##elif bull.board_position[1] < target[1]:
					##bull.direction = "down"
				##elif bull.board_position[1] > target[1]:
					##bull.direction = "up"
				##enemy_stack.append(bull)
	#if entity == player:
		#player.prev_board_position = prev_position
	#return did_move

#func move(board, entity, target, tween):
	##var tween = create_tween()
	#hide_preview.emit()
	#var prev_position = entity.board_position
	#if !is_valid_position(target):
		#return did_move
	#if board[target[0]][target[1]] == null:
		#var new_pos = Vector2(target * 16)
		##entity.position = target * 16
		#show_preview.emit()
		#tween.stop()
		#tween.tween_property(entity, "position", new_pos, 0.2)
		##if tween.is_running():
			##await tween.finished
		##else:
			##print("error in move")
			##return
		##if entity.position != new_pos:
			##return
		#board[prev_position[0]][prev_position[1]] = null
		#board[target[0]][target[1]] = entity
		#entity.board_position = target
		#did_move.emit()
		

func attack(entity, target, board, player, stack):
	var entity_pos = entity.board_position
	var target_pos = target.board_position
	if !is_instance_valid(entity) or !is_in_range(entity_pos, target_pos, entity.range):
		turn_finished.emit(stack)
		return
	if board[target_pos[0]][target_pos[1]] != null and board[target_pos[0]][target_pos[1]] != entity:
		var anim_player = entity.get_node("AnimationPlayer")
		if anim_player != null:
			await animate_attack(entity.board_position, target.board_position, anim_player)
		if target != player.preview:
			damage(target, entity.damage, board, player)
			turn_finished.emit(board, player, stack)

func damage(target, amount, board, player):
	if !is_instance_valid(target) or target == null:
		return
	target.hp -= amount
	if target.hp > 0:
		var health = target.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").reduce_health(amount)
	elif target != player.preview:
		board[target.board_position[0]][target.board_position[1]] = null
		target.destroy()

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

func push(entity, offset, distance, board, stack, board_pos):
	for i in range(distance):
		if !is_instance_valid(entity):
			return
		var validity = is_instance_valid(entity)
		var dest = entity.board_position + offset
		if is_valid_position(dest) and board[dest[0]][dest[1]] != null:
			break
		await move(board, entity, dest, stack, board_pos)
