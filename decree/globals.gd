extends Node

var player_scene = preload("res://Player.tscn")

var PLAYER := player_scene.instantiate()
var HEALTH_PATH := "Navigation/%s/Path2D/PathFollow2D/Sprite2D/Label"
var TURN_ORDER_PATH := "Path2D/PathFollow2D/Sprite2D/TurnOrder"
var ROCK_COORDS := Rect2(96, 32, 16, 16)
var BOARD_SIZE := Vector2i(6,6)
var BOARD := []
var PREVIEW_BOARD := []
var TERRAIN := []
var GRID := AStarGrid2D.new()
var ENEMIES := []
var PREVIEW_ENEMIES := []
var RUNNING_TWEENS := {}
var IS_PLAYER_TURN := true
var BULLS := []
var ROCKS := []
var ACTIVE_TURNS := []
var ACTIVE_ANIM = AnimationPlayer.new()
