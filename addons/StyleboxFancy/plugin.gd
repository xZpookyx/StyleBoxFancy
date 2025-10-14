@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"StyleBoxFancy",
		"StyleBox",
		preload("res://addons/StyleboxFancy/StyleBoxFancy.gd"),
		preload("res://addons/StyleboxFancy/StyleBoxFancy.svg")
	)

	add_custom_type(
		"StyleBorder",
		"Resource",
		preload("res://addons/StyleboxFancy/StyleBorder.gd"),
		preload("res://addons/StyleboxFancy/StyleBorder.svg")
	)

func _exit_tree():
	remove_custom_type("StyleBoxFancy")
	remove_custom_type("StyleBorder")
