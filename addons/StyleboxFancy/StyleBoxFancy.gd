@tool
extends StyleBox
class_name StyleBoxFancy

#region Properties
## The background color of this stylebox.
## Modulates [param texture] if it is set.
@export var color: Color = Color(0.6, 0.6, 0.6):
	set(v):
		color = v
		emit_changed()

## The background texture of this stylebox.
@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()

## Toggles drawing the center of this stylebox.
@export var draw_center: bool = true:
	set(v):
		draw_center = v
		emit_changed()

## Distorts the stylebox horizontally or vertically.
## See [member StyleBoxFlat.skew] for more details.
@export var skew: Vector2:
	set(v):
		skew = v
		emit_changed()

## An array of [StyleBorder]s, each border will be drawn one inside of the other
## from top to bottom unless [member StyleBorder.ignore_stack] is enabled.
@export var borders: Array[StyleBorder]:
	set(v):
		borders = v
		for border in borders:
			if not border: continue
			if not border.changed.is_connected(emit_changed):
				border.changed.connect(emit_changed)
		emit_changed()


#region Corners
## Sets the number of vertices used for each corner, it includes the center rect,
## borders, and shadow. See [member StyleBoxFlat.corner_detail] for more details.
@export_range(1, 20, 1) var corner_detail: int = 8:
	set(v):
		corner_detail = v
		emit_changed()

@export_group("Corner Radius", "corner_radius")
## The top-left corner's radius. If [code]0[/code], the corner is not rounded.
@export_range(0, 1, 1, "or_greater") var corner_radius_top_left: int:
	set(v):
		corner_radius_top_left = v
		emit_changed()

## The top-right corner's radius. If [code]0[/code], the corner is not rounded.
@export_range(0, 1, 1, "or_greater") var corner_radius_top_right: int:
	set(v):
		corner_radius_top_right = v
		emit_changed()

## The bottom-right corner's radius. If [code]0[/code], the corner is not rounded.
@export_range(0, 1, 1, "or_greater") var corner_radius_bottom_right: int:
	set(v):
		corner_radius_bottom_right = v
		emit_changed()

## The bottom-left corner's radius. If [code]0[/code], the corner is not rounded.
@export_range(0, 1, 1, "or_greater") var corner_radius_bottom_left: int:
	set(v):
		corner_radius_bottom_left = v
		emit_changed()
#endregion


#region Expand margins
@export_group("Expand Margins", "expand_margin_")
## Expands the stylebox rect outside of the control rect on the left edge,
## and allows negative values (but it wont draw if the rect size is negative). [br]
## See [member StyleBoxFlat.expand_margin_left] for more details.
@export var expand_margin_left: float:
	set(v):
		expand_margin_left = v
		emit_changed()

## Expands the stylebox rect outside of the control rect on the top edge,
## and allows negative values (but it wont draw if the rect size is negative). [br]
## See [member StyleBoxFlat.expand_margin_left] for more details.
@export var expand_margin_top: float:
	set(v):
		expand_margin_top = v
		emit_changed()

## Expands the stylebox rect outside of the control rect on the right edge,
## and allows negative values (but it wont draw if the rect size is negative). [br]
## See [member StyleBoxFlat.expand_margin_left] for more details.
@export var expand_margin_right: float:
	set(v):
		expand_margin_right = v
		emit_changed()

## Expands the stylebox rect outside of the control rect on the bottom edge,
## and allows negative values (but it wont draw if the rect size is negative). [br]
## See [member StyleBoxFlat.expand_margin_left] for more details.
@export var expand_margin_bottom: float:
	set(v):
		expand_margin_bottom = v
		emit_changed()
#endregion


#region Shadow
@export_group("Shadow", "shadow_")
## Toggles drawing the shadow, allows for non blurred shadows unlike [StyleBoxFlat].
@export var shadow_enabled: bool:
	set(v):
		shadow_enabled = v
		emit_changed()

## The shadow's color. Modulates [param shadow_texture] if it is set.
@export var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.6):
	set(v):
		shadow_color = v
		emit_changed()

## The shadow's texture.
@export var shadow_texture: Texture2D:
	set(v):
		shadow_texture = v
		emit_changed()

## Sets the amount of blur the shadow will have.
@export_range(0, 1, 1, "or_greater") var shadow_blur: int = 1:
	set(v):
		shadow_blur = v
		emit_changed()

## Offsets the shadow's rect relative to the stylebox.
@export var shadow_offset: Vector2:
	set(v):
		shadow_offset = v
		emit_changed()

## Sets the size relative to the stylebox, higher values will extend the shadow's rect
## and smaller values will shrink it. [br] [br]
## [b]Note:[/b] if the rect is too small it wont draw.
@export_custom(PROPERTY_HINT_LINK, "") var shadow_spread: Vector2:
	set(v):
		shadow_spread = v
		emit_changed()
#endregion


#region Anti aliasing
@export_group("Anti Aliasing", "anti_aliasing_")
## Makes the edges of the stylebox smoother.
## See [member StyleBoxFlat.anti_aliasing] for more details.
@export var anti_aliasing: bool = true:
	set(v):
		anti_aliasing = v
		emit_changed()

## Changes the size of the antialiasing effect. [code]1.0[/code] is recommended.
## See [member StyleBoxFlat.anti_aliasing_size] for more details.
@export var anti_aliasing_size: float = 1.0:
	set(v):
		anti_aliasing_size = v
		emit_changed()
#endregion

#endregion

func _get_rounded_polygon(rect: Rect2, corner_radius: Vector4) -> PackedVector2Array:
	var corners: PackedVector2Array = _get_points_from_rect(rect)

	var total_points: int = 0
	for i in 4:
		total_points += 1 if corner_radius[i] == 0 else corner_detail + 1

	var polygon: PackedVector2Array
	polygon.resize(total_points)


	const HALF_PI: float = PI * 0.5
	var angle_step: float = HALF_PI / corner_detail
	var idx: int = 0

	for corner_idx: int in 4:
		var radius: float = corner_radius[corner_idx]

		# Square corner
		if radius == 0:
			polygon[idx] = corners[corner_idx]
			idx += 1
			continue

		var offset_x: float = radius if (corner_idx == 0 or corner_idx == 3) else -radius
		var offset_y: float = radius if (corner_idx < 2) else -radius
		var center: Vector2 = corners[corner_idx] + Vector2(offset_x, offset_y)

		var base_angle: float = PI + HALF_PI * corner_idx

		for step: int in corner_detail + 1:
			var angle: float = base_angle + angle_step * step
			polygon[idx] = center + Vector2(cos(angle), sin(angle)) * radius
			idx += 1

	return polygon


func _get_points_from_rect(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.position.x + rect.size.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.position.y + rect.size.y)
	])


func _draw_ring(to_canvas_item: RID, inner_rect: Rect2, outer_rect: Rect2, corner_radius: Vector4, ring_color: Color, ring_texture: Texture2D, texture_rect: Rect2, fade: bool, fade_inside: bool = false) -> void:
	if inner_rect.abs().encloses(outer_rect):
		return

	var inner_corner_radius = _adjust_corner_radius(corner_radius, _get_sides_width_from_rects(inner_rect, outer_rect))

	var inner_points: PackedVector2Array = _get_rounded_polygon(inner_rect, inner_corner_radius)
	var outer_points: PackedVector2Array = _get_rounded_polygon(outer_rect, corner_radius)
	var all_points: PackedVector2Array = inner_points + outer_points
	var indices: PackedInt32Array = _triangulate_ring(inner_points, outer_points, corner_radius, inner_corner_radius)

	for point_idx in range(all_points.size()):
		all_points[point_idx] = all_points[point_idx].clamp(outer_rect.position, outer_rect.end)

	var colors: PackedColorArray
	if fade:
		if fade_inside:
			colors = _get_faded_color_array(ring_color, inner_points.size(), outer_points.size(), true)
		else:
			colors = _get_faded_color_array(ring_color, inner_points.size(), outer_points.size())
	else:
		colors = [ring_color]

	if ring_texture != null:
		RenderingServer.canvas_item_add_triangle_array(
			to_canvas_item,
			indices,
			all_points,
			colors,
			_get_polygon_uv(all_points, texture_rect),
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
		# DEBUG
		#RenderingServer.canvas_item_add_polyline(to_canvas_item, all_points, [Color.GREEN_YELLOW])


func _draw_rect(to_canvas_item: RID, rect: Rect2, rect_color: Color, corner_radius: Vector4, aa: float, rect_texture: Texture2D = null, force_aa: bool = false) -> void:
	# Simple rect check
	if not corner_radius and not force_aa:
		if rect_texture:
			RenderingServer.canvas_item_add_texture_rect(to_canvas_item, rect, rect_texture.get_rid(), false, rect_color)
		else:
			RenderingServer.canvas_item_add_rect(to_canvas_item, rect, rect_color)
		return

	# Rounded rect
	var center_rect: Rect2 = rect
	var center_corner_radius: Vector4 = _fit_corner_radius_in_rect(corner_radius, center_rect)

	if aa != 0: # if antialiasing
		var inner_rect: Rect2 = rect.grow(-aa * 0.5)
		# NOTE: Godot will report an error in rect.expand when its size is negative
		# but will work anyways :/
		inner_rect = inner_rect.expand(inner_rect.abs().get_center())
		var outer_rect: Rect2 = rect.grow(aa * 0.5)
		var inner_corner_radius: Vector4 = _fit_corner_radius_in_rect(corner_radius, inner_rect)
		var ring_corner_radius: Vector4 = _adjust_corner_radius(inner_corner_radius, _get_sides_width_from_rects(outer_rect, inner_rect))
		ring_corner_radius = _fit_corner_radius_in_rect(ring_corner_radius, outer_rect)

		_draw_ring(
			to_canvas_item,
			inner_rect,
			outer_rect,
			ring_corner_radius,
			rect_color,
			rect_texture,
			rect,
			true
		)
		#_draw_debug_rect(to_canvas_item, inner_rect)

		center_rect = inner_rect
		center_corner_radius = inner_corner_radius

	var points: PackedVector2Array = _get_rounded_polygon(center_rect, center_corner_radius)

	if rect_texture != null:
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


func _draw_border(to_canvas_item: RID, rect: Rect2, border: StyleBorder, corner_radius: Vector4) -> void:
	# TODO: In StyleBoxFlat the border gives a margin to the corner radius so it doesn't
	# overlap with itself, however it gives the border a different corner radius than the
	# underlying center panel.

	var outer_rect: Rect2 = rect.grow_individual(-border.inset_left, -border.inset_top, -border.inset_right, -border.inset_bottom)
	var inner_rect: Rect2 = outer_rect.grow_individual(-border.width_left, -border.width_top, -border.width_right, -border.width_bottom)
	var fill_corner_radius: Vector4 = _fit_corner_radius_in_rect(corner_radius, rect)

	if not outer_rect.has_area():
		return

	if not inner_rect.has_area() and not border.blend:
		# Since it is filled, drawing just the rect is more performant
		_draw_rect(
			to_canvas_item,
			outer_rect,
			border.color,
			corner_radius,
			anti_aliasing_size if anti_aliasing else 0.0,
			border.texture,
		)
		return

	if anti_aliasing:
		var antialiasing_sides := Vector4(
			anti_aliasing_size if border.width_left else 0.0,
			anti_aliasing_size if border.width_top else 0.0,
			anti_aliasing_size if border.width_right else 0.0,
			anti_aliasing_size if border.width_bottom else 0.0,
		)

		outer_rect = outer_rect.grow_individual(
			antialiasing_sides[0] * -0.5,
			antialiasing_sides[1] * -0.5,
			antialiasing_sides[2] * -0.5,
			antialiasing_sides[3] * -0.5,
		)
		if not border.blend:
			inner_rect = inner_rect.grow_individual(
				antialiasing_sides[0] * 0.5,
				antialiasing_sides[1] * 0.5,
				antialiasing_sides[2] * 0.5,
				antialiasing_sides[3] * 0.5,
			)

		fill_corner_radius = _adjust_corner_radius(fill_corner_radius, antialiasing_sides * 0.5)

		var feather_outer_rect: Rect2 = outer_rect.grow_individual(
			antialiasing_sides[0],
			antialiasing_sides[1],
			antialiasing_sides[2],
			antialiasing_sides[3],
		)

		var feather_inner_rect: Rect2 = inner_rect.grow_individual(
			-antialiasing_sides[0],
			-antialiasing_sides[1],
			-antialiasing_sides[2],
			-antialiasing_sides[3],
		)

		# Outer aa
		_draw_ring(
			to_canvas_item,
			outer_rect,
			feather_outer_rect,
			_adjust_corner_radius(fill_corner_radius, -antialiasing_sides),
			border.color,
			border.texture,
			rect,
			true,
		)

		# Inner aa
		if not border.blend:
			_draw_ring(
				to_canvas_item,
				feather_inner_rect,
				inner_rect,
				_adjust_corner_radius(fill_corner_radius, _get_sides_width_from_rects(feather_inner_rect, outer_rect) - antialiasing_sides),
				border.color,
				border.texture,
				rect,
				true,
				true
			)


	# Border
	_draw_ring(
		to_canvas_item,
		inner_rect,
		outer_rect,
		fill_corner_radius,
		border.color,
		border.texture,
		rect,
		border.blend,
		true
	)


func _triangulate_ring(inner_ring: PackedVector2Array, outer_ring: PackedVector2Array, corner_radius: Vector4, inner_corner_radius: Vector4) -> PackedInt32Array:
	# Triangle amount calc
	var total_triangles: int = 0
	for corner_idx in 4:
		var is_rounded: bool = corner_radius[corner_idx] != 0
		var inner_is_point: bool = inner_corner_radius[corner_idx] == 0

		if is_rounded:
			if inner_is_point:
				# Triangle per detail
				total_triangles += corner_detail + 2
			else:
				# Quad per detail
				total_triangles += (corner_detail + 1) * 2
		else:
			# Square corner
			total_triangles += 2

	var triangles: PackedInt32Array
	triangles.resize(total_triangles * 3)

	# Triangulation
	var inner_size: int = inner_ring.size()
	var outer_size: int = outer_ring.size()
	var tri_idx: int = 0
	var inner_idx: int = 0
	var outer_idx: int = 0

	for corner_idx: int in 4:
		var is_rounded: bool = corner_radius[corner_idx] != 0
		var inner_is_point: bool = inner_corner_radius[corner_idx] == 0

		if is_rounded:
			if inner_is_point:
				# FIll using triangles
				for i in corner_detail:
					triangles[tri_idx] = inner_idx
					triangles[tri_idx + 1] = outer_idx + inner_size
					triangles[tri_idx + 2] = (outer_idx + 1) % outer_size + inner_size
					tri_idx += 3
					outer_idx += 1
			else:
				# Fill using quads
				for i in corner_detail:
					@warning_ignore_start("confusable_local_declaration") # Yeah I know
					var next_inner: int = (inner_idx + 1) % inner_size
					var next_outer: int = (outer_idx + 1) % outer_size + inner_size
					var curr_outer: int = outer_idx + inner_size
					@warning_ignore_restore("confusable_local_declaration")

					triangles[tri_idx] = inner_idx
					triangles[tri_idx + 1] = curr_outer
					triangles[tri_idx + 2] = next_outer
					triangles[tri_idx + 3] = inner_idx
					triangles[tri_idx + 4] = next_inner
					triangles[tri_idx + 5] = next_outer

					tri_idx += 6
					inner_idx += 1
					outer_idx += 1

		# Fill to the next corner
		var next_inner: int = (inner_idx + 1) % inner_size
		var next_outer: int = (outer_idx + 1) % outer_size + inner_size
		var curr_outer: int = outer_idx + inner_size

		triangles[tri_idx] = inner_idx
		triangles[tri_idx + 1] = curr_outer
		triangles[tri_idx + 2] = next_outer
		triangles[tri_idx + 3] = inner_idx
		triangles[tri_idx + 4] = next_inner
		triangles[tri_idx + 5] = next_outer
		tri_idx += 6

		inner_idx += 1
		outer_idx += 1
	return triangles


func _get_faded_color_array(fill_color: Color, opaque: int, transparent: int, inverse: bool = false) -> PackedColorArray:
	var colors: PackedColorArray
	colors.resize(opaque + transparent)

	if inverse:
		for i in range(opaque):
			colors[i] = fill_color * Color.TRANSPARENT

		for i in range(opaque, opaque + transparent):
			colors[i] = fill_color
	else:
		for i in range(opaque):
			colors[i] = fill_color

		for i in range(opaque, opaque + transparent):
			colors[i] = fill_color * Color.TRANSPARENT

	return colors


func _get_sides_width_from_rects(inner_rect: Rect2, outer_rect: Rect2) -> Vector4:
	return Vector4(
		inner_rect.position.x - outer_rect.position.x,
		inner_rect.position.y - outer_rect.position.y,
		(outer_rect.position.x + outer_rect.size.x) - (inner_rect.position.x + inner_rect.size.x),
		(outer_rect.position.y + outer_rect.size.y) - (inner_rect.position.y + inner_rect.size.y)
	)


func _adjust_corner_radius(corner_radius: Vector4, sides_width: Vector4) -> Vector4:
	return Vector4(
		max(0, corner_radius[0] - min(sides_width[0], sides_width[1])),
		max(0, corner_radius[1] - min(sides_width[1], sides_width[2])),
		max(0, corner_radius[2] - min(sides_width[2], sides_width[3])),
		max(0, corner_radius[3] - min(sides_width[3], sides_width[0]))
	)


func _get_polygon_uv(polygon: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var uv: PackedVector2Array
	uv.resize(polygon.size())
	for point_idx in range(polygon.size()):
		uv[point_idx] = (polygon[point_idx] - rect.position) / rect.size
	return uv


func _fit_corner_radius_in_rect(corners: Vector4, rect: Rect2) -> Vector4:
	var adjusted: Vector4

	var scale = min(
		1,
		rect.size.x / (corners[0] + corners[1]),
		rect.size.y / (corners[1] + corners[2]),
		rect.size.x / (corners[2] + corners[3]),
		rect.size.y / (corners[3] + corners[0]),
	)

	for i in 4:
		# Subtracted a margin to avoid corner overflow because of floating point precision
		adjusted[i] = max(0, corners[i] * scale - 0.001)
	return adjusted


func _draw_debug_rect(to_canvas_item, rect) -> void:
	var points = _get_points_from_rect(rect)
	RenderingServer.canvas_item_add_polyline(to_canvas_item, points, [Color.AQUA])


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	rect = rect.grow_individual(
		expand_margin_left,
		expand_margin_top,
		expand_margin_right,
		expand_margin_bottom
	)

	if not rect.has_area():
		return

	var corner_radius := Vector4(
		corner_radius_top_left,
		corner_radius_top_right,
		corner_radius_bottom_right,
		corner_radius_bottom_left
	)

	# Skew
	var transform := Transform2D(Vector2(1, -skew.y), Vector2(-skew.x, 1), Vector2(rect.size.y * skew.x * 0.5, rect.size.x * skew.y * 0.5))
	RenderingServer.canvas_item_add_set_transform(to_canvas_item, transform)

	if shadow_enabled:
		var shadow_rect: Rect2 = rect.grow(shadow_blur * 0.5)
		shadow_rect = shadow_rect.grow_individual(
			shadow_spread.x * 0.5,
			shadow_spread.y * 0.5,
			shadow_spread.x * 0.5,
			shadow_spread.y * 0.5,
		)
		shadow_rect.position += shadow_offset

		if shadow_rect.has_area():
			_draw_rect(
				to_canvas_item,
				shadow_rect,
				shadow_color,
				corner_radius,
				shadow_blur,
				shadow_texture,
				true
			)

	if draw_center:
		_draw_rect(
			to_canvas_item,
			rect,
			color,
			corner_radius,
			anti_aliasing_size if anti_aliasing else 0.0,
			texture
		)

	if borders:
		var border_rect: Rect2 = rect
		var border_corner_radius: Vector4 = corner_radius

		for border: StyleBorder in borders:
			if border == null: continue

			if border.ignore_stack:
				_draw_border(
					to_canvas_item,
					rect,
					border,
					corner_radius

				)
				continue

			_draw_border(
				to_canvas_item,
				border_rect,
				border,
				border_corner_radius
			)

			# Adjust parameters for the next border
			border_corner_radius = _adjust_corner_radius(border_corner_radius, Vector4(
				border.width_left,
				border.width_top,
				border.width_right,
				border.width_bottom,
			))

			border_rect = border_rect.grow_individual(
				-border.width_left - border.inset_left,
				-border.width_top - border.inset_top,
				-border.width_right - border.inset_right,
				-border.width_bottom - border.inset_bottom,
			)
