extends Node2D

@onready var line: Line2D = $Line2D
@onready var bobber: Node2D = $bobber

const WATER_LEVEL := 32.0
const ROD_TIP_POSITION := Vector2(14, -2)

# --- Casting Variables ---
var is_casting = false
var velocity = Vector2.ZERO
const GRAVITY := 300.0
var cast_power_base = Vector2(60, -100)

# --- Floating Variables ---
var floating := false
var float_timer := 0.0
const FLOAT_AMPLITUDE := 2.0
const FLOAT_SPEED := 4.0
var base_water_pos := Vector2.ZERO

var caught = false
var fish_on_line = false
var catch_window = 0.8 # window to catch the fish

# --- Reeling Variables ---
var reeling_in := false
const REEL_SPEED := 200.0

func _process(delta):
	if reeling_in:
		# Reeling motion
		var target = Vector2(-16, 0)
		bobber.position = bobber.position.move_toward(target, 300 * delta)
		line.points = [Vector2.ZERO, bobber.position + ROD_TIP_POSITION]

		# When close enough to rod, reset
		if bobber.position.distance_to(target) < 2:
			reset_fishing()
		return  # Stop all other logic during reeling

	if is_casting and not fish_on_line:
		if not floating:
			# Simulate arc
			velocity.y += GRAVITY * delta
			bobber.position += velocity * delta

			# Update line points
			line.points = [Vector2.ZERO, bobber.position + ROD_TIP_POSITION]

			# Land on water
			if bobber.position.y >= WATER_LEVEL:
				bobber.position.y = WATER_LEVEL
				velocity = Vector2.ZERO
				floating = true
				base_water_pos = bobber.position
				fish_bite_delay()
		else:
			# Floating motion (gentle sine wave)
			float_timer += delta
			var bob_offset = sin(float_timer * FLOAT_SPEED) * FLOAT_AMPLITUDE
			bobber.position.y = base_water_pos.y + bob_offset
			line.points = [Vector2.ZERO, bobber.position + ROD_TIP_POSITION]

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

	line.points = [Vector2.ZERO, bobber.position + ROD_TIP_POSITION]

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
		start_reeling_in()
	elif floating and not fish_on_line:
		print("You reeled in the line.")
		start_reeling_in()

func reset_fishing():
	reeling_in = false
	floating = false
	float_timer = 0.0
	is_casting = false
	fish_on_line = false
	velocity = Vector2.ZERO
	line.clear_points()
	bobber.visible = false

func start_reeling_in():
	reeling_in = true
	floating = false  # Stop floating motion
	velocity = Vector2.ZERO  # Stop arc motion
