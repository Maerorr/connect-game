class_name MapObjectsManager extends Node2D

var object_prefab: PackedScene = preload("res://Prefabs/tile_object.tscn")
#                 [x][y]
var objects: Array[TileObjectArray] = []
var map_size: Vector2i = Vector2i.ZERO
var map_data: Array[Globals.TILE_TYPE] = []

func _ready() -> void:
	print("map object manager Ready()")

func setup_map(loaded_map_data: Array[Globals.TILE_TYPE]):
	map_size = Globals.map_size
	map_data = loaded_map_data
	
	objects.resize(map_size.x)
	for x in map_size.x:
		var tile_col := TileObjectArray.new()
		tile_col.arr = []
		tile_col.arr.resize(map_size.y)
		objects[x] = tile_col

	var spacing_offset: Vector2 = Vector2.ZERO
	spacing_offset = Globals.tile_spacing * (map_size - Vector2i.ONE) / 2.0

	Globals.offset = (Globals.map_size * Globals.tile_size) / 2.0 + spacing_offset

	for x in range(map_size.x):
		for y in range(map_size.y):
			add_and_setup_object(Vector2i(x, y), map_data[y + x * map_size.y])

func add_and_setup_object(position_in_grid: Vector2i, tile_type: Globals.TILE_TYPE):
	var object_instance: ClickableTile = object_prefab.instantiate()
	objects[position_in_grid.x].arr[position_in_grid.y] = object_instance
	add_child(object_instance)
	object_instance.position = Globals.grid_position_world(position_in_grid.x, position_in_grid.y)
	object_instance.set_size(Globals.tile_size)
	object_instance.set_position_in_grid(position_in_grid)
	var map_idx = position_in_grid.y + position_in_grid.x * map_size.y
	object_instance.tile_type = map_data[map_idx] as Globals.TILE_TYPE
	# connect signals
	object_instance.tile_clicked.connect(tile_clicked)
	# object_instance.tile_hovered.connect(on_tile_hovered)

	if object_instance.tile_type == Globals.TILE_TYPE.CHARACTER:
		Globals.character.current_tile = object_instance
		print("Character tile found at position: ", object_instance.position_in_grid)

func get_tile_at(x: int, y: int) -> ClickableTile:
	return objects[x].arr[y]

func tile_clicked(tile: ClickableTile):
	# remove the tile
	var x := tile.position_in_grid.x
	var y := tile.position_in_grid.y
	objects[x].arr[y].tile_type = Globals.TILE_TYPE.EMPTY
	apply_gravity()

func apply_gravity():
	for x in range(objects.size()):
		await _cascade_column_once(x)

func _cascade_column_once(x: int) -> void:
	print("running cascade for X: ", x)
	var column := objects[x].arr
	var empty_spots_below := 0

	for y in range(column.size() - 1, -1, -1): # Bottom to top
		var tile := column[y]

		if tile.tile_type == Globals.TILE_TYPE.EMPTY:
			empty_spots_below += 1
		elif empty_spots_below > 0:
			print("moving tile on (", x, ", ", y, ")", " to y = ", y + empty_spots_below)
			await _move_tile(x, y, y + empty_spots_below)
			break


func _move_tile(x: int, from_y: int, to_y: int) -> void:
	var column := objects[x].arr

	var tile := column[from_y]
	var destination_tile := column[to_y]

	# Animate movement
	var start_pos = tile.global_position
	var end_pos := destination_tile.global_position
	var tween := get_tree().create_tween()
	var time = abs(from_y - to_y) * Globals.falling_speed
	print("moving tile to pos: ", end_pos)
	tween.tween_property(tile, "global_position", end_pos, time)

	# Swap ClickableTiles in array
	column[to_y] = tile
	column[from_y] = destination_tile
	# Update logical positions
	tile.set_position_in_grid(Vector2i(x, to_y))
	destination_tile.set_position_in_grid(Vector2i(x, from_y))
	destination_tile.global_position = start_pos

	await tween.finished

	_cascade_column_once(x)
	
	# Make the moved-from tile empty
	#destination_tile.tile_type = Globals.TILE_TYPE.EMPTY