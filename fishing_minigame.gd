extends CanvasLayer

@export var bar_speed := 200.0
@export var success_zone_height := 50.0

@onready var moving_bar = $PanelContainer/MovingBar
@onready var success_zone = $PanelContainer/SuccessZone
@onready var background_bar = $PanelContainer/BackgroundBar

var direction := 1
var success := false
var in_progress := false
var has_clicked := false

signal fish_caught(success: bool)

func _ready():
	hide()
	moving_bar.position.y = 0
	randomize_success_zone()

func start():
	$start.play()
	show()
	in_progress = true
	success = false
	has_clicked = false
	randomize_success_zone()
	moving_bar.position.y = 0

func stop():
	in_progress = false
	hide()

func randomize_success_zone():
	var bg_height = background_bar.size.y
	var y = randi() % int(bg_height - success_zone_height)
	success_zone.position.y = y
	success_zone.size.y = success_zone_height

func _process(delta):
	if not in_progress:
		return

	# Move the bar
	var pos = moving_bar.position
	pos.y += direction * bar_speed * delta

	var max_y = background_bar.size.y - moving_bar.size.y
	if pos.y < 0:
		pos.y = 0
		direction *= -1
	elif pos.y > max_y:
		pos.y = max_y
		direction *= -1

	moving_bar.position = pos

func _unhandled_input(event):
	if not in_progress or has_clicked or not event.is_action_pressed("interact"):
		return

	has_clicked = true  # Block further input

	var bar_top = moving_bar.position.y
	var bar_bottom = bar_top + moving_bar.size.y
	var success_top = success_zone.position.y
	var success_bottom = success_top + success_zone.size.y

	# Check for success
	if bar_bottom >= success_top and bar_top <= success_bottom:
		$sucess.play()
		success = true
	else:
		$fail.play()
		success = false

	in_progress = false  # Stop movement but keep visible
	
	# Add scale effect (like a little bounce)
	var tween := create_tween()
	var panel = $PanelContainer
	tween.tween_property(panel, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

	# Pause for a moment to let the player see the result
	await get_tree().create_timer(0.5).timeout

	# Now hide and emit result
	fish_caught.emit(success)
	hide()
