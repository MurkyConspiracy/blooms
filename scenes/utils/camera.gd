extends Camera2D

@export var player_ref : CharacterBody2D
var actual_camera_pos : Vector2
func _ready() -> void:
	actual_camera_pos = player_ref.global_position.round()

func _physics_process(delta: float) -> void:
	actual_camera_pos = actual_camera_pos.lerp(player_ref.global_position, delta *4)
	
	var cam_subpixel_offset = actual_camera_pos.round() - actual_camera_pos
	get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)
	global_position = actual_camera_pos.round()
