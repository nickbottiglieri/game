extends Area2D

@onready var game_manager: Node = %gameManager
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _on_body_entered(_body: Node2D) -> void:
	
	if not visible:
		return
	
	game_manager.play_pickup_sound()
	game_manager.add_coin(self)
	hide()
