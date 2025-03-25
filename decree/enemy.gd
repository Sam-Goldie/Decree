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
	
func find_targets(next_dest):
	if next_dest == null:
		return null
	var target = board[next_dest[0]][next_dest[1]]
	if target != null:
		return target
	else:
		return null

func destroy():
	self.queue_free()
