extends Node2D
var move_pattern_scene = preload("res://move_patterns.gd")

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

func _ready():
	var hp_display = str(hp)
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

func plan_move(board, player):
	return move_patterns.shift_chase_axis(self, player.board_position)

func find_targets(board, player):
	var player_pos = player.board_position
	var target = board_position
	var attack_axis
	if board_position[0] != player_pos[0] and board_position[1] != player_pos[1]:
		return null
	elif board_position[0] == player_pos[0]:
		attack_axis = 1
	else:
		attack_axis = 0
	match attack_axis:
		0:
			while target[0] > player_pos[0]:
				target[0] -= 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]
			while target[0] < player_pos[0]:
				target[0] += 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]
		1:
			while target[1] > player_pos[1]:
				target[1] -= 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]
			while target[1] < player_pos[1]:
				target[1] += 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]

func destroy():
	if preview:
		preview.queue_free()
		self.queue_free()
