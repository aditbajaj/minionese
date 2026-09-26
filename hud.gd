extends CanvasLayer

@onready var label: Label = $Margin/Counter/Label
@onready var icon: TextureRect = $Margin/Counter/Icon
@onready var win_label: Label = $WinLabel


func set_count(collected: int, total: int) -> void:
	label.text = "%d / %d" % [collected, total]


func pop() -> void:
	icon.scale = Vector2(1.45, 1.45)
	var tween := create_tween()
	tween.tween_property(icon, "scale", Vector2.ONE, 0.28) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func show_win(collected: int, total: int) -> void:
	var missed := total - collected
	win_label.text = "YOU WIN!\n" + (
		"all %d bananas, flawless" % total if missed == 0
		else "...but %d banana%s got you" % [missed, "" if missed == 1 else "s"])
	win_label.visible = true
	win_label.pivot_offset = win_label.size * 0.5
	win_label.scale = Vector2(0.2, 0.2)
	create_tween().tween_property(win_label, "scale", Vector2.ONE, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
