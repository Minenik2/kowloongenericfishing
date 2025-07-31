extends Camera2D

@export var zoomed_out: Vector2 = Vector2(2, 2)
@export var zoomed_in: Vector2 = Vector2(1, 1)
@export var zoom_duration := 0.4

func zoom_to(target_zoom: Vector2):
	var tween := create_tween()
	tween.tween_property(self, "zoom", target_zoom, zoom_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_cast_started():
	zoom_to(zoomed_out)

func _on_reeling_started():
	zoom_to(zoomed_in)
