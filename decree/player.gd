extends Node2D

var board_position : Vector2i
var prev_board_position : Vector2i
var hp : int
var damage : int
var has_moved : bool
var range : int
var speed : int
var is_enemy : bool

signal move(entity, target)
signal attack(entity, target)
signal end_turn
signal lose

func _ready():
	var hp_display = str(hp)
	$Path2D/PathFollow2D/Sprite2D/Label.text = hp_display

func _on_level_confirm_move():
	has_moved = true

func _on_level_confirm_attack():
	has_moved = false
	end_turn.emit()

func destroy():
	lose.emit()
