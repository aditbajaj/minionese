extends Node

# How long the minions get to gloat before the level restarts
const DEATH_SCREEN_TIME = 3.0

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var death_screen: CanvasLayer = $DeathScreen
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

var collected: int = 0
var total: int = 0


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
