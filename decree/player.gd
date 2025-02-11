extends Node2D

var board_position : Vector2
var hp : int
var damage : int
var has_moved : bool

signal move(entity, target)
signal attack(entity, target)
signal end_turn

func _ready():
	var hp_display = str(hp)
	$Label.text = hp_display

func _on_level_confirm_move():
	has_moved = true

func _on_level_confirm_attack():
	has_moved = false
	end_turn.emit()
