extends Node2D

var board_position : Vector2i
var hp : int
var damage : int
var has_moved : bool
var board
@onready var flash_player = $Path2D/PathFollow2D/Sprite2D/AnimationPlayer
signal flash_finished

func _ready():
	var hp_display = str(hp)
	$Path2D/PathFollow2D/Label.text = hp_display

func find_targets(player):
	var result = null
	var valid_offsets = [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]
	for offset in valid_offsets:
		if offset[0] > board_position[0] or board_position[0] - offset[0] > len(board) - 1 or offset[1] > board_position[1] or board_position[1] - offset[1] > len(board[0]) - 1:
			continue
		var target = board[board_position[1] - offset[1]][board_position[0] - offset[0]]
		if target == player:
			return player
		elif target != null:
			result = target
	return result

func flash():
	flash_player.play("flash")
	flash_finished.emit()
