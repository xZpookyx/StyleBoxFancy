@tool
extends Resource
class_name StyleBorder

## Sets the border color. Modulates [param texture] if it is set.
@export var color: Color = Color(0.8, 0.8, 0.8):
	set(v):
		color = v
		emit_changed()

## If [code]true[/code], the border will fade into the background color.
@export var blend: bool:
	set(v):
		blend = v
		emit_changed()

## Sets the border texture.
@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()

## If [code]true[/code], the border will ignore the entire border stack and
## draw as if it was on top of it.
@export var ignore_stack: bool = false:
	set(v):
		ignore_stack = v
		emit_changed()

#region Border width
@export_group("Border width", "width")
## Border width for the left edge.
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_left: int:
	set(v):
		width_left = v
		emit_changed()

## Border width for the top edge.
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_top: int:
	set(v):
		width_top = v
		emit_changed()

## Border width for the right edge.
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_right: int:
	set(v):
		width_right = v
		emit_changed()

## Border width for the bottom edge.
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_bottom: int:
	set(v):
		width_bottom = v
		emit_changed()
#endregion

#region Border inset
@export_group("Inset", "inset")

## Moves the left edge inwards leaving an empty area behind, or outwards if it is set with
## a negative value.
@export var inset_left: int:
	set(v):
		inset_left = v
		emit_changed()

## Moves the top edge inwards leaving an empty area behind, or outwards if it is set with
## a negative value.
@export var inset_top: int:
	set(v):
		inset_top = v
		emit_changed()

## Moves the right edge inwards leaving an empty area behind, or outwards if it is set with
## a negative value.
@export var inset_right: int:
	set(v):
		inset_right = v
		emit_changed()

## Moves the bottom edge inwards leaving an empty area behind, or outwards if it is set with
## a negative value.
@export var inset_bottom: int:
	set(v):
		inset_bottom = v
		emit_changed()
#endregion

func get_width(side: Side) -> int:
	match side:
		SIDE_LEFT: return width_left
		SIDE_TOP: return width_top
		SIDE_RIGHT: return width_right
		SIDE_BOTTOM: return width_bottom
	return 0

func get_width_min() -> int:
	return min(width_left, width_top, width_right, width_bottom)

func set_width(side: Side, width: int) -> void:
	match side:
		SIDE_LEFT: width_left = width
		SIDE_TOP: width_top = width
		SIDE_RIGHT: width_right = width
		SIDE_BOTTOM: width_bottom = width

func set_width_all(width: int) -> void:
	width_left = width
	width_top = width
	width_right = width
	width_bottom = width
