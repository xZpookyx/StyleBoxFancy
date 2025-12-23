@tool
extends StyleBox
class_name StyleBoxFancy

const Curvatures = {
	ROUND = 1.0,
	SQUIRCLE = 2.0,
	BEVEL = 0.0,
	SCOOP = -1.0,
	REVERSE_SQUIRCLE = -2.0,
	NOTCH = -4.0
}

var _corner_geometry: Array[PackedVector2Array]

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

@export_group("Corners", "corner_")

## Sets the number of vertices used for each corner, it includes the center rect,
## borders, and shadow. See [member StyleBoxFlat.corner_detail] for more details.
@export_range(1, 20, 1) var corner_detail: int = 8:
	set(v):
		corner_detail = v
		emit_changed()

@export_subgroup("Set to all")
# TODO: Documentation
@export_range(0, 1, 1, "or_greater") var corner_radius_setter: int
@export_enum("Round", "Squircle", "Bevel", "Scoop", "Reverse squircle", "Notch")
var corner_curvature_preset_setter: String = "Round":
	set(v):
		corner_curvature_preset_setter = v
		if v != "Custom":
			corner_curvature_setter = Curvatures.get(v.to_snake_case().to_upper(), corner_curvature_setter)

@export_range(-4, 10, 0.005) var corner_curvature_setter: float = 1:
	set(v):
		corner_curvature_setter = v
		if v not in Curvatures.values():
			corner_curvature_preset_setter = "Custom"

@export_tool_button("Set to all corners", "Edit")
var corner_radius_all_action: Callable = _tool_button_set_to_all_corners

func _tool_button_set_to_all_corners() -> void:
	var undoredo: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	undoredo.create_action("Set corner parameters to all corners")

	undoredo.add_do_property(self, &"corner_radius_top_left", corner_radius_setter)
	undoredo.add_do_property(self, &"corner_radius_top_right", corner_radius_setter)
	undoredo.add_do_property(self, &"corner_radius_bottom_right", corner_radius_setter)
	undoredo.add_do_property(self, &"corner_radius_bottom_left", corner_radius_setter)
	undoredo.add_do_property(self, &"corner_curvature_top_left", corner_curvature_setter)
	undoredo.add_do_property(self, &"corner_curvature_top_right", corner_curvature_setter)
	undoredo.add_do_property(self, &"corner_curvature_bottom_right", corner_curvature_setter)
	undoredo.add_do_property(self, &"corner_curvature_bottom_left", corner_curvature_setter)

	undoredo.add_undo_property(self, &"corner_radius_top_left", corner_radius_top_left)
	undoredo.add_undo_property(self, &"corner_radius_top_right", corner_radius_top_right)
	undoredo.add_undo_property(self, &"corner_radius_bottom_right", corner_radius_bottom_right)
	undoredo.add_undo_property(self, &"corner_radius_bottom_left", corner_radius_bottom_left)
	undoredo.add_undo_property(self, &"corner_curvature_top_left", corner_curvature_top_left)
	undoredo.add_undo_property(self, &"corner_curvature_top_right", corner_curvature_top_right)
	undoredo.add_undo_property(self, &"corner_curvature_bottom_right", corner_curvature_bottom_right)
	undoredo.add_undo_property(self, &"corner_curvature_bottom_left", corner_curvature_bottom_left)
	undoredo.commit_action()


@export_subgroup("Corner Radius", "corner_radius_")
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

@export_subgroup("Corner Curvature", "corner_curvature_")
# TODO: Documentation
@export_range(-4, 10, 0.005) var corner_curvature_top_left: float = 1:
	set(v):
		corner_curvature_top_left = v
		emit_changed()

# TODO: Documentation
@export_range(-4, 10, 0.005) var corner_curvature_top_right: float = 1:
	set(v):
		corner_curvature_top_right = v
		emit_changed()

# TODO: Documentation
@export_range(-4, 10, 0.005) var corner_curvature_bottom_right: float = 1:
	set(v):
		corner_curvature_bottom_right = v
		emit_changed()

# TODO: Documentation
@export_range(-4, 10, 0.005) var corner_curvature_bottom_left: float = 1:
	set(v):
		corner_curvature_bottom_left = v
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

#region Draw
func _superellipse_quadrant(exponent: float, detail: int) -> PackedVector2Array:
	var n: float = pow(2, abs(exponent))
	var points: PackedVector2Array
	points.resize(detail + 1)

	points[0] = Vector2(1, 0)
	points[-1] = Vector2(0, 1)

	const HALF_PI: float = PI * 0.5
	for i: int in range(1, detail):
		var theta: float = HALF_PI * i / detail

		var cx: float = cos(theta)
		var cy: float = sin(theta)

		var x: float = pow(cx, 2.0 / n)
		var y: float = pow(cy, 2.0 / n)
		points[i] = Vector2(x, y)
	return points

func _transform_points(points: PackedVector2Array, transform_vector: Vector2) -> PackedVector2Array:
	var out: PackedVector2Array
	for p: Vector2 in points:
		out.append(p * transform_vector)
	return out

func _generate_corner_geometry(corner_curvatures: Vector4) -> void:
	var transforms: PackedVector2Array = [
		Vector2(-1, -1),
		Vector2(1, -1),
		Vector2(1, 1),
		Vector2(-1, 1),
	]

	var _quadrant_cache: Dictionary[float, PackedVector2Array]
	var geometry_array: Array[PackedVector2Array]

	for corner_idx in range(4):
		var quadrant_points: PackedVector2Array
		var corner_geometry: PackedVector2Array
		var curvature: float = corner_curvatures[corner_idx]

		if _quadrant_cache.has(curvature):
			quadrant_points = _quadrant_cache[curvature]
		else:
			quadrant_points = _superellipse_quadrant(curvature, corner_detail)
			_quadrant_cache[curvature] = quadrant_points

		var sign = sign(curvature)
		if curvature == 0:
			sign = -1

		quadrant_points = _transform_points(
			quadrant_points,
			transforms[corner_idx] * sign
		)

		if curvature > 0:
			if corner_idx % 2 == 1:
				quadrant_points.reverse()

			for point in quadrant_points:
				corner_geometry.append(point - transforms[corner_idx] * sign)
		else:
			if corner_idx % 2 == 0:
				quadrant_points.reverse()
			corner_geometry = quadrant_points
		geometry_array.append(corner_geometry)

	_corner_geometry = geometry_array


func _get_rounded_rect(rect: Rect2, corner_radii: Vector4) -> PackedVector2Array:
	var corners: PackedVector2Array = [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]

	var points: PackedVector2Array

	for corner_idx: int in range(4):
		if corner_radii[corner_idx] == 0:
			points.append(corners[corner_idx])
		else:
			var corner: PackedVector2Array
			for point: Vector2 in _corner_geometry[corner_idx]:
				corner.append(point * corner_radii[corner_idx] + corners[corner_idx])
			points.append_array(corner)
	return points


func _get_points_from_rect(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y)
	])


func _draw_ring(to_canvas_item: RID, inner_rect: Rect2, outer_rect: Rect2, corner_radius: Vector4, ring_color: Color, ring_texture: Texture2D, texture_rect: Rect2, fade: bool, fade_inside: bool = false) -> void:
	if inner_rect.abs().encloses(outer_rect):
		return

	var inner_corner_radius = _adjust_corner_radius(corner_radius, _get_sides_width_from_rects(inner_rect, outer_rect))

	var inner_points: PackedVector2Array = _get_rounded_rect(inner_rect, inner_corner_radius)
	var outer_points: PackedVector2Array = _get_rounded_rect(outer_rect, corner_radius)
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

	var points: PackedVector2Array = _get_rounded_rect(center_rect, center_corner_radius)

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
	# NOTE: In StyleBoxFlat the border gives a margin to the corner radius so it doesn't
	# overlap with itself, however it gives the border a different corner radius than the
	# underlying center panel.

	# NOTE 2: I'm not sure if I want to have that behavior, css doesn't do it, but
	# consider if you know how to fix the overlap when it is transparent, that would be awesome

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

func _draw_debug_polygon(to_canvas_item: RID, polygon: PackedVector2Array):
	RenderingServer.canvas_item_add_polyline(to_canvas_item, polygon, [Color.AQUA])
	RenderingServer.canvas_item_add_circle(to_canvas_item, polygon[0], 1, Color.RED)
	RenderingServer.canvas_item_add_circle(to_canvas_item, polygon[-1], 1, Color.BLUE)

func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	rect = rect.grow_individual(
		expand_margin_left,
		expand_margin_top,
		expand_margin_right,
		expand_margin_bottom
	)

	if not rect.has_area():
		return

	var corner_radii: Vector4 = Vector4(
		corner_radius_top_left,
		corner_radius_top_right,
		corner_radius_bottom_right,
		corner_radius_bottom_left,
	)

	var corner_curvatures: Vector4 = Vector4(
		corner_curvature_top_left,
		corner_curvature_top_right,
		corner_curvature_bottom_right,
		corner_curvature_bottom_left,
	)

	_generate_corner_geometry(corner_curvatures)

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
				corner_radii,
				shadow_blur,
				shadow_texture,
				true
			)

	if draw_center:
		_draw_rect(
			to_canvas_item,
			rect,
			color,
			corner_radii,
			anti_aliasing_size if anti_aliasing else 0.0,
			texture
		)

	if borders:
		var border_rect: Rect2 = rect
		var border_corner_radii: Vector4 = corner_radii

		for border: StyleBorder in borders:
			if border == null: continue

			if border.ignore_stack:
				_draw_border(
					to_canvas_item,
					rect,
					border,
					corner_radii

				)
				continue

			_draw_border(
				to_canvas_item,
				border_rect,
				border,
				border_corner_radii
			)

			# Adjust parameters for the next border
			border_corner_radii = _adjust_corner_radius(border_corner_radii, Vector4(
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

	RenderingServer.canvas_item_add_set_transform(to_canvas_item, Transform2D.IDENTITY)
#endregion

#region Public methods
# Getters
func get_corner_radius(corner: Corner) -> int:
	match corner:
		CORNER_TOP_LEFT: return corner_radius_top_left
		CORNER_TOP_RIGHT: return corner_radius_top_right
		CORNER_BOTTOM_LEFT: return corner_radius_bottom_left
		CORNER_BOTTOM_RIGHT: return corner_radius_bottom_right
		_: return 0

func get_corner_curvature(corner: Corner) -> float:
	match corner:
		CORNER_TOP_LEFT: return corner_curvature_top_left
		CORNER_TOP_RIGHT: return corner_curvature_top_right
		CORNER_BOTTOM_LEFT: return corner_curvature_bottom_left
		CORNER_BOTTOM_RIGHT: return corner_curvature_bottom_right
		_: return 0

func get_expand_margin(side: Side) -> float:
	match side:
		SIDE_LEFT: return expand_margin_left
		SIDE_TOP: return expand_margin_top
		SIDE_RIGHT: return expand_margin_right
		SIDE_BOTTOM: return expand_margin_bottom
		_: return 0

# Setters
func set_corner_radius(corner: Corner, radius: int) -> void:
	match corner:
		CORNER_TOP_LEFT: corner_radius_top_left = radius
		CORNER_TOP_RIGHT: corner_radius_top_right = radius
		CORNER_BOTTOM_LEFT: corner_radius_bottom_left = radius
		CORNER_BOTTOM_RIGHT: corner_radius_bottom_right = radius

func set_corner_radius_all(radius: int) -> void:
	corner_radius_top_left = radius
	corner_radius_top_right = radius
	corner_radius_bottom_right = radius
	corner_radius_bottom_left = radius

func set_corner_curvature(corner: Corner, curvature: int) -> void:
	match corner:
		CORNER_TOP_LEFT: corner_curvature_top_left = curvature
		CORNER_TOP_RIGHT: corner_curvature_top_right = curvature
		CORNER_BOTTOM_LEFT: corner_curvature_bottom_left = curvature
		CORNER_BOTTOM_RIGHT: corner_curvature_bottom_right = curvature

func set_corner_curvature_all(curvature: int) -> void:
	corner_curvature_top_left = curvature
	corner_curvature_top_right = curvature
	corner_curvature_bottom_right = curvature
	corner_curvature_bottom_left = curvature

func set_expand_margin(side: Side, margin: float) -> void:
	match side:
		SIDE_LEFT: expand_margin_left = margin
		SIDE_TOP: expand_margin_top = margin
		SIDE_RIGHT: expand_margin_right = margin
		SIDE_BOTTOM: expand_margin_bottom = margin

func set_expand_margin_all(margin: float) -> void:
	expand_margin_left = margin
	expand_margin_top = margin
	expand_margin_right = margin
	expand_margin_bottom = margin
#endregion
