extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DECEL = 15

@onready var move_effet: AudioStreamPlayer = %MoveEffet
@onready var thump_effect: AudioStreamPlayer = %ThumpEffect
@onready var spread_effect: AudioStreamPlayer = %SpreadEffect
@onready var contract_effect: AudioStreamPlayer = %ContractEffect
@onready var boing_effect: AudioStreamPlayer = %BoingEffect


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

@onready var floor_dev: Label = $CanvasLayer/floor_dev

@onready var character_model: AnimatedSprite2D = $CharacterModel

var left_dash_lock : bool = false
@export var left_dash_velocity : float = 500

var right_dash_lock : bool = false
@export var right_dash_velocity : float = 500

@onready var health_ui_container: HBoxContainer = %HealthUIContainer


func _ready() -> void:
	reset_conditionals()
	DataHandler.player_reference = get_node(".")

func _physics_process(delta: float) -> void:
	float_dev.text = ("Float Time: %f      Lock: %s" % [float_timer.time_left,float_lock])
	fall_dev.text = ("Fall Time: %f      Lock: %s" % [fall_timer.time_left,fall_lock])
	velocity_dev.text = ("XVel: %f      YVel: %f" % [velocity.x, velocity.y])
	floor_dev.text = "Is On Floor: %s" % str(is_on_floor())
	if velocity.y > 1000:
		velocity.y = move_toward(velocity.y, 1000, 1 * (velocity.y - 1000))
		
	
	var collision = move_and_collide(velocity * delta, true)
	if collision:
		if collision.get_angle() < deg_to_rad(5):
			if (collision.get_collider() is AnimatableBody2D && 
				(collision.get_collider() as AnimatableBody2D).physics_material_override.resource_path == "res://scenes/level_components/bounce_platform.tres"):
					boing_effect.pitch_scale = lerp(0.8, 1.5, 1- clamp(abs(velocity.y) / 1000, 0, 1))
					boing_effect.play()
					velocity = velocity.bounce(collision.get_normal().normalized()) * Vector2(1, (collision.get_collider() as AnimatableBody2D).physics_material_override.bounce)
					apply_floor_snap()
					fall_timer.stop()
					left_dash_lock = false
					right_dash_lock = false
			else:
				thump_effect.play()

	# Add the gravity and handle float.
	if not is_on_floor() && !fall_start:
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
		if float_lock:
			float_lock = false
		if fall_lock || velocity.y > death_velocity:
			DataHandler.damage_player()
		if fall_start:
			reset_conditionals()
		if not fall_timer.is_stopped():
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
	if event.is_action_pressed("float") && !float_lock && not is_on_floor():
		spread_effect.play()
		if float_timer.is_stopped():
			float_timer.start(float_duration)
			float_timer.set_paused(false)
			fall_timer.set_paused(true)
		elif float_timer.paused:
			float_timer.set_paused(false)
			fall_timer.set_paused(true)
	elif event.is_action_released("float") && not fall_timer.is_stopped():
		fall_timer.set_paused(false)
		contract_effect.play()
		if !float_timer.is_stopped():
			float_timer.set_paused(true)
		if fall_timer.is_stopped() && !fall_lock:
			fall_timer.start(fall_duration)
	if event.is_action_pressed("dash_right") && !right_dash_lock:
		velocity.y += -120
		velocity.x = right_dash_velocity
		right_dash_lock = true
	if event.is_action_pressed("dash_left") && !left_dash_lock:
		velocity.y += -120
		velocity.x = -left_dash_velocity
		left_dash_lock = true
	if (event.is_action_pressed("move_left") || event.is_action_pressed("move_right")):
		move_effet.play()
	elif event.is_action_released("move_left") && not Input.is_action_pressed("move_right") && move_effet.playing:
		move_effet.stop()
	elif event.is_action_released("move_right") && not Input.is_action_pressed("move_left") && move_effet.playing:
		move_effet.stop()
	elif Input.is_action_pressed("move_left") && Input.is_action_pressed("move_right") && velocity == Vector2.ZERO:
		move_effet.stop()
	if not is_on_floor() && move_effet.playing:
		move_effet.stop()
		

func _on_float_timer_timeout() -> void:
	float_lock = true

func _on_fall_timer_timeout() -> void:
	fall_lock = true
		
func reset_conditionals():
	float_timer.set_paused(false)
	float_timer.stop()
	fall_lock = false
	fall_start = false
	fall_timer.set_paused(false)
	fall_timer.stop()
	fall_lock = false
	left_dash_lock = false
	right_dash_lock = false
	for hp : TextureRect in health_ui_container.get_children():
		if int(hp.name.right(1)) <= DataHandler.player_health:
			(hp.texture as AtlasTexture).region = Rect2(0,0,16,16)
		else:
			(hp.texture as AtlasTexture).region = Rect2(16,0,16,16)
