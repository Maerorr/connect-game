extends Node

## ENUMS
enum TILE_TYPE {APPLE, PEAR, OBSTACLE, CHARACTER, EMPTY}

## REFS
@export var apple_sprite: Texture2D = preload("res://Sprites/apel.png")
@export var pear_sprite: Texture2D = preload("res://Sprites/pear.png")
@export var obstacle_sprite: Texture2D = preload("res://Sprites/stone.png")
@export var character_sprite: Texture2D = preload("res://Sprites/character.png")

## GLOBAL VARIABLES
@export var tile_size: int = 64
@export var tile_spacing: int = 10
@export var falling_speed: float = 0.15 # time for a tile to move one tile of distance
var map_size: Vector2i
var offset: Vector2
var character: Character = null


## HELPER FUNCTIONS
# returns chebyshev distance between two tiles (meaning, 8 nearest neighbours are considered as distance of 1)
func distance_between_chebyshev(tile_a: ClickableTile, tile_b: ClickableTile) -> int:
	# chebyshev distance
	return max(abs(tile_a.position_in_grid.x - tile_b.position_in_grid.x), abs(tile_a.position_in_grid.y - tile_b.position_in_grid.y))

func grid_position_world(x: int, y: int) -> Vector2:
	var full_offset := offset - Vector2(tile_size / 2.0, tile_size / 2.0)
	full_offset.y += map_size.y * (tile_size + tile_spacing)
	return Vector2(
		x * (tile_size + tile_spacing),
		y * (tile_size + tile_spacing)
	) - full_offset

func debug_tile_type_to_string(tile_type: TILE_TYPE) -> String:
	match tile_type:
		TILE_TYPE.APPLE:
			return "Ap"
		TILE_TYPE.PEAR:
			return "Pe"
		TILE_TYPE.OBSTACLE:
			return "Obs"
		TILE_TYPE.CHARACTER:
			return "Ch"
		TILE_TYPE.EMPTY:
			return "Em"
		_:
			return "--"
