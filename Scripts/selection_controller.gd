class_name SelectionController extends Node2D

@onready var line_renderer: Line2D = get_parent().get_node("line_renderer")

var selected_tiles: Array[ClickableTile] = []
var selecting: bool = false
var currently_selecting_type: Globals.TILE_TYPE = Globals.TILE_TYPE.NONE
var changing_types: bool = false;
var allowed_change_types: Array[Globals.TILE_TYPE] = []

func _ready() -> void:
	call_deferred("set_connections")


func _process(_delta: float) -> void:
	if selecting:
		if Input.is_action_just_released("left_click"):
			selecting = false
			currently_selecting_type = Globals.TILE_TYPE.NONE


func set_connections():
	#Globals.character.move_completed.connect(_on_character_move_completed)
	Globals.character.whole_move_completed.connect(_on_character_whole_move_completed)


func on_tile_clicked(tile: ClickableTile):
	print("Tile clicked: ", tile.position_in_grid, " Type: ", tile.tile_type)
	if can_start_selection(tile) == false:
		return
	currently_selecting_type = tile.tile_type
	selected_tiles.append(tile)
	line_renderer.add_point(tile.position)
	selecting = true
	tile.on_tile_selected()


func on_tile_hovered(tile: ClickableTile):
	if selecting:
		next_tile_selection_logic(tile)
		return


func can_start_selection(tile: ClickableTile):
	if selecting:
		return false
	if tile.tile_type == Globals.TILE_TYPE.OBSTACLE or tile.tile_type == Globals.TILE_TYPE.EMPTY:
		return false
	if selected_tiles.size() > 0:
		var dist = Globals.distance_between_chebyshev(selected_tiles[-1], tile)
		if dist > 1 or dist == 0:
			return false
		if currently_selecting_type != tile.tile_type and currently_selecting_type != Globals.TILE_TYPE.NONE:
			return false
	else:
		if Globals.distance_between_chebyshev(Globals.character.current_tile, tile) > 1:
			return false
	return true


func next_tile_selection_logic(next_tile: ClickableTile):
	var prev_tile: ClickableTile = selected_tiles[-1]

	if Globals.distance_between_chebyshev(prev_tile, next_tile) > 1:
		print("Tile is too far away from the last selected tile.")
		return
	
	if next_tile.tile_type == Globals.TILE_TYPE.OBSTACLE or next_tile.tile_type == Globals.TILE_TYPE.EMPTY:
		print("Tile is not selectable: ", next_tile.tile_type)
		return

	if selected_tiles.has(next_tile):
		print("Tile already selected: ", next_tile.position_in_grid)
		return
	
	# TODO : modify this logic later to allow for special tiles like changing possible selection type
	# if currently_selecting_type != next_tile.tile_type and currently_selecting_type != Globals.TILE_TYPE.NONE:
	# 	return

	if changing_types:
		print("changing type selection")
		if next_tile.tile_type in Globals.REGULAR_TILE_TYPES or next_tile.tile_type in Globals.SPECIAL_TILE_TYPES:
			currently_selecting_type = next_tile.tile_type
			changing_types = false;
		else:
			print("(CHANGING) Tile is not selectable: ", next_tile.tile_type)
			return
	else:
		if not (next_tile.tile_type == currently_selecting_type or next_tile.tile_type in Globals.SPECIAL_TILE_TYPES):
			print("Tile is not selectable: ", next_tile.tile_type)
			return

	selected_tiles.append(next_tile)
	line_renderer.add_point(next_tile.position)
	next_tile.on_tile_selected()


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
