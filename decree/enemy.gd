extends Node2D

func move(player_pos):
	var distance = self.position - player_pos
	if abs(distance[0]) + abs(distance[1]) == 1:
		return
	elif abs(distance[0]) < abs(distance[1]):
		if distance[0] < 0:
			self.position += Vector2(16,0)
		else:
			self.position -= Vector2(16,0)
	else:
		if distance[1] < 0:
			self.position += Vector2(0,16)
		else:
			self.position -= Vector2(0,16)
