extends Camera2D

@export var player_ref : CharacterBody2D
@export var camera_pan_offset : float = 95
var actual_camera_pos : Vector2

func _ready() -> void:
	actual_camera_pos = player_ref.global_position.round()

func _physics_process(delta: float) -> void:
	var pan_speed_offset = 0.00001 + (actual_camera_pos.distance_to(player_ref.global_position)* 0.05)
	if !Input.is_action_pressed("pan_down"):
		actual_camera_pos = actual_camera_pos.slerp(player_ref.global_position, delta * 4 * pan_speed_offset)
	else:
		actual_camera_pos = actual_camera_pos.lerp(player_ref.global_position + Vector2(0,camera_pan_offset), delta * 4 * pan_speed_offset)
	var cam_subpixel_offset = actual_camera_pos.round() - actual_camera_pos
	get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	global_position = actual_camera_pos.round()
	
func reset_camera_pos():
	actual_camera_pos = player_ref.global_position.round()
	global_position = player_ref.global_position.round()
