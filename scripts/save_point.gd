extends Area2D
@onready var game_manager: Node = %gameManager

@export var save_zone_id: int = 1

func _on_body_entered(body: Node2D) -> void:
	game_manager.save_game(save_zone_id, body.global_position)
