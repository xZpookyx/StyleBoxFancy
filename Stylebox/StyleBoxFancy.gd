@tool
@icon("res://Stylebox/StyleBoxFancy.svg")
extends StyleBox
class_name StyleBoxFancy

#region Properties

@export var color: Color = Color(0.6, 0.6, 0.6):
	set(v):
		color = v
		emit_changed()
@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()
@export var skew: Vector2:
	set(v):
		skew = v
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
#endregion

@export_storage var cached_rect: Rect2

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


func _get_points_from_rect(rect: Rect2) -> PackedVector2Array:
	var points: PackedVector2Array = [
		rect.position,
		rect.position + Vector2(rect.size.x, 0),
		rect.end,
		rect.position + Vector2(0, rect.size.y),
	]
	return points


func _draw_border(to_canvas_item: RID, rect: Rect2, border: StyleBorder, corner_radius: PackedInt32Array, corner_detail: int):
	# Inset
	rect = rect.grow_individual(-border.inset_left, -border.inset_top, -border.inset_right, -border.inset_bottom)
	if not rect.has_area():
		return

	# Geometry
	var polygons: Array[PackedVector2Array]

	var inside_rect = rect.grow_individual(
		-border.width_left,
		-border.width_top,
		-border.width_right,
		-border.width_bottom,
	)

	if inside_rect.has_area(): # Has hole
		var outside_polygon: PackedVector2Array
		var inside_polygon: PackedVector2Array
		if corner_radius.count(0) == 4:
			outside_polygon = _get_points_from_rect(rect)
			inside_polygon = _get_points_from_rect(inside_rect)
		else:
			var inside_corner_radius = _get_border_adjusted_corner_radius(border, corner_radius)
			inside_corner_radius = _get_adjusted_corner_radius(inside_corner_radius, inside_rect)

			outside_polygon = _get_rounded_polygon(rect, corner_radius, corner_detail)
			inside_polygon = _get_rounded_polygon(
				inside_rect,
				inside_corner_radius,
				corner_detail
			)
		polygons = Geometry2D.clip_polygons(outside_polygon, inside_polygon)

	else: # Not enought size to cut a hole
		if corner_radius.count(0) == 4:
			polygons = [_get_points_from_rect(rect)]
		else:
			polygons = [_get_rounded_polygon(rect, corner_radius, corner_detail)]

	# Cut polygon if there's an enclosed hole
	if polygons.size() == 2:
		if Geometry2D.is_polygon_clockwise(polygons[1]):
			var fixed_polygon: PackedVector2Array
			fixed_polygon.append_array(polygons[0])
			fixed_polygon.append(polygons[0][0])

			for i in range(polygons[1].size() + 1):
				fixed_polygon.append(polygons[1][i - 2])

			fixed_polygon.append(polygons[0][0])
			polygons = [fixed_polygon]

	# Render
	for polygon in polygons:
		if border.texture:
			var uv: PackedVector2Array
			uv.resize(polygon.size())
			for point_idx in range(polygon.size()):
				uv[point_idx] = (polygon[point_idx] - rect.position) / rect.size

			RenderingServer.canvas_item_add_polygon(
				to_canvas_item,
				polygon,
				[border.color],
				uv,
				border.texture.get_rid()
			)
		else:
			RenderingServer.canvas_item_add_polygon(to_canvas_item, polygon, [border.color])


func _get_border_adjusted_corner_radius(border: StyleBorder, corner_radius: PackedInt32Array, use_inset: bool = false) -> PackedInt32Array:
	var adjusted: PackedInt32Array
	adjusted.resize(4)

	if use_inset:
		adjusted[0] = maxi(0, corner_radius[0] - maxi(0, mini(border.inset_left, border.inset_top)))
		adjusted[1] = maxi(0, corner_radius[1] - maxi(0, mini(border.inset_top, border.inset_right)))
		adjusted[2] = maxi(0, corner_radius[2] - maxi(0, mini(border.inset_right, border.inset_bottom)))
		adjusted[3] = maxi(0, corner_radius[3] - maxi(0, mini(border.inset_bottom, border.inset_left)))
	else:
		adjusted[0] = maxi(0, corner_radius[0] - mini(border.width_left, border.width_top))
		adjusted[1] = maxi(0, corner_radius[1] - mini(border.width_top, border.width_right))
		adjusted[2] = maxi(0, corner_radius[2] - mini(border.width_right, border.width_bottom))
		adjusted[3] = maxi(0, corner_radius[3] - mini(border.width_bottom, border.width_left))
	return adjusted


func _get_polygon_uv(polygon: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var uv: PackedVector2Array
	uv.resize(polygon.size())
	for point_idx in range(polygon.size()):
		uv[point_idx] = (polygon[point_idx] - rect.position) / rect.size
	return uv


func _get_adjusted_corner_radius(corners: PackedInt32Array, rect: Rect2):
	var adjusted: PackedInt32Array
	adjusted.resize(4)
	var scale = min(
		1,
		rect.size.x / (corners[0] + corners[1]),
		rect.size.y / (corners[1] + corners[2]),
		rect.size.x / (corners[2] + corners[3]),
		rect.size.y / (corners[3] + corners[0]),
	)

	for i in range(4):
		adjusted[i] = corners[i] * scale
	return adjusted

func _draw(to_canvas_item, rect):
	if cached_rect == rect:
		pass
	else:
		cached_rect = rect


	var transform = Transform2D(Vector2(1, -skew.y), Vector2(-skew.x, 1), Vector2(rect.size.y * skew.x * 0.5, rect.size.x * skew.y * 0.5))
	RenderingServer.canvas_item_add_set_transform(to_canvas_item, transform)

	var corner_radius: PackedInt32Array = [
		corner_radius_top_left,
		corner_radius_top_right,
		corner_radius_bottom_right,
		corner_radius_bottom_left
	]

	if draw_center:
		# if no corner radius
		if corner_radius.count(0) == 4:
			if texture:
				RenderingServer.canvas_item_add_texture_rect(to_canvas_item, rect, texture.get_rid(), false, color)
			else:
				RenderingServer.canvas_item_add_rect(to_canvas_item, rect, color)
		else:
			var adjusted_corner_radius = _get_adjusted_corner_radius(corner_radius, rect)
			var polygon: PackedVector2Array = _get_rounded_polygon(
					rect,
					adjusted_corner_radius,
					corner_detail
				)

			if texture:
				var uv = _get_polygon_uv(polygon, rect)
				RenderingServer.canvas_item_add_polygon(
					to_canvas_item,
					polygon,
					[color],
					uv,
					texture.get_rid()
				)
			else:
				RenderingServer.canvas_item_add_polygon(to_canvas_item, polygon, [color])

	if borders:
		var border_rect = rect
		var border_corner_radius = corner_radius
		for border in borders:
			if not border: continue


			if border.ignore_stack:
				border_corner_radius = _get_adjusted_corner_radius(border_corner_radius, border_rect)
				_draw_border(to_canvas_item, rect, border, corner_radius, corner_detail)
				continue

			if not border_rect.has_area(): continue

			# Apply inset first
			border_corner_radius = _get_border_adjusted_corner_radius(border, border_corner_radius, true)
			border_corner_radius = _get_adjusted_corner_radius(border_corner_radius, border_rect)

			_draw_border(to_canvas_item, border_rect, border, border_corner_radius, corner_detail)
			border_corner_radius = _get_border_adjusted_corner_radius(border, border_corner_radius)

			border_rect = border_rect.grow_individual(
				-border.width_left - border.inset_left,
				-border.width_top - border.inset_top,
				-border.width_right - border.inset_right,
				-border.width_bottom - border.inset_bottom,
			)
