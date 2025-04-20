extends Area2D

@onready var game_manager: Node = %gameManager

const WATER_DAMAGE: int = 1000

func _on_body_entered(_body: Node2D) -> void:
	game_manager.damage_player(WATER_DAMAGE)
