class_name SelectionTypeChangingTile extends ClickableTile

@export var new_allowed_types: Array[Globals.TILE_TYPE] = []

func on_tile_selected():
	print("CHANGING TILE TYPE OF SELECTION TILE")
	grid.trigger_change_type(new_allowed_types)
