extends Node

var player_health : int = 4
var spawn_position : Vector2
var player_reference : CharacterBody2D
var player_camera : Camera2D

	
func damage_player(damage_amount : int = 1, force_death : bool = false) -> bool:
	if !player_camera:
		player_camera = get_tree().root.find_child("PlayerCamera",true,false)
	player_health -= damage_amount
	player_reference.velocity = Vector2.ZERO
	if player_health >= 0:
		player_reference.global_position = spawn_position
		player_camera.call("reset_camera_pos")
		reset_input_mapping()
		return false
	elif force_death || player_health < 0:
		player_health = 4
		reset_input_mapping()
		get_tree().reload_current_scene()
		return true
	player_camera.call("reset_camera_pos")
	return false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_game"):
		get_tree().quit(0)
		
func reset_input_mapping() -> void:
	for action in InputMap.get_actions():
		if Input.is_action_pressed(action):
			Input.action_release(action)
