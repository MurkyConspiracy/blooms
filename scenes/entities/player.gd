extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_HORIZONTAL_VELOCITTY =750
const DECEL = 15


func _physics_process(delta: float) -> void:
	
	if position.y > 25:
		get_tree().reload_current_scene()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("move_jump_left"):
		velocity.x -= JUMP_HORIZONTAL_VELOCITTY
		velocity.y = JUMP_VELOCITY
		
		
	if Input.is_action_just_pressed("move_jump_right"):
		velocity.x += JUMP_HORIZONTAL_VELOCITTY
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	elif is_on_floor() && !direction:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL)
	
	#print("Vol X:%f\nVol Y:%f" %[velocity.x,velocity.y])
	
	move_and_slide()
