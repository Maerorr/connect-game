class_name ClickableTile extends Node2D

var grid: GridController = null
var position_in_grid: Vector2i = Vector2i.ZERO
var size_px: int = 64
var tile_type = Globals.TILE_TYPE.EMPTY:
	set(new_type):
		match new_type as Globals.TILE_TYPE:
			Globals.TILE_TYPE.APPLE:
				sprite_node.texture = Globals.apple_sprite
			Globals.TILE_TYPE.PEAR:
				sprite_node.texture = Globals.pear_sprite
			Globals.TILE_TYPE.OBSTACLE:
				sprite_node.texture = Globals.obstacle_sprite
			Globals.TILE_TYPE.CHARACTER:
				sprite_node.texture = null # character is outside of the tile
			Globals.TILE_TYPE.EMPTY:
				sprite_node.texture = null
		tile_type = new_type

@onready var sprite_node: Sprite2D = $main_sprite

signal tile_clicked(tile: ClickableTile)
signal tile_hovered(tile: ClickableTile)

func set_size(new_size_px: int):
	size_px = new_size_px
	var new_scale = (size_px as float) / (get_texture_size() as float)
	print("new scale: ", new_scale)
	scale = Vector2(new_scale, new_scale)

# returns texture size as int because the tex is square
func get_texture_size() -> int:
	return sprite_node.texture.get_width()

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