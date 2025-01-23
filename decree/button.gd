extends Button

@onready
var player = Level.player

signal move_player(position)

func _ready():
	self.pressed.connect(move)
	
func move():
	print(self.position)
	player.position = self.position
	
