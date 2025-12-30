@tool
extends Button

func _ready():
	button_pressed = false
	icon = get_theme_icon("Unlinked", "EditorIcons")

func _on_toggled(toggled_on: bool):
	if toggled_on:
		icon = get_theme_icon("Instance", "EditorIcons")
	else:
		icon = get_theme_icon("Unlinked", "EditorIcons")
