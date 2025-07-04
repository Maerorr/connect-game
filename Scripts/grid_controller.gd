class_name GridController extends Node2D

# create a container for the clickable tiles
var clickable_tiles = []
# @export var grid_size: Vector2i = Vector2i(5, 5)
var map_size: Vector2i = Vector2i.ZERO
@export var tile_size: int = 64
@export var tile_spacing: int = 10
var tile_prefab: PackedScene = preload("res://Prefabs/clickable_tile.tscn")

var selected_tiles: Array[ClickableTile] = []
var map_data: Array[int] = []
var selecting: bool = false
@onready var line_renderer: Line2D = get_node("line_renderer")
var currently_selecting_type: Globals.TILE_TYPE = Globals.TILE_TYPE.EMPTY

func _on_map_loader_map_loaded(loaded_map_size: Vector2i, loaded_map_data: Array[int]) -> void:
	map_size = loaded_map_size
	map_data = loaded_map_data

	var spacing_offset: Vector2 = Vector2.ZERO
	spacing_offset = tile_spacing * (map_size - Vector2i.ONE) / 2.0

	var offset: Vector2 = (map_size * tile_size) / 2.0 + spacing_offset
	# position itself in the center of the screen
	position = get_viewport_rect().size / 2.0
	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile_instance: ClickableTile = tile_prefab.instantiate()
			call_deferred("setup_tile", tile_instance, x, y, offset)
	
func setup_tile(tile_instance: ClickableTile, x: int, y: int, offset: Vector2) -> void:
	add_child(tile_instance)
	tile_instance.position = Vector2(
		x * (tile_size + tile_spacing),
		y * (tile_size + tile_spacing)
	) - offset + Vector2(tile_size / 2.0, tile_size / 2.0)
	var size = tile_instance.get_size();
	tile_instance.scale = Vector2(tile_size / size.x, tile_size / size.y)
	tile_instance.set_position_in_grid(Vector2i(x, y))
	tile_instance.set_grid(self)
	tile_instance.set_type(map_data[y + x * map_size.y])
	# connect signals
	tile_instance.tile_clicked.connect(on_tile_clicked)
	tile_instance.tile_hovered.connect(on_tile_hovered)
	clickable_tiles.append(tile_instance)

func _process(_delta: float) -> void:
	if selecting:
		if Input.is_action_just_released("left_click"):
			print("Selection ended, total selected tiles: ", selected_tiles.size())
			selecting = false
			# do something with selected tiles then clear the selection
			selected_tiles.clear()
			line_renderer.clear_points()

func get_tile(xy_idx: Vector2i) -> ClickableTile:
	if xy_idx.x < 0 or xy_idx.x >= map_size.x or xy_idx.y < 0 or xy_idx.y >= map_size.y:
		return null
	return clickable_tiles[xy_idx.y + xy_idx.x * map_size.y]

func on_tile_clicked(tile: ClickableTile):
	var xy_idx: Vector2i = tile.position_in_grid
	print("Tile clicked at position, callback from grid ", xy_idx)
	if selected_tiles.has(tile) == false:
		selected_tiles.append(tile)
		currently_selecting_type = tile.tile_type
		line_renderer.add_point(tile.position)
	selecting = true

func on_tile_hovered(tile: ClickableTile):
	if selecting:
		next_tile_selection_logic(tile)
		return
		# if selected_tiles.has(xy_idx) == false:
		# 	selected_tiles[xy_idx] = tile
		# 	line_renderer.add_point(tile.position)
		# dont handle otherwise

func next_tile_selection_logic(next_tile: ClickableTile):
	var prev_tile: ClickableTile = selected_tiles[-1]
	# if floor is > 1 then its more than 1 tile away
	if floor(prev_tile.position_in_grid.distance_to(next_tile.position_in_grid)) > 1:
		return
	
	if next_tile.tile_type == Globals.TILE_TYPE.OBSTACLE or next_tile.tile_type == Globals.TILE_TYPE.EMPTY:
		return

	if selected_tiles.has(next_tile):
		return
	
	if currently_selecting_type != next_tile.tile_type: # TODO : modify this logic later to allow for special tiles like changing possible selection type
		return

	selected_tiles.append(next_tile)
	line_renderer.add_point(next_tile.position)
