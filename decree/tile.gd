extends Control

var board_position : Vector2i
var currently_hovered = false

signal click
signal right_click
signal is_hovering

#func _process(delta):
	#if board_position == Vector2i(5, 2):
		#print("hi")
	#if currently_hovered:
		#$TileSelector.self_modulate.a = 1
		#is_hovering.emit()
		#currently_hovered = true
	#else:
		#currently_hovered = false
		#$TileSelector.self_modulate.a = 0

func _input(event):
	if event is InputEventMouseButton and event.is_action_pressed("click") and not event.is_echo():
		if Vector2i(floor(get_global_mouse_position() / 16)) == board_position:
			click.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			right_click.emit()
	# just made this change
	elif !currently_hovered and !event.is_echo() and Vector2i(get_global_mouse_position() / 16) == board_position:
		currently_hovered = true
		is_hovering.emit()
	else:
		currently_hovered = false
