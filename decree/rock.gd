extends Node2D

var board_position : Vector2i
var hp : int
var is_enemy : bool
var type : String
var preview : Node2D
var prev_pos : Vector2


signal destroy_rock

func _ready():
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)

func initialize(board_position, hp, is_enemy, type, preview):
	self.board_position = board_position
	self.hp = hp
	self.is_enemy = is_enemy
	self.type = type
	self.preview = preview
	
func destroy():
	if preview:
		destroy_rock.emit()
		self.preview.queue_free()
		self.queue_free()
	else:
		get_node("Crossout").visible = true
