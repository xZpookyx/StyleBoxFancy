@tool
class_name StyleBoxPlus
extends StyleBox

@export var color: Color = Color(0.6, 0.6, 0.6):
	set(v):
		color = v
		emit_changed()
@export var draw_center: bool = true:
	set(v):
		draw_center = v
		emit_changed()
@export var borders: Array[StyleBorder]:
	set(v):
		borders = v
		for border in borders:
			if not border: continue
			if not border.changed.is_connected(emit_changed):
				border.changed.connect(emit_changed)
		emit_changed()

# Corners
@export_range(1, 20, 1) var corner_detail: int = 8:
	set(v):
		corner_detail = v
		emit_changed()
@export_group("Corner radius", "corner_radius")
@export_range(0, 1, 1, "or_greater") var corner_radius_top_left: int:
	set(v):
		corner_radius_top_left = v
		emit_changed()
@export_range(0, 1, 1, "or_greater") var corner_radius_top_right: int:
	set(v):
		corner_radius_top_right = v
		emit_changed()
@export_range(0, 1, 1, "or_greater") var corner_radius_bottom_right: int:
	set(v):
		corner_radius_bottom_right = v
		emit_changed()
@export_range(0, 1, 1, "or_greater") var corner_radius_bottom_left: int:
	set(v):
		corner_radius_bottom_left = v
		emit_changed()

func _get_rounded_polygon(rect: Rect2, corner_radius: PackedInt32Array, corner_detail: int):
	var polygon: PackedVector2Array

	var corners: PackedVector2Array = [
		rect.position,
		rect.position + Vector2(rect.size.x, 0),
		rect.end,
		rect.position + Vector2(0, rect.size.y)
	]

	var offsets: PackedVector2Array = [
		Vector2(corner_radius[0], corner_radius[0]),
		Vector2(-corner_radius[1], corner_radius[1]),
		Vector2(-corner_radius[2], -corner_radius[2]),
		Vector2(corner_radius[3], -corner_radius[3])
	]


	for corner_idx in range(corners.size()):
		if corner_radius[corner_idx] == 0:
			polygon.append(corners[corner_idx])
			continue

		var quarter_arc = PI / 2.0
		for detail_step in range(corner_detail + 1):
			var angle_step = PI + quarter_arc * corner_idx
			angle_step += quarter_arc * detail_step / corner_detail
			var x = cos(angle_step) * corner_radius[corner_idx]
			var y = sin(angle_step) * corner_radius[corner_idx]
			polygon.append(corners[corner_idx] + offsets[corner_idx] + Vector2(x, y))
	return polygon


func triangulate(outside_polygon: PackedVector2Array, inside_polygon: PackedVector2Array) -> PackedInt32Array:
	# We assume outside_polygon and inside_polygon has the same number of vertices

	var points_idx: PackedInt32Array
	var inside_offset = outside_polygon.size()
	var total_points = outside_polygon.size() + inside_polygon.size()
	for i in range(total_points):
		if i % 2 == 0:
			# First triangle
			points_idx.append(i / 2)
			points_idx.append(i / 2 % inside_polygon.size() + inside_offset)
			points_idx.append((i / 2 + 1) % outside_polygon.size())
		else:
			# Second triangle
			points_idx.append(i / 2 + inside_offset)
			points_idx.append((i / 2 + 1) % inside_polygon.size() + inside_offset)
			points_idx.append(ceili(i / 2.0) % outside_polygon.size())

	print(points_idx)
	return points_idx


func _draw_border(to_canvas_item: RID, rect: Rect2, border: StyleBorder, corner_radius: PackedInt32Array, corner_detail: int):
	var inside_rect = rect.grow_individual(
		-border.width_left,
		-border.width_top,
		-border.width_right,
		-border.width_bottom,
	)

	# If there isn't space available to do a proper border, just render the
	# texture in the space left
	if not inside_rect.has_area():
		if border.texture:
			RenderingServer.canvas_item_add_texture_rect(
				to_canvas_item,
				rect,
				border.texture.get_rid(),
				false,
				border.color
			)
		else:
			RenderingServer.canvas_item_add_rect(
				to_canvas_item,
				rect,
				border.color
			)
		return

	var border_outside: PackedVector2Array
	var border_inside: PackedVector2Array
	if corner_radius.count(0) == 4:
		# No corner radius, just create the polygon
		border_outside.resize(4)
		border_outside[0] = rect.position
		border_outside[1] = rect.position + Vector2(rect.size.x, 0)
		border_outside[2] = rect.end
		border_outside[3] = rect.position + Vector2(0, rect.size.y)

		border_inside.resize(4)
		border_inside[0] = inside_rect.position
		border_inside[1] = inside_rect.position + Vector2(inside_rect.size.x, 0)
		border_inside[2] = inside_rect.end
		border_inside[3] = inside_rect.position + Vector2(0, inside_rect.size.y)
	else:
		# Create rounded polygon
		border_outside = _get_rounded_polygon(rect, corner_radius, corner_detail)
		#border_inside = _get_rounded_polygon(inside_rect, [0,0,0,0], corner_detail)
		var inside_corner_radius = _get_border_adjusted_corner_radius(border, corner_radius)
		border_inside = _get_rounded_polygon(inside_rect, inside_corner_radius, corner_detail)

	var polygon_indices = triangulate(border_outside, border_inside)
	var combined_polygon = border_outside + border_inside
	print(combined_polygon)

	var uv_points: PackedVector2Array
	uv_points.resize(combined_polygon.size())
	for point_idx in range(combined_polygon.size()):
		uv_points[point_idx] = (combined_polygon[point_idx] - rect.position) / rect.size

	if border.texture:
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			polygon_indices,
			combined_polygon,
			[border.color],
			uv_points,
			PackedInt32Array(),
			PackedFloat32Array(),
			border.texture.get_rid()
		)
	else:
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			polygon_indices,
			combined_polygon,
			[border.color]
		)

func _get_border_adjusted_corner_radius(border: StyleBorder, corner_radius: PackedInt32Array) -> PackedInt32Array:
	corner_radius[0] -= mini(border.width_left, border.width_top)
	corner_radius[1] -= mini(border.width_top, border.width_right)
	corner_radius[2] -= mini(border.width_right, border.width_bottom)
	corner_radius[3] -= mini(border.width_bottom, border.width_left)
	for corner_idx in range(4):
		if corner_radius[corner_idx] < 0:
			corner_radius[corner_idx] = 0
	return corner_radius

func _draw(to_canvas_item, rect):
	var corner_radius: PackedInt32Array = [
		corner_radius_top_left,
		corner_radius_top_right,
		corner_radius_bottom_right,
		corner_radius_bottom_left
	]

	if draw_center:
		var center_polygon: PackedVector2Array = _get_rounded_polygon(
			rect,
			corner_radius,
			corner_detail
		)
		RenderingServer.canvas_item_add_polygon(to_canvas_item, center_polygon, [color])



	var border_rect = rect
	var border_corner_radius = corner_radius
	for border in borders:
		if not border: continue

		if border.ignore_stack:
			_draw_border(to_canvas_item, rect, border, corner_radius, corner_detail)
			#border_corner_radius = _get_border_adjusted_corner_radius(border, border_corner_radius)
			continue

		if not border_rect.has_area(): continue

		_draw_border(to_canvas_item, border_rect, border, corner_radius, corner_detail)
		#border_corner_radius = _get_border_adjusted_corner_radius(border, border_corner_radius)

		border_rect	= border_rect.grow_individual(
			-border.width_left,
			-border.width_top,
			-border.width_right,
			-border.width_bottom,
		)

	#_get_rounded_polygon(to_canvas_item, rect, [10,10,10,10], 0)
