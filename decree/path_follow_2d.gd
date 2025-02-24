extends PathFollow2D

var speed = 2
signal end_move

func _process(delta):
	progress_ratio += delta * speed
	if progress_ratio == 1:
		end_move.emit()
