extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DECEL = 15

@export var death_velocity : float = 1500
@onready var velocity_dev: Label = $CanvasLayer/velocity_dev

@export var float_mod : float = 0.1
@export var float_duration : float = 1
var float_lock : bool = false

@onready var float_timer: Timer = $Float_Timer
@onready var float_dev: Label = $CanvasLayer/float_dev

@export var fall_duration : float = 1.5
var fall_lock : bool = false
var fall_start : bool = false

@onready var fall_timer: Timer = $Fall_Timer
@onready var fall_dev: Label = $CanvasLayer/fall_dev

@onready var character_model: AnimatedSprite2D = $CharacterModel

var left_dash_lock : bool = false
@export var left_dash_velocity : float = 500

var right_dash_lock : bool = false
@export var right_dash_velocity : float = 500

func _ready() -> void:
	float_lock = false
	fall_lock = false
	left_dash_lock = false
	right_dash_lock = false

func _physics_process(delta: float) -> void:
	float_dev.text = ("Float Time: %f      Lock: %s" % [float_timer.time_left,float_lock])
	fall_dev.text = ("Fall Time: %f      Lock: %s" % [fall_timer.time_left,fall_lock])
	velocity_dev.text = ("XVel: %f      YVel: %f" % [velocity.x, velocity.y])

	var collision = move_and_collide(velocity * delta, true)
	if collision && collision.get_angle() < deg_to_rad(15):
		if (collision.get_collider() is AnimatableBody2D && 
			(collision.get_collider() as AnimatableBody2D).physics_material_override.resource_path == "res://scenes/level_components/bounce_platform.tres"):
				velocity = velocity.bounce(collision.get_normal().normalized()) * Vector2(1, (collision.get_collider() as AnimatableBody2D).physics_material_override.bounce)
				apply_floor_snap()
				fall_timer.stop()
				left_dash_lock = false
				right_dash_lock = false
	
	# Add the gravity and handle float.
	if not is_on_floor() && !fall_start:
		print("1 frame")
		fall_timer.start(fall_duration)
		fall_start = true
		if float_timer.paused == false && !float_timer.is_stopped():
			velocity += (get_gravity() / 2 * float_mod) * delta
		else:
			velocity += get_gravity() * delta
	elif not is_on_floor():
		if float_timer.paused == false && !float_timer.is_stopped():
			velocity += (get_gravity() / 2 * float_mod) * delta
		else:
			velocity += get_gravity() * delta
	else:
		if fall_lock || velocity.y > death_velocity:
			player_death(true)
		if fall_start:
			reset_conditionals()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x,direction * SPEED, 45)
		character_model.play("walk")
		if (direction > 0):
			character_model.flip_h = true
		else:
			character_model.flip_h = false
	elif is_on_floor() && !direction:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		character_model.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL)
		
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("float") && !float_lock:
		if float_timer.is_stopped():
			float_timer.start(float_duration)
			float_timer.set_paused(false)
		elif float_timer.paused:
			float_timer.set_paused(false)
			fall_timer.set_paused(true)
	elif event.is_action_released("float"):
		fall_timer.set_paused(false)
		if !float_timer.is_stopped():
			float_timer.set_paused(true)
		if fall_timer.is_stopped() && !fall_lock:
			fall_timer.start(fall_duration)
	elif event.is_action_pressed("dash_right") && !right_dash_lock:
		velocity.y += -120
		velocity.x = right_dash_velocity
		right_dash_lock = true
	elif event.is_action_pressed("dash_left") && !left_dash_lock:
		velocity.y += -120
		velocity.x = -left_dash_velocity
		left_dash_lock = true
	
func player_death(soft_death: bool = false):
	if soft_death && DataHandler.player_health > 0:
		DataHandler.player_health -= 1
		print("Remaining Health: %s" % str(DataHandler.player_health))
		reset_player()
	else:
		print("Actual Death")
		get_tree().reload_current_scene()

func _on_float_timer_timeout() -> void:
	float_lock = true


func _on_fall_timer_timeout() -> void:
	fall_lock = true
	
func reset_player():
	global_position = DataHandler.spawn_position
	reset_conditionals()
	print("Soft Death!")
	
func reset_conditionals():
	print("Reset player conditions")
	float_timer.set_paused(false)
	float_timer.stop()
	fall_start = false
	fall_timer.set_paused(false)
	fall_timer.stop()
	fall_lock = false
	left_dash_lock = false
	right_dash_lock = false
	
