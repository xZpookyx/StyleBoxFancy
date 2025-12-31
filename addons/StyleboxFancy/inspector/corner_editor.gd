extends EditorProperty

const CORNER_EDITOR_CONTAINER = preload("res://addons/StyleboxFancy/inspector/corner editor container/corner_editor_container.tscn")

var controls: CornerEditorContainer = CORNER_EDITOR_CONTAINER.instantiate()


func _on_property_changed(value: float, property: StringName) -> void:
	emit_changed(property, value, "", true)

func _on_property_reverted(property: StringName) -> void:
	emit_changed(property, get_edited_object().property_get_revert(property))

func _on_multi_property_changed(values: Array, properties: Array[StringName]) -> void:
	# Fun fact: you actually have to send 3 arguments, the third one is "changing"
	multiple_properties_changed.emit(properties, values, true)

func _on_multi_property_reverted(properties: Array[StringName]) -> void:
	var values: Array[float]
	for property in properties:
		values.append(get_edited_object().property_get_revert(property))
	multiple_properties_changed.emit(properties, values, false)

func _init():
	draw_background = false
	add_child(controls)
	set_bottom_editor(controls)
	add_focusable(controls)
	controls.property_changed.connect(_on_property_changed)
	controls.property_reverted.connect(_on_property_reverted)
	controls.multi_property_changed.connect(_on_multi_property_changed)
	controls.multi_property_reverted.connect(_on_multi_property_reverted)

func _ready():
	controls.set_all_properties(get_edited_object())

func _update_property():
	controls.set_all_properties(get_edited_object())
