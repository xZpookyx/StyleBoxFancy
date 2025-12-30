extends EditorInspectorPlugin

const CornerEditor = preload("res://addons/StyleboxFancy/inspector/corner_editor.gd")

func _can_handle(object: Object):
	return object is StyleBoxFancy

#func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	#if name == "corner_detail":
		#add_property_editor("", CornerEditor.new())

func _parse_group(object: Object, group: String):
	if group == "Corners":

		add_property_editor_for_multiple_properties(
			"Corner Radius",
			[
				"corner_radius_top_left",
				"corner_radius_top_right",
				"corner_radius_bottom_left",
				"corner_radius_bottom_right",
			],
			CornerEditor.new()
		)
