extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = 700.0

# Adjust this Y value to match where your pit/fall height is
const DEATH_Y_LEVEL = 1000.0 

var is_dying: bool = false


func _ready() -> void:
	floor_snap_length = 8.0
	floor_stop_on_slope = true
	floor_constant_speed = true


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

	# Movement direction
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func die() -> void:
	is_dying = true
	velocity = Vector2.ZERO # Stop all movement
	
	
	# Restart the level back to the beginning
	get_tree().reload_current_scene()
