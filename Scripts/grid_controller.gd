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
var character_tile: ClickableTile = null

# Paths to other nodes
@export var character_path: NodePath
@export var line_renderer_path: NodePath
@export var map_objects_manager_path: NodePath
@export var selection_controller_path: NodePath

@onready var character: Character = get_node(character_path)
@onready var line_renderer: Line2D = get_node(line_renderer_path)
@onready var map_object_manager: MapObjectsManager = get_node(map_objects_manager_path)
@onready var selection_controller: SelectionController = get_node(selection_controller_path)
var currently_selecting_type: Globals.TILE_TYPE = Globals.TILE_TYPE.EMPTY


func _ready():
	# position itself in the center of the screen
	position = Vector2.ZERO
	global_position = get_viewport_rect().size / 2.0
	Globals.character = character
	Globals.grid = self


func _process(_delta: float) -> void:
	pass


func _on_map_loader_map_loaded(loaded_map_size: Vector2i, loaded_map_data: Array[Globals.TILE_TYPE]) -> void:
	Globals.map_size = loaded_map_size
	map_data = loaded_map_data
	setup_tiles(loaded_map_data)
	

func setup_tiles(loaded_map_data: Array[Globals.TILE_TYPE]):
	map_object_manager.setup_map(loaded_map_data)


func get_tile(xy_idx: Vector2i) -> ClickableTile:
	if xy_idx.x < 0 or xy_idx.x >= map_size.x or xy_idx.y < 0 or xy_idx.y >= map_size.y:
		return null
	return clickable_tiles[xy_idx.y + xy_idx.x * map_size.y]


func trigger_change_type(new_types: Array[Globals.TILE_TYPE]):
	if not selection_controller.selecting:
		return
	selection_controller.changing_types = true
	selection_controller.allowed_change_types = new_types