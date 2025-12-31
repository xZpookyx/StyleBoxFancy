extends EditorProperty

const CORNER_EDITOR_CONTAINER = preload("res://addons/StyleboxFancy/inspector/corner editor container/corner_editor_container.tscn")

var controls: CornerEditorContainer = CORNER_EDITOR_CONTAINER.instantiate()
var ratios: Vector4 = Vector4.ONE

func _update_ratio() -> void:
	pass

func _on_property_changed(value: float, property: StringName) -> void:
	if controls.is_linked():
		pass
	else:
		emit_changed(property, value, "", true)

func _on_property_reverted(property: StringName) -> void:
	if controls.is_linked():
		pass
	else:
		emit_changed(property, get_edited_object().property_get_revert(property))

func _init():
	draw_background = false
	add_child(controls)
	set_bottom_editor(controls)
	add_focusable(controls)
	controls.property_changed.connect(_on_property_changed)
	controls.property_reverted.connect(_on_property_reverted)
	controls.linked_corners.connect(_update_ratio)

func _ready():
	controls.set_all_properties(get_edited_object())

func _update_property():
	controls.set_all_properties(get_edited_object())
