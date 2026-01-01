@tool
extends VBoxContainer
class_name CornerEditorContainer

signal linked_corners
signal property_changed(value: float, property: StringName)
signal property_reverted(property: StringName)
signal multi_property_changed(values: Array, properties: Array[StringName])
signal multi_property_reverted(properties: Array[StringName])

enum CornerStringNames {
	radius_tl,
	radius_tr,
	radius_bl,
	radius_br,
	curvature_tl,
	curvature_tr,
	curvature_bl,
	curvature_br,
}

const CORNER_STRINGNAMES: Array[StringName] = [
	&"corner_radius_top_left",
	&"corner_radius_top_right",
	&"corner_radius_bottom_left",
	&"corner_radius_bottom_right",
	&"corner_curvature_top_left",
	&"corner_curvature_top_right",
	&"corner_curvature_bottom_left",
	&"corner_curvature_bottom_right",
]

@export var panel: PanelContainer
@export var radius_controls: Control
@export var curvature_controls: Control
@export var link_button: Button
@export var properties_dict: Dictionary[Node, CornerStringNames]

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

func _get_edited_property_from_node(node: Node) -> StringName:
	if node in properties_dict:
		return CORNER_STRINGNAMES[properties_dict[node]]
	return ""

func _property_changed(value: float, property: StringName):
	if link_button.button_pressed:
		var values: Array
		values.resize(4)
		values.fill(value)

		if CORNER_STRINGNAMES.find(property) < 4:
			var properties: Array[StringName]
			properties.assign(CORNER_STRINGNAMES.slice(0, 4))
			multi_property_changed.emit(values, properties)
		else:
			var properties: Array[StringName]
			properties.assign(CORNER_STRINGNAMES.slice(4, 8))
			multi_property_changed.emit(values, properties)
	else:
		property_changed.emit(value, property)

func _property_revert(property: StringName) -> void:
	if link_button.button_pressed:
		# NOTE: Only corner radius have a revert button
		var properties: Array[StringName]
		properties.assign(CORNER_STRINGNAMES.slice(0, 4))
		multi_property_reverted.emit(properties)
	else:
		property_reverted.emit(property)

func _ready():
	_on_radius_tab_button_pressed()

	# Set themes
	var editor_theme = EditorInterface.get_editor_theme()
	panel.add_theme_stylebox_override("panel", editor_theme.get_stylebox("child_bg", "EditorProperty"))

	# Connect signals
	for node: Node in properties_dict:
		var property = _get_edited_property_from_node(node)
		if node is EditorSpinSlider:
			if not node.value_changed.is_connected(_property_changed):
				node.value_changed.connect(_property_changed.bind(property))

		elif node is Button:
			if not node.pressed.is_connected(_property_revert):
				node.pressed.connect(_property_revert.bind(property))


func _on_link_button_pressed() -> void:
	linked_corners.emit()

func _on_radius_tab_button_pressed() -> void:
	radius_controls.show()
	curvature_controls.hide()

func _on_curvature_tab_button_pressed() -> void:
	radius_controls.hide()
	curvature_controls.show()


func is_linked() -> bool:
	if link_button == null:
		return false
	return link_button.button_pressed

func set_all_properties(stylebox: StyleBoxFancy) -> void:
	if stylebox == null: return

	for node: Node in properties_dict:
		var property = _get_edited_property_from_node(node)
		if node is EditorSpinSlider:
			node.set_value_no_signal(stylebox.get(property))
		if node is Button:
			node.disabled = !stylebox.property_can_revert(property)
