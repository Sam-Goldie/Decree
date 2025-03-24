extends Node2D

var board_position : Vector2i
var hp : int
var grid : AStarGrid2D
var type : String
var is_enemy : bool

signal destroy_rock

func _ready():
	$Path2D/PathFollow2D/Sprite2D/HealthDisplay.initiate(hp)

func initialize(board_position, hp, is_enemy, type, grid):
	self.board_position = board_position
	self.hp = hp
	self.is_enemy = is_enemy
	self.type = type
	self.grid = grid
	
func destroy():
	grid.set_point_solid(board_position, false)
	destroy_rock.emit()
	self.queue_free()
