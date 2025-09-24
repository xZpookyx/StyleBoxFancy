extends GridContainer


func _ready():
	var t = create_tween().set_loops()
	t.tween_property(self, "size:x", 600.0, 1)
	t.tween_property(self, "size:x", 536.0, 1)
