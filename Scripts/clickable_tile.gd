class_name ClickableTile extends Node2D

var grid: GridController = null
var position_in_grid: Vector2i = Vector2i.ZERO
var tile_type = Globals.TILE_TYPE.EMPTY

@onready var sprite_node: Sprite2D = $main_sprite

signal tile_clicked(tile: ClickableTile)
signal tile_hovered(tile: ClickableTile)

func get_size() -> Vector2:
	# get the size bg node texture
	var bg_node = $bg
	if bg_node is Sprite2D:
		var size = bg_node.texture.get_size()
		return size
	return Vector2.ONE

func _on_item_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("left_click"):
		print("Tile clicked at position: ", position_in_grid)
		tile_clicked.emit(self)
		return
	# TODO : right click handle?

func set_grid(grid_controller: GridController):
	grid = grid_controller

func set_position_in_grid(xy_idx: Vector2i):
	position_in_grid = xy_idx

func _on_item_area_mouse_entered():
	tile_hovered.emit(self)

# set the tile type. 
# This will also change the sprite texture based on the tile type.
func set_type(new_tile_type: int):
	var tile_type_enum = new_tile_type as Globals.TILE_TYPE
	match tile_type_enum as Globals.TILE_TYPE:
		Globals.TILE_TYPE.APPLE:
			sprite_node.texture = Globals.apple_sprite
		Globals.TILE_TYPE.PEAR:
			sprite_node.texture = Globals.pear_sprite
		Globals.TILE_TYPE.OBSTACLE:
			sprite_node.texture = Globals.obstacle_sprite
		Globals.TILE_TYPE.EMPTY:
			sprite_node.texture = null
	self.tile_type = tile_type_enum
