extends Area2D


func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Player" && DataHandler.player_health < 4:
		DataHandler.heal_player(1)
		DataHandler.player_reference.slerp_effect_play()
		queue_free()
