extends Node2D

var board_position : Vector2i
var hp : int
var grid : AStarGrid2D

func _ready():
	var hp_display = str(hp)
	$Path2D/PathFollow2D/Label.text = hp_display

func destroy():
	grid.set_point_solid(board_position, false)
	self.queue_free()
