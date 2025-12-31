@tool
extends Button

@export var popup_menu: PopupMenu
@export var curvature_slider: EditorSpinSlider

func _ready():
	popup_menu.clear()
	for preset: String in StyleBoxFancy.Curvatures:
		popup_menu.add_item(preset)

func _on_pressed():
	var mouse_position: Vector2 = DisplayServer.mouse_get_position()
	popup_menu.popup(Rect2(mouse_position, popup_menu.size))

func _on_popup_index_pressed(index: int):
	var preset: String = popup_menu.get_item_text(index)
	curvature_slider.value = StyleBoxFancy.Curvatures[preset]
