extends Button

var board_position : Vector2i

signal click
signal right_click

func _process(delta):
	if is_hovered():
		$TileSelector.self_modulate.a = 1
	else:
		$TileSelector.self_modulate.a = 0

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		if is_hovered() and event.button_index == MOUSE_BUTTON_LEFT:
			click.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			right_click.emit()
