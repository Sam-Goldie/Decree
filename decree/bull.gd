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
var grid

func _ready():
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)

func initialize(board_position, hp, damage, has_moved, board, speed, range, is_enemy, enemies, player, type, grid):
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
	self.grid = grid

func find_targets():
	var x = board_position[0]
	var y = board_position[1]
	if x != player.board_position[0] and y != player.board_position[1]:
		return null
	if x < player.board_position[0]:
		return board[x+1][y]
	elif x > player.board_position[0]:
		return board[x-1][y]
	elif y < player.board_position[1]:
		return board[x][y+1]
	else:
		return board[x][y-1]

func destroy():
	self.queue_free()
