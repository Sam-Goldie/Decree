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
	for i in range(amount):
		pips[len(pips) - 1 - i].queue_free()
		pips.remove_at(len(pips) - 1 - i)
