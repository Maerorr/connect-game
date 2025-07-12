class_name Character extends Node2D
# grid travelling character

var current_tile: ClickableTile = null
var next_tile: ClickableTile = null
var previous_tile: ClickableTile = null
@export var time_to_move_seconds: float = 0.25 # time in seconds to move to the next tile
var move_tween: Tween = null
var path: Array[ClickableTile] = []

signal move_completed(current_tile: ClickableTile)
signal whole_move_completed()

func move(_path: Array[ClickableTile]) -> void:
	path = _path
	move_coroutine()

func move_coroutine() -> void:
	for tile in path:
		travel_to_tile(tile)
		await self.move_completed
	on_whole_move_completed()

func travel_to_tile(tile: ClickableTile) -> void:
	if (Globals.distance_between_chebyshev(current_tile, tile) > 1):
		return
	if (current_tile == tile):
		return
	if (move_tween != null):
		move_tween.stop()
	next_tile = tile
	move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "position", tile.position, time_to_move_seconds)
	move_tween.tween_callback(_on_move_completed)

func _on_move_completed() -> void:
	previous_tile = current_tile
	current_tile = next_tile
	move_completed.emit(next_tile)

func on_whole_move_completed() -> void:
	whole_move_completed.emit()
	path.clear()
	next_tile = null
	move_tween = null
