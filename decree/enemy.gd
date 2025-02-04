extends Node2D

var board_position : Vector2
var hp : int

func _ready():
	var hp_display = str(hp)
	$TextEdit.text = hp_display

func move(player_pos, board):
	if abs(self.board_position[0] - player_pos[0]) + abs(self.board_position[1] - player_pos[1]) == 1:
		return
	var dest = self.board_position
	var valid_offsets = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	for offset in valid_offsets:
		var target = self.board_position + offset
		if target[0] < 0 or target[0] > len(board) - 1 or target[1] < 0 or target[1] > len(board) - 1 or board[target[0]][target[1]] != null:
			continue
		var current_dist = Vector2(abs(player_pos[0] - dest[0]), abs(player_pos[1] - dest[1]))
		var current_total = current_dist[0] + current_dist[1]
		var target_dist = Vector2(abs(player_pos[0] - target[0]), abs(player_pos[1] - target[1]))
		var target_total = target_dist[0] + target_dist[1]
		print(current_total == target_total)
		if current_total > target_total or (current_total == target_total and abs(current_dist[0] - current_dist[1]) > abs(target_dist[0] - target_dist[1])):
			dest = target
	self.board_position = dest
	self.position = dest * 16

func find_targets(board, player):
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
