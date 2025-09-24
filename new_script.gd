@tool
class_name RPGStyleBox extends StyleBox

@export var center_texture: Texture2D
@export var style_box: StyleBoxFlat

func _init():
	print("I was initialized")

func _notification(what):
	print("RPG stylebox notified! ", what)

func _draw(to_canvas_item, rect):
	print("I was drawn!")
	#to_canvas_item.draw
	#render
	RenderingServer.canvas_item_add_texture_rect(to_canvas_item, rect, center_texture.get_rid())
	#style_box.draw(to_canvas_item, rect)
