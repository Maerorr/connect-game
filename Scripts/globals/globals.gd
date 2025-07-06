extends Node

## ENUMS
enum TILE_TYPE {APPLE, PEAR, OBSTACLE, CHARACTER, EMPTY}

## REFS
@export var apple_sprite: Texture2D = preload("res://Sprites/apel.png")
@export var pear_sprite: Texture2D = preload("res://Sprites/pear.png")
@export var obstacle_sprite: Texture2D = preload("res://Sprites/stone.png")
@export var character_sprite: Texture2D = preload("res://Sprites/character.png")

## HELPER FUNCTIONS
# returns chebyshev distance between two tiles (meaning, 8 nearest neighbours are considered as distance of 1)
func distance_between(tile_a: ClickableTile, tile_b: ClickableTile) -> int:
	# chebyshev distance
	return max(abs(tile_a.position_in_grid.x - tile_b.position_in_grid.x), abs(tile_a.position_in_grid.y - tile_b.position_in_grid.y))
