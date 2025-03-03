class_name MovePatterns

var grid : AStarGrid2D

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = (int_position - (int_position % Vector2i(16,16))) / 16
	return snapped_position

func shift_targeted(entity, target):
	if grid.is_dirty():
		grid.update()
	var dest = []
	var path = grid.get_id_path(entity.board_position, target, true)
	if len(path) > 2:
		for i in range(1, entity.speed + 1):
			dest.append(path[i])
	dest.reverse()
	return dest
#
#func shift_two_targeted(entity, target):
	#if grid.is_dirty():
		#grid.update()
	#var path = grid.get_id_path(entity.board_position, target, true)
	#var dest = []
	#if len(path) > 2:
		#for i in range(1,3):
			#dest.append(path[i])
	#dest.reverse()
	#return dest
