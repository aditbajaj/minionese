extends CanvasLayer

@onready var label: Label = $Margin/Counter/Label
@onready var icon: TextureRect = $Margin/Counter/Icon


func set_count(collected: int, total: int) -> void:
	label.text = "%d / %d" % [collected, total]


func pop() -> void:
	icon.scale = Vector2(1.45, 1.45)
	var tween := create_tween()
	tween.tween_property(icon, "scale", Vector2.ONE, 0.28) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
