extends CanvasLayer

const QUIPS := [
	"the bananas will wait.",
	"gravity: 1 — you: 0",
	"bello? ...bello?",
	"you have been purple-d.",
	"tank yu for falling.",
	"the ground was a lie.",
	"skipped leg day, clearly.",
	"poopaye!",
	"banana... gone.",
	"that was a choice.",
]

# The slide-in tween owns the minions until this point, then the idle bob does
const SETTLE_TIME = 0.95

@onready var fade: ColorRect = $Fade
@onready var title: Label = $Title
@onready var quip: Label = $Quip
@onready var hint: Label = $Hint
@onready var minions: Control = $Minions
@onready var sfx: AudioStreamPlayer = $Sfx

var _t: float = 0.0
var _playing: bool = false
var _homes: Array[Vector2] = []


func _ready() -> void:
	visible = false


func play() -> void:
	if _playing:
		return
	_playing = true
	visible = true
	# normally I hate godot but this looks so clean, wow (below)
	quip.text = QUIPS.pick_random()
	sfx.play()

	for label in [title, quip, hint]:
		label.pivot_offset = label.size * 0.5

	fade.modulate.a = 0.0
	title.scale = Vector2(0.2, 0.2)
	title.modulate.a = 0.0
	quip.modulate.a = 0.0
	hint.modulate.a = 0.0

	var tween := create_tween().set_parallel()
	tween.tween_property(fade, "modulate:a", 1.0, 0.3)
	tween.tween_property(title, "modulate:a", 1.0, 0.25).set_delay(0.1)
	tween.tween_property(title, "scale", Vector2.ONE, 0.6) \
		.set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(quip, "modulate:a", 1.0, 0.4).set_delay(0.45)
	tween.tween_property(hint, "modulate:a", 0.7, 0.4).set_delay(0.9)

	# The minions shuffle up from under the screen, one after another
	_homes.clear()
	for i in minions.get_child_count():
		var m: Control = minions.get_child(i)
		m.pivot_offset = m.size * 0.5
		_homes.append(m.position)
		m.position = _homes[i] + Vector2(0.0, 520.0)
		tween.tween_property(m, "position", _homes[i], 0.8) \
			.set_delay(0.09 * i).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if not _playing:
		return
	_t += delta

	title.rotation = sin(_t * 2.2) * 0.035
	hint.modulate.a = 0.45 + 0.3 * sin(_t * 3.4)

	if _t < SETTLE_TIME:
		return
	for i in minions.get_child_count():
		var m: Control = minions.get_child(i)
		m.rotation = sin(_t * (1.7 + 0.4 * i) + i) * 0.07
		m.position.y = _homes[i].y + sin(_t * (2.3 + 0.5 * i) + i * 1.7) * 12.0
