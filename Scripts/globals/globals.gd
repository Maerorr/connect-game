extends Node

## ENUMS
enum TILE_TYPE {APPLE, PEAR, OBSTACLE, EMPTY}

## REFS
@export var apple_sprite: Texture2D = preload("res://Sprites/apel.png")
@export var pear_sprite: Texture2D = preload("res://Sprites/pear.png")
@export var obstacle_sprite: Texture2D = preload("res://Sprites/stone.png")