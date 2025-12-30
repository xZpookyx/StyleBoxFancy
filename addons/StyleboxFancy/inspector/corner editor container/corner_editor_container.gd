@tool
extends VBoxContainer
class_name CornerEditorContainer

signal linked_corners
signal property_changed(value: float, property: StringName)

const CORNER_STRINGNAMES: Array[StringName] = [
	"corner_radius_top_left",
	"corner_radius_top_right",
	"corner_radius_bottom_left",
	"corner_radius_bottom_right",
	"corner_curvature_top_left",
	"corner_curvature_top_right",
	"corner_curvature_bottom_left",
	"corner_curvature_bottom_right",
]

@export var link_button: Button
@export var properties_dict: Dictionary[EditorSpinSlider, StringName]

# NOTE: Accidentaly managed to instance a EditorSpinSlider inside the scene
# so I don't need to generate them anymore, but I'll leave this just in case
# it breaks
func _get_radius_spinbox() -> EditorSpinSlider:
	var editor_spinbox = EditorSpinSlider.new()
	editor_spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor_spinbox.min_value = 0
	editor_spinbox.step = 1
	editor_spinbox.allow_greater = true
	editor_spinbox.editing_integer = true
	editor_spinbox.suffix = "px"
	return editor_spinbox


func _property_changed(value: float, property: StringName):
	property_changed.emit(value, property)


func _ready():
	for spinbox: EditorSpinSlider in properties_dict:
		if not spinbox.value_changed.is_connected(_property_changed):
			spinbox.value_changed.connect(_property_changed.bind(properties_dict[spinbox]))


func _on_link_button_pressed() -> void:
	linked_corners.emit()


func _on_radius_tab_button_pressed() -> void:
	get_tree().call_group("Radius spinboxes", "show")
	get_tree().call_group("Curvature spinboxes", "hide")


func _on_curvature_tab_button_pressed() -> void:
	get_tree().call_group("Radius spinboxes", "hide")
	get_tree().call_group("Curvature spinboxes", "show")


func is_linked() -> bool:
	if link_button == null:
		return false
	return link_button.button_pressed


func set_property_value(value: int, corner: StringName) -> void:
	var spinbox: EditorSpinSlider = properties_dict.find_key(corner)
	if spinbox != null:
		spinbox.set_value_no_signal(value)
