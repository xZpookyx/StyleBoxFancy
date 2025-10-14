@tool
extends Resource
class_name StyleBorder

@export var color: Color = Color(0.8, 0.8, 0.8):
	set(v):
		color = v
		emit_changed()
@export var blend: bool:
	set(v):
		blend = v
		emit_changed()
@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()
@export var ignore_stack: bool = false:
	set(v):
		ignore_stack = v
		emit_changed()

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

@export_group("Inset", "inset")
@export var inset_left: int:
	set(v):
		inset_left = v
		emit_changed()
@export var inset_top: int:
	set(v):
		inset_top = v
		emit_changed()
@export var inset_right: int:
	set(v):
		inset_right = v
		emit_changed()
@export var inset_bottom: int:
	set(v):
		inset_bottom = v
		emit_changed()

#@export_group("Texture")
#@export var region_rect: Rect2:
	#set(v):
		#region_rect = v
		#emit_changed()
#
#@export_subgroup("Patch margin", "patch_margin")
#@export var patch_margin_left: int:
	#set(v):
		#patch_margin_left = v
		#emit_changed()
#@export var patch_margin_top: int:
	#set(v):
		#patch_margin_top = v
		#emit_changed()
#@export var patch_margin_right: int:
	#set(v):
		#patch_margin_right = v
		#emit_changed()
#@export var patch_margin_bottom: int:
	#set(v):
		#patch_margin_bottom = v
		#emit_changed()
#
#@export_subgroup("Axis strech", "axis_stretch")
#@export var axis_stretch_horizontal: RenderingServer.NinePatchAxisMode:
	#set(v):
		#axis_stretch_horizontal = v
		#emit_changed()
#@export var axis_stretch_vertical: RenderingServer.NinePatchAxisMode:
	#set(v):
		#axis_stretch_vertical = v
		#emit_changed()
