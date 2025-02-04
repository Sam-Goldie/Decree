extends Node2D

var board_position : Vector2
var hp : int

func _ready():
	var hp_display = str(hp)
	$TextEdit.text = hp_display
