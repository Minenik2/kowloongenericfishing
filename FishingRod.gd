extends Node2D

@onready var line: Line2D = $Line2D
@onready var bobber: Node2D = $bobber

var water_level := 32.0
var floating := false
var float_timer := 0.0
var float_amplitude := 2.0
var float_speed := 4.0
var base_water_pos := Vector2.ZERO

var is_casting = false
var fish_on_line = false
var velocity = Vector2.ZERO
var gravity = 300.0

var cast_power_base = Vector2(60, -100)  # Base force
var catch_window = 0.8

var caught = false

var lineAdust = Vector2(14, -2) # adjust the line on the bobber

var reeling := false
var reel_speed := 200.0  # Pixels per second

func _process(delta):
	if is_casting and not fish_on_line:
		if not floating:
			# Simulate arc
			velocity.y += gravity * delta
			bobber.position += velocity * delta

			# Update line points
			line.points = [Vector2.ZERO, bobber.position + lineAdust]

			# Land on water
			if bobber.position.y >= water_level:
				bobber.position.y = water_level
				velocity = Vector2.ZERO
				floating = true
				base_water_pos = bobber.position
				fish_bite_delay()
		else:
			# Floating motion (gentle sine wave)
			float_timer += delta
			var bob_offset = sin(float_timer * float_speed) * float_amplitude
			bobber.position.y = base_water_pos.y + bob_offset
			line.points = [Vector2.ZERO, bobber.position + lineAdust]

	if reeling:
		var target_pos = Vector2(-16, 0)
		var direction = (target_pos - bobber.position).normalized()
		var distance = (target_pos - bobber.position).length()

		# Move bobber towards rod
		var move_amount = min(reel_speed * delta, distance)
		bobber.position += direction * move_amount

		# Update line
		line.points = [Vector2.ZERO, bobber.position + lineAdust]

		# Check if it's close enough to reset
		if distance < 4.0:
			reeling = false
			reset_fishing()
		return  # Don't run other fishing logic during reeling

func cast(facing_right: bool):
	if is_casting:
		return

	is_casting = true
	caught = false
	fish_on_line = false

	bobber.visible = true
	bobber.position = Vector2(-16, 0)  # Origin at rod tip

	# Flip X velocity if facing left
	var direction_multiplier = 1 if facing_right else -1
	velocity = cast_power_base * Vector2(direction_multiplier, 1)

	line.points = [Vector2.ZERO, bobber.position + lineAdust]

func fish_bite_delay():
	var wait_time = randf_range(1.0, 3.0)
	await get_tree().create_timer(wait_time).timeout
	show_bite()

func show_bite():
	if caught or fish_on_line or not floating:
		return

	fish_on_line = true
	print("!! BITE !! Press interact to hook it!")

	await get_tree().create_timer(catch_window).timeout

	if fish_on_line:
		print("The fish escaped...")
		fish_on_line = false
		fish_bite_delay()
		# Do NOT call reset_fishing here – let the player decide to reel in

func try_catch():
	if fish_on_line:
		print("You caught something!")
		fish_on_line = false
		caught = true
		# Reward logic here
		start_reeling()
	elif floating and not fish_on_line:
		print("You reeled in the line.")
		start_reeling()

func reset_fishing():
	floating = false
	float_timer = 0.0
	is_casting = false
	fish_on_line = false
	velocity = Vector2.ZERO
	bobber.visible = false
	line.clear_points()

func start_reeling():
	reeling = true
	floating = false
	velocity = Vector2.ZERO
