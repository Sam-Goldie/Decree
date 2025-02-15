extends Node2D

var board_position : Vector2i
var hp : int
var damage : int
var board
#@onready
#var grid = AStarGrid2D.new()

func _ready():
	var hp_display = str(hp)
	$Label.text = hp_display
	#grid.size = Vector2i(4,4)
	#grid.cell_size = Vector2(16,16)
	#grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#grid.update()

func plan_move(player_pos):
	var dest = null
	#var path = grid.get_id_path(self.board_position, player_pos)
	#if len(path) > 1:
		#dest = path[1]
	#if abs(self.board_position[0] - player_pos[0]) + abs(self.board_position[1] - player_pos[1]) == 1:
		#return dest
	#var valid_offsets = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	#for offset in valid_offsets:
		#var target = self.board_position + offset
		#if target[0] < 0 or target[0] > len(board) - 1 or target[1] < 0 or target[1] > len(board) - 1 or board[target[0]][target[1]] != null:
			#continue
		#var current_dist = Vector2(abs(player_pos[0] - dest[0]), abs(player_pos[1] - dest[1]))
		#var current_total = current_dist[0] + current_dist[1]
		#var target_dist = Vector2(abs(player_pos[0] - target[0]), abs(player_pos[1] - target[1]))
		#var target_total = target_dist[0] + target_dist[1]
		#print(current_total == target_total)
		#if current_total > target_total or (current_total == target_total and abs(current_dist[0] - current_dist[1]) > abs(target_dist[0] - target_dist[1])):
			#dest = target
	return dest

func find_targets(player):
	var result = null
	var valid_offsets = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	for offset in valid_offsets:
		if offset[0] > board_position[0] or board_position[0] - offset[0] > len(board) - 1 or offset[1] > board_position[1] or board_position[1] - offset[1] > len(board[0]) - 1:
			continue
		var target = board[board_position[0] - offset[0]][board_position[1] - offset[1]]
		if target == player:
			return player
		elif target != null:
			result = target
	return result
