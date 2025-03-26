class_name MovePatterns

var grid : AStarGrid2D
var board

func _init():
	grid = Globals.GRID
	board = Globals.BOARD
	
func is_valid_position(board_position):
	if board_position[0] < 0 or board_position[0] > Globals.BOARD_SIZE[0] - 1 or board_position[1] < 0 or board_position[1] > Globals.BOARD_SIZE[1] - 1:
		return false
	else:
		return true

func get_board_position(position : Vector2):
	var int_position = Vector2i(floori(position[0]), floori(position[1]))
	var snapped_position = (int_position - (int_position % Vector2i(16,16))) / 16
	return snapped_position

func get_distance(board_pos1 : Vector2i, board_pos2 : Vector2i):
	var total_distance = board_pos1 - board_pos2
	return abs(total_distance[0]) + abs(total_distance[1])

func shift_chase(entity, target):
	var dest
	var offset = entity.board_position - target
	if offset[0] < 0:
		return entity.board_position + Vector2i(1,0)
	elif offset[0] > 0:
		return entity.board_position + Vector2i(-1,0)
	elif offset[1] < 0:
		return entity.board_position + Vector2i(0,1)
	else:
		return entity.board_position + Vector2i(0,-1)

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
	for i in range(Globals.BOARD_SIZE[1]):
		var current_path = grid.get_id_path(entity.board_position, Vector2i(target_x, i), false)
		#var current_distance = get_distance(entity.board_position, Vector2i(target_x, i))
		if len(path) == 0 or (len(current_path) > 0 and len(current_path) < len(path)):
			path = current_path
			#path_distance = current_distance
	for i in range(Globals.BOARD_SIZE[0]):
		var current_path = grid.get_id_path(entity.board_position, Vector2i(i, target_y), false)
		#var current_distance = get_distance(entity.board_position, Vector2i(i, target_y))
		if len(path) == 0 or (len(current_path) > 0 and len(current_path) < len(path)):
			path = current_path
			#path_distance = current_distance
	return path

func charge(entity, target):
	var dest = entity.board_position
	var offset
	match entity.direction:
		"right":
			offset = Vector2i(1,0)
		"left":
			offset = Vector2i(-1,0)
		"down":
			offset = Vector2i(0,1)
		"up":
			offset = Vector2i(0,-1)
			
	while is_valid_position(dest + offset):
		var next = dest + offset
		if board[next[0]][next[1]] == null:
			dest = next
		else:
			return dest
	return dest
