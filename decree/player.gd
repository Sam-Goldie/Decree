extends Node2D

var board_position : Vector2i
var prev_board_position : Vector2i
var hp : int
var damage : int
var has_moved : bool
var range : int
var speed : int
var is_enemy : bool
var preview : Node2D
var tween : Tween

signal move(entity, target)
signal attack(entity, target)
signal end_turn
signal lose

func _ready():
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)

func _on_level_confirm_move():
	has_moved = true

func _on_level_confirm_attack():
	has_moved = false
	end_turn.emit()

func destroy():
	if preview != null:
		lose.emit()
