extends Control

var pip_scene = preload("res://pip.tscn")
var pips = []

# where are these pips I see coming from exactly?
func initiate(hp):
	for node in get_children():
		remove_child(node)
		node.queue_free()
	for i in range(hp):
		var new_pip = pip_scene.instantiate()
		new_pip.position = Vector2(i * 3, 1)
		add_child(new_pip)
		pips.append(new_pip)

func reduce_health(amount):
	var pip_count = len(pips)
	if pip_count == 0:
		return
	for i in range(amount):
		pips[pip_count - 1 - i].free()
		pips.remove_at(pip_count - 1 - i)
