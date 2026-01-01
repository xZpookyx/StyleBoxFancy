@tool
extends Button

@export var tooltip: Control

func _make_custom_tooltip(_for_text):
	if tooltip:
		var new_tooltip = tooltip.duplicate()
		new_tooltip.show()
		return new_tooltip
