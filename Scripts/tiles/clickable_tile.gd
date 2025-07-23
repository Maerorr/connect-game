class_name ClickableTile extends Node2D

var grid: GridController = null
var tex_size: int
var position_in_grid: Vector2i = Vector2i.ZERO
var size_px: int = 64

var _tile_type = Globals.TILE_TYPE.EMPTY
var tile_type:
	get:
		return _tile_type
	set(new_type):
		match new_type:
			Globals.TILE_TYPE.APPLE:
				sprite_node.texture = Globals.apple_sprite
			Globals.TILE_TYPE.PEAR:
				sprite_node.texture = Globals.pear_sprite
			Globals.TILE_TYPE.OBSTACLE:
				sprite_node.texture = Globals.obstacle_sprite
			Globals.TILE_TYPE.TYPE_CHANGE:
				sprite_node.texture = Globals.type_change_sprite
			Globals.TILE_TYPE.CHARACTER, Globals.TILE_TYPE.EMPTY:
				sprite_node.texture = null
		tex_size = sprite_node.texture.get_width() if sprite_node.texture else 0
		_tile_type = new_type

@onready var sprite_node: Sprite2D = $main_sprite
@onready var square_collider: RectangleShape2D = $item_area/square_area.shape as RectangleShape2D

signal tile_clicked(tile: ClickableTile)
signal tile_hovered(tile: ClickableTile)


func set_size(new_size_px: int):
	if sprite_node.texture == null:
		sprite_node.scale = Vector2(1, 1)
	size_px = new_size_px
	var new_scale = (size_px as float) / (tex_size as float)
	sprite_node.scale = Vector2(new_scale, new_scale)
	square_collider.size = Vector2(new_size_px, new_size_px)


# returns texture size as int because the tex is square
func get_texture_size() -> int:
	return sprite_node.texture.get_width()


func _on_item_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("left_click"):
		tile_clicked.emit(self)
		return
	# TODO : right click handle?


func set_grid(grid_controller: GridController):
	grid = grid_controller


func set_position_in_grid(xy_idx: Vector2i):
	position_in_grid = xy_idx


func _on_item_area_mouse_entered():
	tile_hovered.emit(self)


func on_tile_selected():
	print("Tile selected: ", position_in_grid, " type: ", tile_type)
	# This function can be overridden by child classes to handle tile selection logic, like special tiles
	# changing the selection type
	pass
