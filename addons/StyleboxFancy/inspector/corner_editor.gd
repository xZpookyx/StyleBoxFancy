extends EditorProperty

const CORNER_EDITOR_CONTAINER = preload("res://addons/StyleboxFancy/inspector/corner editor container/corner_editor_container.tscn")

var controls: CornerEditorContainer = CORNER_EDITOR_CONTAINER.instantiate()
var ratios: Vector4 = Vector4.ONE
var updating: bool = false

func _update_ratio() -> void:
	pass

func _on_property_changed(value: float, property: StringName):
	if controls.is_linked():
		pass
	else:
		emit_changed(property, value)

func _init():
	draw_background = false
	add_child(controls)
	set_bottom_editor(controls)
	add_focusable(controls)
	controls.property_changed.connect(_on_property_changed)
	controls.linked_corners.connect(_update_ratio)

func _update_property():
	print(get_edited_object())
	print(get_edited_property())
	#var new_value = get_edited_object()[get_edited_property()]
	#if (new_value == current_value):
		#return
#
	## Update the control with the new value.
	#updating = true
	#current_value = new_value
	#refresh_control_text()
	#updating = false
