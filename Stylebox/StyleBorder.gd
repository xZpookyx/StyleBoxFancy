@tool
extends Resource
class_name StyleBorder

@export_group("Border width", "width")
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_left: int:
	set(v):
		width_left = v
		emit_changed()
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_top: int:
	set(v):
		width_top = v
		emit_changed()
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_right: int:
	set(v):
		width_right = v
		emit_changed()
@export_range(0, 1, 1, "or_greater", "suffix:px") var width_bottom: int:
	set(v):
		width_bottom = v
		emit_changed()

@export var color: Color = Color(0.8, 0.8, 0.8):
	set(v):
		color = v
		emit_changed()
@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()
@export var ignore_stack: bool = false:
	set(v):
		ignore_stack = v
		emit_changed()
