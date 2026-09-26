extends Node

# How long the minions get to gloat before the level restarts
const DEATH_SCREEN_TIME = 3.0

# Landing past this point on the last platform counts as reaching the end
const FINISH_X = 12128.0
const WIN_SCREEN_TIME = 4.0
# The banana barrage never takes longer than this, however many you skipped
const MAX_BARRAGE_TIME = 5.0

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var death_screen: CanvasLayer = $DeathScreen
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var smash_sfx: AudioStreamPlayer = $SmashSfx

var collected: int = 0
var total: int = 0
var won: bool = false


func _ready() -> void:
	var bananas := get_tree().get_nodes_in_group("banana")
	total = bananas.size()
	for banana in bananas:
		banana.collected.connect(_on_banana_collected)
	hud.set_count(collected, total)
	player.died.connect(_on_player_died)

	# Hold the minion still and the music back until the hello finishes
	player.set_physics_process(false)
	var hello := AudioStreamPlayer.new()
	hello.stream = preload("res://hello.mp3")
	add_child(hello)
	hello.play()
	await hello.finished
	hello.queue_free()
	player.set_physics_process(true)
	music.play()


func _on_banana_collected() -> void:
	collected += 1
	hud.set_count(collected, total)
	hud.pop()


func _on_player_died() -> void:
	death_screen.play()
	await get_tree().create_timer(DEATH_SCREEN_TIME).timeout
	get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	if not won and not player.is_dying and player.is_on_floor() \
			and player.global_position.x > FINISH_X:
		_win()


func _win() -> void:
	won = true
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	create_tween().tween_property(music, "volume_db", -40.0, 1.0)

	var missed: Array = []
	for banana in get_tree().get_nodes_in_group("banana"):
		if not banana.taken:
			missed.append(banana)

	var gap := minf(0.2, MAX_BARRAGE_TIME / maxf(missed.size(), 1.0))
	for i in missed.size():
		missed[i].smashed.connect(_on_banana_smashed)
		missed[i].smash_into(player, 0.6 + gap * i)
	if not missed.is_empty():
		await missed[missed.size() - 1].smashed
		await get_tree().create_timer(0.6).timeout

	hud.show_win(collected, total)
	await get_tree().create_timer(WIN_SCREEN_TIME).timeout
	get_tree().reload_current_scene()


func _on_banana_smashed() -> void:
	player.bonk()
	smash_sfx.pitch_scale = randf_range(0.85, 1.2)
	smash_sfx.play()
	var cam: Camera2D = player.get_node("Camera2D")
	var tween := create_tween()
	for i in 4:
		tween.tween_property(cam, "offset",
			Vector2(150, -110) + Vector2(randf_range(-18, 18), randf_range(-18, 18)), 0.03)
	tween.tween_property(cam, "offset", Vector2(150, -110), 0.05)
