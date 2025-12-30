@tool
extends EditorPlugin

const InspectorPlugin = preload("res://addons/StyleboxFancy/inspector/inspector_plugin.gd")
const StyleBoxFancyConverter = preload("res://addons/StyleboxFancy/styleboxfancy_converter.gd")

var converter = StyleBoxFancyConverter.new()
var inspector_plugin = InspectorPlugin.new()

func _enter_tree():
	add_inspector_plugin(inspector_plugin)
	add_resource_conversion_plugin(converter)

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
	remove_inspector_plugin(inspector_plugin)
	remove_resource_conversion_plugin(converter)
	remove_custom_type("StyleBoxFancy")
	remove_custom_type("StyleBorder")
