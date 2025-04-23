extends Area2D

@export var save_zone_id: int = 1

func _on_body_entered(body: Node2D) -> void:	
	Global.game_manager.save_game(save_zone_id, body.global_position)
