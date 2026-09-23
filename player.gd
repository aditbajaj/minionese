extends CharacterBody2D

signal died

const SPEED = 500.0
const JUMP_VELOCITY = 700.0
const BASE_SCALE = Vector2(0.4, 0.4)

# Fall past this and the pit has you
const DEATH_Y_LEVEL = 400.0

var is_dying: bool = false
var _was_on_floor: bool = true

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	floor_snap_length = 8.0
	floor_stop_on_slope = true
	floor_constant_speed = true
	add_to_group("player")


func _physics_process(delta: float) -> void:
	# If dying, freeze player input and movement
	if is_dying:
		return

	# Check if player fell into a pit
	if global_position.y > DEATH_Y_LEVEL:
		die()
		return

	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
		_squash(0.82, 1.20)

	# Movement direction
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Landing thump
	if is_on_floor() and not _was_on_floor:
		_squash(1.22, 0.80)
	_was_on_floor = is_on_floor()


func die() -> void:
	if is_dying:
		return
	is_dying = true
	velocity = Vector2.ZERO # Stop all movement
	died.emit()


func _squash(sx: float, sy: float) -> void:
	sprite.scale = BASE_SCALE * Vector2(sx, sy)
	var tween := create_tween()
	tween.tween_property(sprite, "scale", BASE_SCALE, 0.22) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
