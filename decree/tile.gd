extends Button
#
var board_position : Vector2i
#
signal click
#
#func (event):
	#get_local_mouse_position()
	#if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		#click.emit(self)

func _process(delta):
	if is_hovered():
		$TileSelector7.self_modulate.a = 1
	else:
		$TileSelector7.self_modulate.a = 0

func _input(event):
	if is_hovered() and event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		click.emit()
