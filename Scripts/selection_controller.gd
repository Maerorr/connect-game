class_name SelectionController extends Node2D

@onready var line_renderer: Line2D = get_parent().get_node("line_renderer")

var selected_tiles: Array[ClickableTile] = []
var selecting: bool = false
var currently_selecting_type: Globals.TILE_TYPE = Globals.TILE_TYPE.EMPTY

func _ready() -> void:
	call_deferred("set_connections")

func _process(_delta: float) -> void:
	if selecting:
		if Input.is_action_just_released("left_click"):
			print("Selection ended, total selected tiles: ", selected_tiles.size())
			selecting = false


func set_connections():
	#Globals.character.move_completed.connect(_on_character_move_completed)
	Globals.character.whole_move_completed.connect(_on_character_whole_move_completed)


func on_tile_clicked(tile: ClickableTile):
	if can_start_selection(tile) == false:
		return
	currently_selecting_type = tile.tile_type
	selected_tiles.append(tile)
	line_renderer.add_point(tile.position)
	selecting = true


func on_tile_hovered(tile: ClickableTile):
	if selecting:
		next_tile_selection_logic(tile)
		return


func can_start_selection(tile: ClickableTile):
	if selecting:
		return false
	if tile.tile_type == Globals.TILE_TYPE.OBSTACLE or tile.tile_type == Globals.TILE_TYPE.EMPTY or tile.tile_type == Globals.TILE_TYPE.CHARACTER:
		return false
	if selected_tiles.size() > 0:
		return false
	if Globals.distance_between_chebyshev(Globals.character.current_tile, tile) > 1:
		return false
	return true


func next_tile_selection_logic(next_tile: ClickableTile):
	var prev_tile: ClickableTile = selected_tiles[-1]

	if Globals.distance_between_chebyshev(prev_tile, next_tile) > 1:
		return
		
	if next_tile.tile_type == Globals.TILE_TYPE.OBSTACLE or next_tile.tile_type == Globals.TILE_TYPE.EMPTY:
		return

	if selected_tiles.has(next_tile):
		return
	
	if currently_selecting_type != next_tile.tile_type: # TODO : modify this logic later to allow for special tiles like changing possible selection type
		return

	selected_tiles.append(next_tile)
	line_renderer.add_point(next_tile.position)


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
