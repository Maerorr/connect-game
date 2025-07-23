extends Node

signal map_loaded(loaded_map_size: Vector2i, loaded_map_data: Array[int])

@export var map_file_path: String = "res://Maps/test_map.txt"
var map_size: Vector2i = Vector2i.ZERO
var map_data: Array[Globals.TILE_TYPE] = []

func _ready():
	call_deferred("load_map_from_txt")
	

func load_map_from_txt():
	print("load map from file")
	var file = FileAccess.open("res://Maps/test_map.txt", FileAccess.READ)
	if file == null:
		print("Failed to open map file.")
		return
	# get the map size from the file
	map_size = Vector2i.ZERO
	while file.eof_reached() == false:
		var line = file.get_line().strip_edges()
		if line.length() != 0:
			var space_split_line = line.split(" ")
			if map_size.x == 0:
				map_size.x = space_split_line.size()
			map_size.y += 1
			for c in space_split_line:
				# TODO : make this a function
				match c:
					'O':
						map_data.append(Globals.TILE_TYPE.OBSTACLE)
					'A':
						map_data.append(Globals.TILE_TYPE.APPLE)
					'P':
						map_data.append(Globals.TILE_TYPE.PEAR)
					'E':
						map_data.append(Globals.TILE_TYPE.EMPTY)
					'C':
						map_data.append(Globals.TILE_TYPE.CHARACTER)
					'S':
						map_data.append(Globals.TILE_TYPE.TYPE_CHANGE)
					_:
						print("Unknown tile type: ", c)
	file.close()
	map_loaded.emit(map_size, map_data)
