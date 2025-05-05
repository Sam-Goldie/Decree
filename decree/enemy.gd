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
var preview : Node2D
var move_patterns = move_pattern_scene.new()
var running_tweens = Globals.RUNNING_TWEENS
var entity_actions = entity_actions_scene.new() 

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
	
func find_targets(board, player):
	var x = self.board_position[0]
	var y = self.board_position[1]
	if x < Globals.BOARD_SIZE[0] - 1 and board[x+1][y] == player:
		return player
	elif x > 0 and board[x-1][y] == player:
		return player
	elif y < Globals.BOARD_SIZE[1] - 1 and board[x][y+1] == player:
		return player
	elif y > 0 and board[x][y-1] == player:
		return player
	return null

func take_turn(board, target_player, stack):
	#if len(stack) == 0:
		#for tween in running_tweens:
			#if tween.is_running():
				#await tween.finished
		#is_player_turn = true
		#for enemy in enemies:
			#enemy.has_moved = false
			#enemy.preview.has_moved = false
		#return
	#var enemy = stack.pop_back()
	if has_moved:
		turn_finished.emit()
		return
	var dest = plan_move(board, target_player)
	var target
	if dest != null and dest != board_position:
		has_moved = true
		if board[dest[0]][dest[1]] == null:
			entity_actions.move(board, self, dest)
		else:
			target = board[dest[0]][dest[1]]
	if target == null:
		target = find_targets(board, target_player)
	if target != null:
		has_moved = true
		entity_actions.attack(self, target, board, target_player, stack)
	take_turn(board, target_player, stack)

func plan_move(board, player):
	return move_patterns.shift_chase(self, player.board_position)

func destroy():
	if preview:
		preview.queue_free()
		self.queue_free()
