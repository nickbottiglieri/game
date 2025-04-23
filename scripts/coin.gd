extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(_body: Node2D) -> void:
	
	if not visible:
		return
	
	audio_stream_player_2d.play()
	Global.game_manager.add_coin(self)
	hide()
