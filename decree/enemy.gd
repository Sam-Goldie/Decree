extends Node2D
var move_pattern_scene = preload("res://move_patterns.gd")

@export var board_position : Vector2i
@export var hp : int
@export var damage : int
@export var has_moved : bool
@export var speed : int
@export var range : int
@export var is_enemy : bool
@export var enemies : Array
@export var type : String
@export var preview : Node2D
var move_patterns = move_pattern_scene.new()

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

func plan_move(board, player):
	return move_patterns.shift_chase(self, player.board_position)

func destroy():
	self.queue_free()
