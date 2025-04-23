extends Area2D

const WATER_DAMAGE: int = 1000

func _on_body_entered(_body: Node2D) -> void:
	Global.game_manager.damage_player(WATER_DAMAGE)
