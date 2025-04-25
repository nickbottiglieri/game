extends Area2D

@export var level_to_load: int
@export var portal_id: int
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
var isActive: bool

func _on_ready() -> void:
	
	# don't show starting points (they are for level testing)
	if portal_id == -1:
		sprite_2d.hide()	
		collision_shape_2d.disabled = true
	
	isActive = true
	
func _on_body_entered(_body: Node2D) -> void:
	Global.game_manager.enter_portal(level_to_load, portal_id)
	isActive = false
