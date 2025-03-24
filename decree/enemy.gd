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
	#var result = null
	#var result_distance = null
	#var valid_offsets = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	#for offset in valid_offsets:
		#if offset[0] > board_position[0] or board_position[0] - offset[0] > len(board) - 1 or offset[1] > board_position[1] or board_position[1] - offset[1] > len(board[0]) - 1:
			#continue
		#var x = board_position[0] - offset[0]
		#var y = board_position[1] - offset[1]
		#var target = board[x][y]
		#var target_distance = Vector2i(abs(x - player.board_position[0]), abs(y - player.board_position[1]))
		#var is_closer = true
		#if result != null:
			#if target_distance[0] + target_distance[1] > result_distance[0] + result_distance[1]:
				#is_closer = false
		#if target == player:
			#return player
		#elif target != null and is_closer:
			#result = target
			#result_distance = target_distance
			#

func destroy():
	self.queue_free()
