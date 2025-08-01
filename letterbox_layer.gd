extends CanvasLayer

@onready var left_bar = $leftRect
@onready var right_bar = $rightRect
@export var bar_width = 100
@export var duration = 0.6

func show_bars():
	var tween = create_tween()
	tween.tween_property(left_bar, "size:x", bar_width, duration)
	tween.parallel().tween_property(right_bar, "size:x", bar_width, duration)

func hide_bars():
	var tween = create_tween()
	tween.tween_property(left_bar, "size:x", 0, duration)
	tween.parallel().tween_property(right_bar, "size:x", 0, duration)
