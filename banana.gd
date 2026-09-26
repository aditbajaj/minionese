extends Area2D

signal collected
signal smashed

const BOB_HEIGHT = 8.0
const BOB_SPEED = 2.4

var taken: bool = false

var _base_y: float = 0.0
var _phase: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var sparks: CPUParticles2D = $Sparks
@onready var pop: Label = $Pop
@onready var sfx: AudioStreamPlayer = $Sfx


func _ready() -> void:
	add_to_group("banana")
	_base_y = position.y
	# Stagger the bob so a row of bananas doesn't move in lockstep
	_phase = randf() * TAU
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if taken:
		return
	_phase += delta * BOB_SPEED
	position.y = _base_y + sin(_phase) * BOB_HEIGHT
	sprite.rotation = sin(_phase * 0.7) * 0.22


func _on_body_entered(body: Node2D) -> void:
	if taken or not body.is_in_group("player"):
		return
	taken = true
	shape.set_deferred("disabled", true)

	sparks.emitting = true
	sfx.pitch_scale = randf_range(0.96, 1.08)
	sfx.play()

	pop.modulate.a = 1.0
	var tween := create_tween().set_parallel()
	tween.tween_property(sprite, "scale", sprite.scale * 2.1, 0.20) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.24)
	tween.tween_property(pop, "position:y", pop.position.y - 70.0, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(pop, "modulate:a", 0.0, 0.8)

	collected.emit()

	# Stay alive long enough for the sound and sparks to finish
	await get_tree().create_timer(1.0).timeout
	queue_free()


# Crash style: every banana you skipped comes back for you at the end
func smash_into(target: Node2D, delay: float) -> void:
	taken = true
	shape.set_deferred("disabled", true)
	await get_tree().create_timer(delay).timeout

	var tween := create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -140), 0.22) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "rotation", TAU * 3.0, 0.55)
	tween.tween_property(self, "global_position", target.global_position, 0.33) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

	sparks.emitting = true
	sprite.visible = false
	smashed.emit()
	await get_tree().create_timer(0.8).timeout
	queue_free()
