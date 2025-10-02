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
@export_group("Corner Radius", "corner_radius")
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

# Antialiasing
@export_group("Anti Aliasing", "anti_aliasing_")
@export var anti_aliasing: bool = true:
	set(v):
		anti_aliasing = v
		emit_changed()
@export var anti_aliasing_size: float = 1.0:
	set(v):
		anti_aliasing_size = v
		emit_changed()

#endregion

@export_storage var cached_rect: Rect2

func _get_rounded_polygon(rect: Rect2, corner_radius: Vector4) -> PackedVector2Array:
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


func _draw_rect(to_canvas_item: RID, rect: Rect2, rect_color: Color, corner_radius: Vector4, aa: float, rect_texture: Texture2D):
	# Simple rect check
	if not corner_radius:
		if rect_texture:
			RenderingServer.canvas_item_add_texture_rect(to_canvas_item, rect, rect_texture.get_rid(), false, color)
		else:
			RenderingServer.canvas_item_add_rect(to_canvas_item, rect, color)
		return

	# Rounded rect
	var center_rect = rect
	var center_cr = corner_radius

	if aa != 0: # if antialiasing
		center_rect = rect.grow(-aa * 0.5)
		center_cr = _adjust_corner_radius(corner_radius, _get_sides_width_from_rects(center_rect, rect.grow(aa * 0.5)))

		_draw_ring2(
			to_canvas_item,
			center_rect,
			rect.grow(aa * 0.5),
			corner_radius,
			rect_color,
			true,
			texture
		)

	var points = _get_rounded_polygon(center_rect, center_cr)
	if rect_texture:
		RenderingServer.canvas_item_add_polygon(
			to_canvas_item,
			points,
			[rect_color],
			_get_polygon_uv(points, rect),
			rect_texture.get_rid()
		)
	else:
		RenderingServer.canvas_item_add_polygon(
			to_canvas_item,
			points,
			[rect_color]
		)

func _draw_ring2(to_canvas_item: RID, inner_rect: Rect2, outer_rect: Rect2, corner_radius: Vector4, ring_color: Color, fade: bool, ring_texture: Texture2D):
	# left, top, right, bottom
	var inner_corner_radius = _adjust_corner_radius(corner_radius, Vector4(
		inner_rect.position.x - outer_rect.position.x,
		inner_rect.position.y - outer_rect.position.y,
		inner_rect.position.x + inner_rect.size.x - outer_rect.position.x + outer_rect.size.x,
		inner_rect.position.y + inner_rect.size.y - outer_rect.position.y + outer_rect.size.y,
	))
	var inner_points: PackedVector2Array = _get_rounded_polygon(inner_rect, inner_corner_radius)
	var outer_points: PackedVector2Array = _get_rounded_polygon(outer_rect, corner_radius)
	var all_points: PackedVector2Array = inner_points + outer_points
	var indices: PackedInt32Array = _triangulate_ring(inner_points, outer_points, corner_radius)
	var colors: PackedColorArray = _get_faded_color_array(ring_color, inner_points.size(), outer_points.size()) if fade else [ring_color]


	if ring_texture != null:
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			indices,
			all_points,
			colors,
			_get_polygon_uv(all_points, outer_rect),
			PackedInt32Array(),
			PackedFloat32Array(),
			ring_texture.get_rid()
		)
	else:
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			indices,
			all_points,
			colors,
		)

func _draw_antialiased_border(to_canvas_item: RID, rect: Rect2, border: StyleBorder, corner_radius: Vector4):
	var border_outer_rect = rect.grow_individual(
		-border.inset_left,
		-border.inset_top,
		-border.inset_right,
		-border.inset_bottom
	)
	var border_inner_rect = border_outer_rect.grow_individual(
		-border.width_left,
		-border.width_top,
		-border.width_right,
		-border.width_bottom,
	)

	if not anti_aliasing:
		var outer_ring = _get_rounded_polygon(border_outer_rect, corner_radius)
		var inner_ring = _get_rounded_polygon(border_inner_rect, corner_radius)
		var fill_points = inner_ring + outer_ring
		if border.texture != null:
			RenderingServer.canvas_item_add_triangle_array(
				to_canvas_item,
				_triangulate_ring(inner_ring, outer_ring, corner_radius),
				fill_points,
				[border.color],
				_get_polygon_uv(fill_points, rect),
				PackedInt32Array(),
				PackedFloat32Array(),
				border.texture.get_rid()
			)
		else:
			RenderingServer.canvas_item_add_triangle_array(
				to_canvas_item,
				_triangulate_ring(inner_ring, outer_ring, corner_radius),
				fill_points,
				[border.color]
			)
		return

	# GEOMETRY
	var rings: Array[PackedVector2Array]
	var inner_rect
	var outer_rect

	# Outside
	inner_rect = border_outer_rect.grow_individual(
		-anti_aliasing_size / 2 if border.width_left else 0,
		-anti_aliasing_size / 2 if border.width_top else 0,
		-anti_aliasing_size / 2 if border.width_right else 0,
		-anti_aliasing_size / 2 if border.width_bottom else 0
	)
	outer_rect = border_outer_rect.grow_individual(
		anti_aliasing_size / 2 if border.width_left else 0,
		anti_aliasing_size / 2 if border.width_top else 0,
		anti_aliasing_size / 2 if border.width_right else 0,
		anti_aliasing_size / 2 if border.width_bottom else 0
	)

	rings.append_array([
		_get_rounded_polygon(outer_rect, corner_radius),
		_get_rounded_polygon(inner_rect, corner_radius)
	])

	# Inside
	inner_rect = border_inner_rect.grow_individual(
		-anti_aliasing_size / 2 if border.width_left else 0,
		-anti_aliasing_size / 2 if border.width_top else 0,
		-anti_aliasing_size / 2 if border.width_right else 0,
		-anti_aliasing_size / 2 if border.width_bottom else 0
	)
	outer_rect = border_inner_rect.grow_individual(
		anti_aliasing_size / 2 if border.width_left else 0,
		anti_aliasing_size / 2 if border.width_top else 0,
		anti_aliasing_size / 2 if border.width_right else 0,
		anti_aliasing_size / 2 if border.width_bottom else 0
	)

	rings.append_array([
		_get_rounded_polygon(outer_rect, corner_radius),
		_get_rounded_polygon(inner_rect, corner_radius),
	])


	# RENDER
	var outer_ring_points = rings[1] + rings[0]
	var inner_ring_points = rings[2] + rings[3]
	var fill_points = rings[1] + rings[2]
	if border.texture != null:
		# TEXTURE
		# Outer ring
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(rings[1], rings[0], corner_radius),
			outer_ring_points,
			_get_faded_color_array(border.color, rings[1].size(), rings[0].size()),
			_get_polygon_uv(outer_ring_points, rect),
			PackedInt32Array(),
			PackedFloat32Array(),
			border.texture.get_rid()
		)

		# Inner ring
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(rings[2], rings[3], corner_radius),
			inner_ring_points,
			_get_faded_color_array(border.color, rings[2].size(), rings[3].size()),
			_get_polygon_uv(inner_ring_points, rect),
			PackedInt32Array(),
			PackedFloat32Array(),
			border.texture.get_rid()
		)

		# Fill
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(rings[1], rings[2], corner_radius),
			rings[1] + rings[2],
			[border.color],
			_get_polygon_uv(fill_points, rect),
			PackedInt32Array(),
			PackedFloat32Array(),
			border.texture.get_rid()
		)
	else:
		# NO TEXTURE
		# Outer ring
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(rings[1], rings[0], corner_radius),
			outer_ring_points,
			_get_faded_color_array(border.color, rings[1].size(), rings[0].size())
		)

		# Inner ring
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(rings[2], rings[3], corner_radius),
			inner_ring_points,
			_get_faded_color_array(border.color, rings[2].size(), rings[3].size())
		)

		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(rings[1], rings[2], corner_radius),
			rings[1] + rings[2],
			[border.color]
		)


func _draw_ring(
	to_canvas_item: RID,
	inner_ring: PackedVector2Array,
	outer_ring: PackedVector2Array,
	corner_radius: Vector4,
	ring_color: Color,
	faded: bool = false,
	ring_texture: RID = RID(),
	ring_uv: PackedVector2Array = PackedVector2Array()
	):
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			_triangulate_ring(inner_ring, outer_ring, corner_radius),
			inner_ring + outer_ring,
			_get_faded_color_array(ring_color, inner_ring.size(), outer_ring.size()), #if faded else [ring_color],
			ring_uv,
			PackedInt32Array(),
			PackedFloat32Array(),
			ring_texture
		)


func _triangulate_ring(inner_ring: PackedVector2Array, outer_ring: PackedVector2Array, corner_radius: Vector4) -> PackedInt32Array:
	var triangle_indices: PackedInt32Array
	var vertex_idx: int = 0
	for corner_idx in range(4):
		var is_rounded = corner_radius[corner_idx] != 0

		for i in range(corner_detail + 1):
			triangle_indices.append(vertex_idx + i)
			triangle_indices.append(vertex_idx + inner_ring.size() + i)
			triangle_indices.append((vertex_idx + 1 + i) % outer_ring.size() + inner_ring.size())

			triangle_indices.append(vertex_idx + i)
			triangle_indices.append((vertex_idx + i + 1) % inner_ring.size())
			triangle_indices.append((vertex_idx + i + 1) % outer_ring.size() + inner_ring.size())

			if not is_rounded:
				break

		if is_rounded:
			vertex_idx += corner_detail + 1
		else:
			vertex_idx += 1
	return triangle_indices


func _get_faded_color_array(fill_color: Color, opaque: int, transparent: int) -> PackedColorArray:
	var colors: PackedColorArray
	colors.resize(opaque + transparent)

	for i in range(opaque):
		colors[i] = fill_color

	for i in range(opaque, opaque + transparent):
		colors[i] = fill_color * Color.TRANSPARENT

	return colors


func _draw_border2(to_canvas_item: RID, rect: Rect2, border: StyleBorder, corner_radius: Vector4):
	var outer_rect = rect.grow_individual(-border.inset_left, -border.inset_top, -border.inset_right, -border.inset_bottom)
	var inner_rect = outer_rect.grow_individual(-border.width_left, -border.width_top, -border.width_right, -border.width_bottom)

	if not outer_rect.has_area():
		return

	if anti_aliasing:
		outer_rect = outer_rect.grow(-anti_aliasing_size * 0.5)
		inner_rect = inner_rect.grow(anti_aliasing_size * 0.5)

		# Outer aa
		_draw_ring2(
			to_canvas_item,
			outer_rect,
			outer_rect.grow(anti_aliasing_size),
			corner_radius,
			border.color,
			true,
			border.texture
		)

		# Inner aa
		_draw_ring2(
			to_canvas_item,
			inner_rect,
			inner_rect.grow(-anti_aliasing_size),
			corner_radius,
			border.color,
			true,
			border.texture
		)

	_draw_ring2(
		to_canvas_item,
		inner_rect,
		outer_rect,
		corner_radius,
		border.color,
		false,
		border.texture
	)

func _get_sides_width_from_rects(inner_rect: Rect2, outer_rect: Rect2):
	return Vector4(
		inner_rect.position.x - outer_rect.position.x,
		inner_rect.position.y - outer_rect.position.y,
		inner_rect.position.x + inner_rect.size.x - outer_rect.position.x + outer_rect.size.x,
		inner_rect.position.y + inner_rect.size.y - outer_rect.position.y + outer_rect.size.y
	)

func _adjust_corner_radius(corner_radius: Vector4, sides_width: Vector4):
	var adjusted: Vector4

	adjusted[0] = maxi(0, corner_radius[0] - maxi(0, mini(sides_width[0], sides_width[1])))
	adjusted[1] = maxi(0, corner_radius[1] - maxi(0, mini(sides_width[1], sides_width[2])))
	adjusted[2] = maxi(0, corner_radius[2] - maxi(0, mini(sides_width[2], sides_width[3])))
	adjusted[3] = maxi(0, corner_radius[3] - maxi(0, mini(sides_width[3], sides_width[0])))
	return adjusted

func _draw_border(to_canvas_item: RID, rect: Rect2, border: StyleBorder, corner_radius: Vector4):
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
		if corner_radius:
			outside_polygon = _get_points_from_rect(rect)
			inside_polygon = _get_points_from_rect(inside_rect)
		else:
			var inside_corner_radius = _get_border_adjusted_corner_radius(border, corner_radius)
			inside_corner_radius = _get_adjusted_corner_radius(inside_corner_radius, inside_rect)

			#outside_polygon = _get_rounded_polygon(rect, corner_radius, corner_detail)
			inside_polygon = _get_rounded_polygon(inside_rect, inside_corner_radius)
		polygons = Geometry2D.clip_polygons(outside_polygon, inside_polygon)

	else: # Not enought size to cut a hole
		if corner_radius:
			polygons = [_get_points_from_rect(rect)]
		else:
			pass
			#polygons = [_get_rounded_polygon(rect, corner_radius, corner_detail)]

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


func _get_border_adjusted_corner_radius(border: StyleBorder, corner_radius: Vector4, use_inset: bool = false) -> Vector4:
	var adjusted: Vector4

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


func _get_adjusted_corner_radius(corners: Vector4, rect: Rect2):
	var adjusted: Vector4

	var scale = min(
		1,
		rect.size.x / (corners[0] + corners[1]),
		rect.size.y / (corners[1] + corners[2]),
		rect.size.x / (corners[2] + corners[3]),
		rect.size.y / (corners[3] + corners[0]),
	)

	for i in range(4):
		adjusted[i] = corners[i] * scale - 1
	return adjusted



func _draw(to_canvas_item, rect):
	var corner_radius = Vector4(
		corner_radius_top_left,
		corner_radius_top_right,
		corner_radius_bottom_right,
		corner_radius_bottom_left
	)

	var transform = Transform2D(Vector2(1, -skew.y), Vector2(-skew.x, 1), Vector2(rect.size.y * skew.x * 0.5, rect.size.x * skew.y * 0.5))
	RenderingServer.canvas_item_add_set_transform(to_canvas_item, transform)

	if draw_center:
		_draw_rect(
			to_canvas_item,
			rect,
			color,
			corner_radius,
			anti_aliasing_size if anti_aliasing else 0,
			texture
		)

	if borders:
		for border in borders:
			_draw_border2(
				to_canvas_item,
				rect,
				border,
				corner_radius
			)

	#if borders:
		#var border_rect = rect
		#var border_corner_radius: Vector4 = corner_radius
		#for border in borders:
			#if not border: continue
#
#
			#if border.ignore_stack:
				#border_corner_radius = _get_adjusted_corner_radius(border_corner_radius, border_rect)
				#_draw_border(to_canvas_item, rect, border, corner_radius, corner_detail)
				#continue
#
			#if not border_rect.has_area(): continue
#
			## Apply inset first
			#border_corner_radius = _get_border_adjusted_corner_radius(border, border_corner_radius, true)
			#border_corner_radius = _get_adjusted_corner_radius(border_corner_radius, border_rect)
#
			##_draw_border(to_canvas_item, border_rect, border, border_corner_radius, corner_detail)
			#_draw_antialiased_border(to_canvas_item, border_rect, border, border_corner_radius)
			#border_corner_radius = _get_border_adjusted_corner_radius(border, border_corner_radius)
#
			#border_rect = border_rect.grow_individual(
				#-border.width_left - border.inset_left,
				#-border.width_top - border.inset_top,
				#-border.width_right - border.inset_right,
				#-border.width_bottom - border.inset_bottom,
			#)
