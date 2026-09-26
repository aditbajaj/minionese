extends Control

# Bottom-left arrows move, a tap anywhere on the right half of the screen jumps
const BUTTON_RADIUS = 78.0
const MARGIN = 40.0

# finger index -> action it is holding
var _fingers: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = DisplayServer.is_touchscreen_available()


func _left_center() -> Vector2:
	return Vector2(MARGIN + BUTTON_RADIUS, size.y - MARGIN - BUTTON_RADIUS)


func _right_center() -> Vector2:
	return _left_center() + Vector2(BUTTON_RADIUS * 2.0 + 30.0, 0.0)


func _jump_center() -> Vector2:
	return Vector2(size.x - MARGIN - BUTTON_RADIUS, size.y - MARGIN - BUTTON_RADIUS)


func _action_at(pos: Vector2) -> String:
	if pos.x > size.x * 0.5:
		return "jump"
	# Generous hit area so thumbs don't slip off the arrows
	if pos.distance_to(_left_center()) < BUTTON_RADIUS * 1.3:
		return "left"
	if pos.distance_to(_right_center()) < BUTTON_RADIUS * 1.3:
		return "right"
	return ""


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		# Touch positions are in window pixels, the controls are in canvas units
		var pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		if event.pressed:
			_hold(event.index, _action_at(pos))
		else:
			_hold(event.index, "")
	elif event is InputEventScreenDrag:
		var pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		# Sliding a thumb between the arrows switches direction, but a jump
		# finger stays a jump finger so it can't start walking by accident
		if _fingers.get(event.index, "") != "jump":
			var action := _action_at(pos)
			_hold(event.index, "" if action == "jump" else action)


func _hold(finger: int, action: String) -> void:
	var old: String = _fingers.get(finger, "")
	if old == action:
		return
	_fingers.erase(finger)
	if old != "" and not _fingers.values().has(old):
		Input.action_release(old)
	if action != "":
		_fingers[finger] = action
		Input.action_press(action)
	queue_redraw()


func _draw() -> void:
	var held: Array = _fingers.values()
	_draw_button(_left_center(), "left" in held, PI)
	_draw_button(_right_center(), "right" in held, 0.0)
	_draw_button(_jump_center(), "jump" in held, -PI / 2.0)


func _draw_button(center: Vector2, pressed: bool, angle: float) -> void:
	var fill := Color(1, 1, 1, 0.32 if pressed else 0.16)
	draw_circle(center, BUTTON_RADIUS, fill)
	draw_arc(center, BUTTON_RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.45), 4.0, true)
	var tip := Vector2(30, 0).rotated(angle)
	var side := Vector2(-18, 26).rotated(angle)
	var side2 := Vector2(-18, -26).rotated(angle)
	draw_colored_polygon(PackedVector2Array([center + tip, center + side, center + side2]),
		Color(1, 1, 1, 0.8))
