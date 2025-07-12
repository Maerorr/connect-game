class_name GridController extends Node2D

# THIS CLASS IS THE TOP-MOST MANAGER FOR THE GRID. IT IS RESPONSIBLE FOR CREATION OF THE GRID.
# IT ONLY STORES THE BACKGROUND TILES.
# FOR ACCESS TO THE TILE OBJECTS, USE THE MAP OBJECTS MANAGER.

var clickable_tiles = []
# @export var grid_size: Vector2i = Vector2i(5, 5)
var map_size: Vector2i = Vector2i.ZERO
var background_tile_prefab: PackedScene = preload("res://Prefabs/bg_tile.tscn")
var tile_prefab: PackedScene = preload("res://Prefabs/tile_object.tscn")

var selected_tiles: Array[ClickableTile] = []
var map_data: Array[Globals.TILE_TYPE] = []
var selecting: bool = false
var character_tile: ClickableTile = null

@onready var character: Character = $character
@onready var line_renderer: Line2D = get_node("line_renderer")
@onready var map_object_manager: MapObjectsManager = $map_objects_manager
var currently_selecting_type: Globals.TILE_TYPE = Globals.TILE_TYPE.EMPTY


func _ready():
	# position itself in the center of the screen
	global_position = get_viewport_rect().size / 2.0
	Globals.character = character


func _on_map_loader_map_loaded(loaded_map_size: Vector2i, loaded_map_data: Array[Globals.TILE_TYPE]) -> void:
	Globals.map_size = loaded_map_size
	map_data = loaded_map_data
	setup_tiles(loaded_map_data)
	

func setup_tiles(loaded_map_data: Array[Globals.TILE_TYPE]):
	map_object_manager.setup_map(loaded_map_data)


func _process(_delta: float) -> void:
	if selecting:
		if Input.is_action_just_released("left_click"):
			print("Selection ended, total selected tiles: ", selected_tiles.size())
			selecting = false
			#character.move(selected_tiles)


func get_tile(xy_idx: Vector2i) -> ClickableTile:
	if xy_idx.x < 0 or xy_idx.x >= map_size.x or xy_idx.y < 0 or xy_idx.y >= map_size.y:
		return null
	return clickable_tiles[xy_idx.y + xy_idx.x * map_size.y]


func on_tile_clicked(tile: ClickableTile):
	var xy_idx: Vector2i = tile.position_in_grid
	print("Tile clicked at position, callback from grid ", xy_idx)
	if tile.tile_type == Globals.TILE_TYPE.OBSTACLE or tile.tile_type == Globals.TILE_TYPE.EMPTY or tile.tile_type == Globals.TILE_TYPE.CHARACTER:
		return
	if selected_tiles.has(tile) == false:
		selected_tiles.append(tile)
		currently_selecting_type = tile.tile_type
		line_renderer.add_point(tile.position)
	selecting = true


func on_tile_hovered(tile: ClickableTile):
	if selecting:
		next_tile_selection_logic(tile)
		return


func can_start_selection(tile: ClickableTile) -> bool:
	if selecting:
		return false
	if tile.tile_type == Globals.TILE_TYPE.OBSTACLE or tile.tile_type == Globals.TILE_TYPE.EMPTY:
		return false
	if selected_tiles.size() > 0:
		return false
	if Globals.distance_between_chebyshev(character_tile, tile) > 1:
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
