extends TileMapLayer

var player_class = preload("res://Player.tscn")
var enemy_class = preload("res://Enemy.tscn")

var board = [[null, null, null, null], [null, player_class.instantiate(), null, null], [null, null, enemy_class.instantiate(), null],[null, null, null, null]]
