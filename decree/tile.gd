extends Control

var board_position : Vector2i
var currently_hovered = false

signal click
signal right_click
signal is_hovering
signal stop_hovering

#figure out why this is multifiring

func _input(event):
	var inputmouseness = event is InputEventMouseButton
	var clickness = event.is_action_pressed("click")
	var nonechoness = not event.is_echo()
	#var Vector2i(get_global_mouse_position() / 16) == board_position
	var mouse_pos = Vector2i(get_global_mouse_position() / 16)
	if event.is_echo() or (!currently_hovered and mouse_pos != board_position):
		return
	elif currently_hovered and mouse_pos != board_position:
		currently_hovered = false
		stop_hovering.emit()
	elif currently_hovered:
		if event is InputEventMouseButton and event.is_action_pressed("click"):
			if Vector2i(floor(get_global_mouse_position() / 16)) == board_position:
				click.emit()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				right_click.emit()
	elif mouse_pos == board_position:
		currently_hovered = true
		is_hovering.emit()
