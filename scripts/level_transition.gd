extends Area2D

@export var level_to_load: int
@export var portal_id: int
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var isActive: bool

func _on_ready() -> void:	
	isActive = true

func _on_body_entered(_body: Node2D) -> void:
	Global.game_manager.load_level(level_to_load, portal_id)
	isActive = false
