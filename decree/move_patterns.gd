class_name MovePatterns

var grid : AStarGrid2D

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = (int_position - (int_position % Vector2i(16,16))) / 16
	return snapped_position

func shift_one_targeted(entity, target):
	#grid.set_point_solid(Vector2i(2,2))
	if grid.is_dirty():
		grid.update()
	var path = grid.get_id_path(entity.board_position, target, true)
	if len(path) > 2:
		return path[1]
	else: 
		return null

func shift_two_targeted(entity, target):
	if grid.is_dirty():
		grid.update()
	var path = grid.get_id_path(entity.board_position, target, true)
	if len(path) > 3:
		return path[2]
	elif len(path) > 2:
		return path[1] 
	else: 
		return null
