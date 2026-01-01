@tool
extends VBoxContainer

## Used to simulate EditorHelpTooltip Node

@export var title_text: RichTextLabel
@export var content_text: RichTextLabel
@export_tool_button("Set theme") var button = set_themes

func set_themes():
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	title_text.add_theme_stylebox_override("normal", editor_theme.get_stylebox("normal", "EditorHelpBitTitle"))
	content_text.add_theme_stylebox_override("normal", editor_theme.get_stylebox("normal", "EditorHelpBitContent"))

func _ready():
	set_themes()
