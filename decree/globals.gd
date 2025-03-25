extends Node

var HEALTH_PATH := "Navigation/%s/Path2D/PathFollow2D/Sprite2D/Label"
var TURN_ORDER_PATH := "Path2D/PathFollow2D/Sprite2D/TurnOrder"
var ROCK_COORDS := Rect2(96, 32, 16, 16)
var BOARD_SIZE := Vector2i(6,6)
var BOARD := []
var TERRAIN := []
var GRID := AStarGrid2D.new()
var ENEMIES := AStarGrid2D.new()
