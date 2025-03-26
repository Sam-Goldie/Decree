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
	
func find_targets():
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

func destroy():
	self.queue_free()
