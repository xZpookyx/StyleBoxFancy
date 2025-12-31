@tool
extends Button
class_name RevertButton

func set_can_revert(can_revert: bool) -> void:
	disabled = !can_revert
	if can_revert:
		self_modulate = EditorInterface.get_editor_theme().get_color("icon_focus_color", "Editor")
	else:
		self_modulate = Color.WHITE
