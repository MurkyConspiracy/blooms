extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DECEL = 15


@export var float_mod : float = 0.1
@export var float_duration : float = 1
var float_lock : bool = false

@onready var float_timer: Timer = $Float_Timer
@onready var float_dev: Label = $CanvasLayer/float_dev

@export var fall_duration : float = 0.5
var fall_lock : bool = false

@onready var fall_timer: Timer = $Fall_Timer
@onready var fall_dev: Label = $CanvasLayer/fall_dev


func _ready() -> void:
	float_lock = false
	fall_lock = false

func _physics_process(delta: float) -> void:
	
	float_dev.text = ("Float Time: %f,\tLock: %s" % [float_timer.time_left,float_lock])
	fall_dev.text = ("Fall Time: %f\tLock: %s" % [fall_timer.time_left,fall_lock])
	# Add the gravity and handle float.
	if not is_on_floor():
			
		
		if Input.is_action_pressed("float") && !float_lock:
			if float_timer.is_stopped():
				float_timer.start(float_duration)
				float_timer.set_paused(false)
			elif float_timer.paused:
				float_timer.set_paused(false)
			fall_timer.set_paused(true)
			velocity += (get_gravity() / 2 * float_mod) * delta
		else:
			fall_timer.set_paused(false)
			if !float_timer.is_stopped():
				float_timer.set_paused(true)
			if fall_timer.is_stopped() && !fall_lock:
				print("Start Fall Timer!")
				fall_timer.start(fall_duration)
			velocity += get_gravity() * delta
	else:
		if fall_lock:
			player_death()
		float_timer.set_paused(false)
		float_timer.stop()
		float_lock = false
		fall_timer.set_paused(false)
		fall_timer.stop()

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


func player_death():
	print("Handle Death!")
	get_tree().reload_current_scene()

func _on_float_timer_timeout() -> void:
	float_lock = true


func _on_fall_timer_timeout() -> void:
	fall_lock = true
