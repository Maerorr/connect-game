@tool
extends Node2D

# Expose this to the editor so it can be set manually
@export var grid_controller_path: NodePath

var grid_controller: GridController = null

func _ready() -> void:
    _fetch_grid_controller()
    queue_redraw()

# Called in the editor and at runtime to keep visuals updated
func _process(_delta: float) -> void:
    queue_redraw()

func _fetch_grid_controller():
    if grid_controller_path != null and has_node(grid_controller_path):
        grid_controller = get_node(grid_controller_path) as GridController
    else:
        grid_controller = null

func _draw() -> void:
    if grid_controller == null:
        _fetch_grid_controller()
        print("GridController not found or not set.")
        return

    # Access exported properties from GridController
    var map_size := grid_controller.get("map_size") as Vector2i
    var tile_size := grid_controller.tile_size
    var tile_spacing := grid_controller.tile_spacing

    var bounds_x := Vector2(
        map_size.x * tile_size + (map_size.x - 1) * tile_spacing,
        0
    )
    var bounds_y := Vector2(
        0,
        map_size.y * tile_size + (map_size.y - 1) * tile_spacing
    )

    var total_bounds := Vector2(-100, 100)
    var rect_pos := -bounds_x / 2.0
    print("Drawing grid bounds at position: ", rect_pos, " with size: ", total_bounds)
    draw_rect(Rect2(rect_pos, total_bounds), Color(1, 1, 1, 0.5), false)
