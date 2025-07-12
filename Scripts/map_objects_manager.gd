class_name MapObjectsManager extends Node2D

var object_prefab: PackedScene = preload("res://Prefabs/tile_object.tscn")
#                 [x][y]
var objects: Array[TileObjectArray] = []
var map_size: Vector2i = Vector2i.ZERO
var map_data: Array[Globals.TILE_TYPE] = []

var selection_controller: SelectionController = null

var cooldown: float = 1.0
var cooldown_timer: float = 0.0

func _ready() -> void:
	selection_controller = get_parent().get_node("selection_controller")
	call_deferred("setup_connections")


func setup_connections():
	Globals.character.whole_move_completed.connect(on_character_whole_move_completed)
	Globals.character.move_completed.connect(on_character_move_completed)


func setup_map(loaded_map_data: Array[Globals.TILE_TYPE]):
	map_size = Globals.map_size
	map_data = loaded_map_data
	
	objects.resize(map_size.x)
	for x in map_size.x:
		var tile_col := TileObjectArray.new()
		tile_col.arr = []
		tile_col.arr.resize(map_size.y * 2) # double the size for falling tiles not displayed initially
		objects[x] = tile_col

	var spacing_offset: Vector2 = Vector2.ZERO
	spacing_offset = Globals.tile_spacing * (map_size - Vector2i.ONE) / 2.0

	Globals.offset = (Globals.map_size * Globals.tile_size) / 2.0 + spacing_offset

	# setup the initial, invisible tiles
	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile_type: Globals.TILE_TYPE;
			var apple_chance := 0.45
			var pear_chance := 0.45
			var obstacle_chance := 0.1
			var rand_val := randf()
			if rand_val < apple_chance:
				tile_type = Globals.TILE_TYPE.APPLE
			elif rand_val < apple_chance + pear_chance:
				tile_type = Globals.TILE_TYPE.PEAR
			elif rand_val < apple_chance + pear_chance + obstacle_chance:
				tile_type = Globals.TILE_TYPE.OBSTACLE
			else:
				tile_type = Globals.TILE_TYPE.EMPTY

			add_and_setup_object(Vector2i(x, y), tile_type)

	# setup the actual map
	for x in range(map_size.x):
		for y in range(map_size.y):
			var map_y_idx = y + map_size.y
			add_and_setup_object(Vector2i(x, map_y_idx), map_data[y + x * map_size.y])


func add_and_setup_object(position_in_grid: Vector2i, tile_type: Globals.TILE_TYPE):
	var object_instance: ClickableTile = object_prefab.instantiate()
	objects[position_in_grid.x].arr[position_in_grid.y] = object_instance
	add_child(object_instance)
	object_instance.position = Globals.grid_position_world(position_in_grid.x, position_in_grid.y)
	object_instance.set_size(Globals.tile_size)
	object_instance.set_position_in_grid(position_in_grid)
	object_instance.tile_type = tile_type
	# connect signals

	object_instance.tile_clicked.connect(selection_controller.on_tile_clicked)
	object_instance.tile_hovered.connect(selection_controller.on_tile_hovered)

	if object_instance.tile_type == Globals.TILE_TYPE.CHARACTER:
		Globals.character.current_tile = object_instance
		print("Character tile found at position: ", object_instance.position_in_grid)

func get_tile_at(x: int, y: int) -> ClickableTile:
	return objects[x].arr[y]


func on_character_whole_move_completed() -> void:
	var pos_in_grid = Globals.character.current_tile.position_in_grid
	var prev_pos_in_grid = Globals.character.previous_tile.position_in_grid
	get_tile_at(prev_pos_in_grid.x, prev_pos_in_grid.y).tile_type = Globals.TILE_TYPE.EMPTY
	get_tile_at(pos_in_grid.x, pos_in_grid.y).tile_type = Globals.TILE_TYPE.CHARACTER
	apply_gravity()


func on_character_move_completed(current_tile: ClickableTile) -> void:
	var pos_in_grid = current_tile.position_in_grid
	var prev_pos_in_grid = Globals.character.previous_tile.position_in_grid
	get_tile_at(pos_in_grid.x, pos_in_grid.y).tile_type = Globals.TILE_TYPE.CHARACTER
	get_tile_at(prev_pos_in_grid.x, prev_pos_in_grid.y).tile_type = Globals.TILE_TYPE.EMPTY


func apply_gravity():
	var tweens := []
	for x in range(objects.size()):
		var column := objects[x].arr
		var empty_spots_below := 0
		for y in range(column.size() - 1, -1, -1): # Bottom to top
			var tile := column[y]

			if tile.tile_type == Globals.TILE_TYPE.EMPTY:
				empty_spots_below += 1
				if column[y - 1].tile_type == Globals.TILE_TYPE.CHARACTER:
					empty_spots_below += 1
			elif empty_spots_below > 0 and tile.tile_type != Globals.TILE_TYPE.CHARACTER:
				var t = _move_tile(x, y, y + empty_spots_below)
				print("created a tween")
				if t != null:
					print("tween was VALID")
					tweens.append(t)
				break

	if tweens.size() > 0:
		#print("awaiting ", tweens.size(), " tweens to finish")
		var finished = []
		for t in tweens:
			finished.append(t.finished)

		var i := 0
		for f in finished:
			if tweens[i].is_valid():
				print("Awaiting tween ", i, " of ", tweens.size())
				await f
			i += 1
		apply_gravity()


func _move_tile(x: int, from_y: int, to_y: int) -> Tween:
	var column := objects[x].arr

	var tile := column[from_y]
	var destination_tile := column[to_y]
	# Ensure the destination tile is empty
	if destination_tile.tile_type != Globals.TILE_TYPE.EMPTY:
		return null
	if tile.tile_type == Globals.TILE_TYPE.EMPTY or tile.tile_type == Globals.TILE_TYPE.CHARACTER:
		return null

	# Animate movement
	var start_pos = tile.global_position
	var end_pos := destination_tile.global_position
	var tween := get_tree().create_tween()
	var time = abs(from_y - to_y) * Globals.falling_speed
	print("tween time: ", time)
	tween.set_trans(tween.TRANS_CUBIC)
	tween.tween_property(tile, "global_position", end_pos, time)
	
	# Swap ClickableTiles in array
	column[to_y] = tile
	column[from_y] = destination_tile
	# Update logical positions
	tile.set_position_in_grid(Vector2i(x, to_y))
	destination_tile.set_position_in_grid(Vector2i(x, from_y))
	destination_tile.global_position = start_pos

	return tween

func _draw() -> void:
	# debug draw a grid of letters depicting the tile types
	for x in range(map_size.x):
		for y in range(map_size.y * 2):
			var tile := objects[x].arr[y]
			var pos := tile.global_position / 2.0 + Vector2(100, -100)
			var text := Globals.debug_tile_type_to_string(tile.tile_type)
			draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER)
