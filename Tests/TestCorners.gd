@tool
extends StyleBox
class_name NewCornerStylebox


const CURVATURES: Dictionary[String, float] = {
	"Round": 1,
	"Squircle": 2,
	"Bevel": 0,
	"Scoop": -1,
	"Reverse squircle": -2,
	"Notch": -10,
}

@export_enum("Custom", "Round", "Squircle", "Bevel", "Scoop", "Reverse squircle", "Notch")
var corner_shape: String = "Round":
	set(v):
		corner_shape = v
		corner_curvature = CURVATURES.get(corner_shape, corner_curvature)
		notify_property_list_changed()

@export var corner_radius: int = 10:
	set(v):
		corner_radius = v
		emit_changed()
@export_range(-4, 10, 0.005) var corner_curvature: float = 1:
	set(v):
		corner_curvature = v
		emit_changed()
@export var detail: int = 4:
	set(v):
		detail = v
		emit_changed()

var corner_geometry: Array[PackedVector2Array]

func _superellipse_quadrant(exponent: float, detail: int) -> PackedVector2Array:
	var n = pow(2, abs(exponent))
	var points: PackedVector2Array

	const HALF_PI = PI * 0.5
	for i in range(detail + 1):
		var theta = HALF_PI * i / detail

		var cx = cos(theta)
		var cy = sin(theta)

		var x = pow(cx, 2.0 / n)
		var y = pow(cy, 2.0 / n)
		points.append(Vector2(x, y))
	return points

func _transform_points(points: PackedVector2Array, tx: float, ty: float) -> PackedVector2Array:
	var out: PackedVector2Array
	for p in points:
		out.append(Vector2(p.x * tx, p.y * ty))
	return out

func _generate_corner_geometry():
	var transforms: PackedVector2Array = [
		Vector2(-1, -1),
		Vector2(1, -1),
		Vector2(1, 1),
		Vector2(-1, 1),
	]

	var geometry_array: Array[PackedVector2Array]
	for corner_idx in range(4):
		var corner_geometry: PackedVector2Array
		var quadrant_points = _superellipse_quadrant(corner_curvature, detail)

		var sign = sign(corner_curvature)
		if corner_curvature == 0:
			sign = -1

		quadrant_points = _transform_points(
			quadrant_points,
			transforms[corner_idx].x * sign,
			transforms[corner_idx].y * sign,
		)

		if corner_curvature > 0:
			if corner_idx % 2 == 1:
				quadrant_points.reverse()

			for point in quadrant_points:
				corner_geometry.append(point - transforms[corner_idx] * sign)
		else:
			if corner_idx % 2 == 0:
				quadrant_points.reverse()
			corner_geometry = quadrant_points
		geometry_array.append(corner_geometry)

	corner_geometry = geometry_array


func _get_rounded_rect(rect: Rect2, corner_radius: Vector4):
	var corners: PackedVector2Array = [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]

	var points: PackedVector2Array
	for corner_idx in range(4):
		for point in corner_geometry[corner_idx]:
			points.append(corners[corner_idx] + point * corner_radius[corner_idx])
	return points



func _draw(to_canvas_item, rect):
	#RenderingServer.canvas_item_add_rect(to_canvas_item, rect, Color.AQUA)
	#var points = superellipse(corner_curvature, detail, 0)
	_generate_corner_geometry()
	var rounded_rect = _get_rounded_rect(rect, Vector4.ONE * corner_radius)
	RenderingServer.canvas_item_add_polyline(to_canvas_item, rounded_rect, [Color.GOLD])


func _validate_property(property: Dictionary):
	if property.name == "corner_curvature" and corner_shape != "Custom":
		property.usage |= PROPERTY_USAGE_READ_ONLY
