class_name SelectionController extends Node2D

@onready var line_renderer: Line2D = get_parent().get_node("line_renderer")

var selected_tiles: Array[ClickableTile] = []
var selecting: bool = false
var currently_selecting_type: Globals.TILE_TYPE = Globals.TILE_TYPE.EMPTY

func on_tile_clicked(tile: ClickableTile):
	var xy_idx: Vector2i = tile.position_in_grid
	print("tile clicked called from SelectionController")
	if tile.tile_type == Globals.TILE_TYPE.OBSTACLE or tile.tile_type == Globals.TILE_TYPE.EMPTY or tile.tile_type == Globals.TILE_TYPE.CHARACTER:
		return
	if selected_tiles.has(tile) == false:
		selected_tiles.append(tile)
		currently_selecting_type = tile.tile_type
		line_renderer.add_point(tile.position)
	selecting = true
		

func on_tile_hovered(tile: ClickableTile):
	pass

func can_start_selection(tile: ClickableTile):
	pass

func next_tile_selection_logic(next_tile: ClickableTile):
	pass


func _on_character_move_completed(current_tile: ClickableTile) -> void:
	current_tile.tile_type = Globals.TILE_TYPE.EMPTY


func _on_character_whole_move_completed() -> void:
	selected_tiles.clear()
	line_renderer.clear_points()
	selecting = false
	print("Character has completed the move, selection cleared.")


func _on_move_button_pressed() -> void:
	if selected_tiles.size() == 0:
		print("No tiles selected for movement.")
		return
	Globals.character.move(selected_tiles)
	selecting = false
	print("Character move initiated with ", selected_tiles.size(), " tiles.")


func _on_reset_button_pressed() -> void:
	selected_tiles.clear()
	line_renderer.clear_points()
	selecting = false