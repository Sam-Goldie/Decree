extends Button


func _ready():
	self.pressed.connect(move_player)
	
func move_player():
	print("hello world")
	
