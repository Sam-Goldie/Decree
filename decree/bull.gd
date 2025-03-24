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

func find_targets(target):
	if board_position[0] != target.board_position[0] and board_position[1] != target.board_position[1]:
		return null
	var path = grid.get_id_path(board_position, target.board_position)
	if board[path[1][0]][path[1][1]] != null:
		return board[path[1][0]][path[1][1]]
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
