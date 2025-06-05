extends Node2D

var board_position : Vector2i
var hp : int = 5
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

func initialize(board_position, hp, has_moved, speed, range, is_enemy, preview):
	self.board_position = board_position
	self.hp = hp
	self.has_moved = has_moved
	self.speed = speed
	self.range = range
	self.is_enemy = is_enemy
	self.preview = preview

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
	else:
		#crossout is not appearing. what da heck
		get_node("Crossout").visible = true
