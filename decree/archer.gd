extends Node2D

var board_position : Vector2i
var hp : int
var damage : int
var has_moved : bool
var board
var speed : int
var range : int
var is_enemy : bool
var enemies : Array
var player
var type

func _ready():
	var hp_display = str(hp)
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)

func initialize(board_position, hp, damage, has_moved, board, speed, range, is_enemy, enemies, player, type):
	self.board_position = board_position
	self.hp = hp
	self.damage = damage
	self.has_moved = has_moved
	self.board = board
	self.speed = speed
	self.range = range
	self.is_enemy = is_enemy
	self.enemies = enemies
	self.player = player
	self.type = type

func find_targets(next_move):
	var target = board_position
	var attack_axis
	if board_position[0] != player.board_position[0] and board_position[1] != player.board_position[1]:
		return null
	elif board_position[0] == player.board_position[0]:
		attack_axis = 1
	else:
		attack_axis = 0
	match attack_axis:
		0:
			while target[0] > player.board_position[0]:
				target[0] -= 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]
			while target[0] < player.board_position[0]:
				target[0] += 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]
		1:
			while target[1] > player.board_position[1]:
				target[1] -= 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]
			while target[1] < player.board_position[1]:
				target[1] += 1
				if board[target[0]][target[1]] != null:
					return board[target[0]][target[1]]

func destroy():
	self.queue_free()
