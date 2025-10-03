extends Area2D


func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Player":
		DataHandler.heal_player(1)
		DataHandler.player_reference.slerp_effect_play()
		DataHandler.secrets_collected += 1
		DataHandler.player_reference.draw_collectables()
		queue_free()
