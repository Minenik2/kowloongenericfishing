extends Camera2D

@export var zoomed_out: Vector2 = Vector2(0.4, 0.4)
@export var zoomed_in: Vector2 = Vector2(1, 1)
@export var zoom_duration := 0.8
@export var pan_offset: Vector2 = Vector2(0, 540) # pan down 40 pixels
@onready var bobber: Sprite2D = $"../rod/bobber"

@onready var letterbox_layer: CanvasLayer = $"../../LetterboxLayer"


var default_position: Vector2
var target_node: Node2D = null

func _ready():
	default_position = global_position

func _process(delta):
	if target_node:
		global_position = global_position.lerp(target_node.global_position, 5 * delta)

func zoom_to(target_zoom: Vector2, pan: bool):
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)
	
	if not target_node:
		if pan:
			tween.tween_property(self, "global_position", default_position + pan_offset, zoom_duration)
		else:
			tween.tween_property(self, "global_position", default_position, zoom_duration)

func follow(target: Node2D):
	target_node = target

func reset_follow():
	target_node = null
	global_position = default_position
	
func shake(intensity: float = 1.0, duration: float = 0.3):
	var tween := create_tween()
	var time_passed := 0.0

	# Store original offset
	var original_offset := offset

	tween.tween_callback(func():
		var rng = RandomNumberGenerator.new()
		while time_passed < duration:
			var shake_offset = Vector2(
				rng.randf_range(-intensity, intensity),
				rng.randf_range(-intensity, intensity)
			)
			offset = shake_offset
			await get_tree().create_timer(0.01).timeout
			time_passed += 0.01
		offset = original_offset
	).set_delay(0)

func _on_cast_started():
	letterbox_layer.show_bars()
	zoom_to(zoomed_out, true)

func _on_reeling_started():
	follow(bobber)
	zoom_to(zoomed_in, false)
	


func _on_rod_reeling_finished() -> void:
	letterbox_layer.hide_bars()
	reset_follow()


func _on_rod_bite_started() -> void:
	shake()
