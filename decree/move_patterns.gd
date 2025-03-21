class_name MovePatterns

var grid : AStarGrid2D

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = (int_position - (int_position % Vector2i(16,16))) / 16
	return snapped_position

func get_distance(board_pos1 : Vector2i, board_pos2 : Vector2i):
	var total_distance = board_pos1 - board_pos2
	return abs(total_distance[0]) + abs(total_distance[1])

# problem is, I need to not include deeper path elements because I reverse, but I need them to choose my attack later
func shift_chase(entity, target):
	if grid.is_dirty():
		grid.update()
	var path = grid.get_id_path(entity.board_position, target, true)
	return path

func shift_target(entity, target):
	if grid.is_dirty():
		grid.update()
	var path = grid.get_id_path(entity.board_position, target, false)
	if len(path) > entity.speed + 1 or len(path) == 0:
		return null
	else:
		return target

func shift_chase_axis(entity, target):
	var path = []
	#var path_distance = 0
	var target_x = target[0]
	var target_y = target[1]
	if entity.board_position[0] == target_x or entity.board_position[1] == target_y:
		return path
	for i in range(Globals.BOARD_SIZE[0]):
		var current_path = grid.get_id_path(entity.board_position, Vector2i(target_x, i), false)
		#var current_distance = get_distance(entity.board_position, Vector2i(target_x, i))
		if len(path) == 0 or (len(current_path) > 0 and len(current_path) < len(path)):
			path = current_path
			#path_distance = current_distance
	for i in range(Globals.BOARD_SIZE[1]):
		var current_path = grid.get_id_path(entity.board_position, Vector2i(i, target_y), false)
		#var current_distance = get_distance(entity.board_position, Vector2i(i, target_y))
		if len(path) == 0 or (len(current_path) > 0 and len(current_path) < len(path)):
			path = current_path
			#path_distance = current_distance
	return path
