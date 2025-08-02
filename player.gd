extends CharacterBody2D

@export var move_speed: float = 60.0
@onready var fishing_rod = $rod
@onready var sprite = $Sprite2D

var is_facing_right := true

func _physics_process(delta):
	handle_movement(delta)

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if not fishing_rod.is_casting:
			fishing_rod.begin_charge()
	elif event.is_action_released("interact"):
		if fishing_rod.is_charging:
			fishing_rod.end_charge_and_cast(is_facing_right)
		elif fishing_rod.is_casting:
			fishing_rod.try_catch()

func handle_movement(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("left"):
		direction.x -= 1
		is_facing_right = false
	elif Input.is_action_pressed("right"):
		direction.x += 1
		is_facing_right = true

	velocity = direction * move_speed
	move_and_slide()

	# Flip sprite
	sprite.flip_h = not is_facing_right
	$rod.flip_h = is_facing_right

	# Move the rod with the player (flips X)
	if not fishing_rod.is_casting:
		fishing_rod.position.x = 6 if is_facing_right else -6
