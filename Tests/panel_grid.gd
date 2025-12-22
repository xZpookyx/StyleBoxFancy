extends GridContainer

enum StyleBoxType {STYLEBOXFANCY, STYLEBOXFLAT}

@export var amount: int = 100
@export var test_stylebox: StyleBoxType
@export var styleboxflat: StyleBoxFlat
@export var styleboxfancy: StyleBoxFancy


func _ready():
	columns = int(sqrt(amount))

	for i in range(amount):
		var panel = Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if test_stylebox == StyleBoxType.STYLEBOXFLAT:
			panel.add_theme_stylebox_override("panel", styleboxflat)
		else:
			panel.add_theme_stylebox_override("panel", styleboxfancy)
		add_child(panel)

func _process(_delta):
	for child: Panel in get_children():
		child.queue_redraw()
