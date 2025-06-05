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

func show_preview():
	player.preview.visible = true
	for enemy in enemies:
		if is_instance_valid(enemy) and is_instance_valid(enemy.preview):
			enemy.preview.visible = true
			enemy.visible = false
	for bull in bulls:
		if is_instance_valid(bull) and is_instance_valid(bull.preview):
			bull.preview.visible = true
			bull.visible = false
	for rock in rocks:
		if is_instance_valid(rock) and is_instance_valid(rock.preview):
			rock.preview.visible = true
			rock.visible = false

func hide_preview():
	if player != null:
		player.preview.visible = false
	for enemy in enemies:
		if is_instance_valid(enemy) and is_instance_valid(enemy.preview):
			enemy.preview.visible = false
			enemy.visible = true
	for bull in bulls:
		if is_instance_valid(bull) and is_instance_valid(bull.preview):
			bull.preview.visible = false
			bull.visible = true
	for rock in rocks:
		if is_instance_valid(rock) and is_instance_valid(rock.preview):
			rock.preview.visible = false
			rock.visible = true

func damage(target, amount, board, player):
	if !is_instance_valid(target) or target == null:
		return
	target.hp -= amount
	if target.hp > 0:
		var health = target.get_node("Path2D/PathFollow2D/Sprite2D/HealthDisplay").reduce_health(amount)
	elif target != player.preview:
		board[target.board_position[0]][target.board_position[1]] = null
		target.destroy()
