extends Node2D

var board_position : Vector2

func move(player_pos):
	var distance = self.position - player_pos
	if abs(distance[0]) + abs(distance[1]) == 16:
		return
	elif distance[1] == 0 or abs(distance[0]) < abs(distance[1]):
		if distance[0] < 0:
			self.position += Vector2(16,0)
		else:
			self.position -= Vector2(16,0)
	else:
		if distance[1] < 0:
			self.position += Vector2(0,16)
		else:
			self.position -= Vector2(0,16)

func find_targets(board, player):
	var result = null
	var valid_offsets = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	for offset in valid_offsets:
		var target = board[board_position[0] - offset[0]][board_position[1] - offset[1]]
		if target == player:
			return player
		elif target != null:
			result = target
	return result
