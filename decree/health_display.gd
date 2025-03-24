extends Control

var pip_scene = preload("res://pip.tscn")
var pips = []

func initiate(hp):
	for i in range(hp):
		var new_pip = pip_scene.instantiate()
		new_pip.position = Vector2(i * 3, 1)
		add_child(new_pip)
		pips.append(new_pip)

func reduce_health(amount):
	var pip_count = len(pips)
	for i in range(amount):
		pips[pip_count - 1 - i].free()
		pips.remove_at(pip_count - 1 - i)
