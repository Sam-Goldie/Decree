extends Popup
signal restart

func _input(event):
	if event.is_pressed():
		restart.emit()
