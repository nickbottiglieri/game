extends Area2D

@export var level_to_load: int
@export var portal_id: int

# side exiting the portal (left, right, top, bottom)
@export var side: String = 'right'

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var isActive: bool

func _on_ready() -> void:
	
	# don't show starting points (they are for level testing)
	if portal_id == -1:
		collision_shape_2d.disabled = true
		Global.game_manager.playerSave.position = self.global_position
	
	isActive = true
		
func _on_body_entered(_body: Node2D) -> void:

	var x_offset = 0
	var y_offset = 0

	match side:
		'right':
			x_offset = -50
		'left':
			x_offset = 50
		'top':
			y_offset = -50
		'bottom':
			y_offset = 50

	Global.game_manager.enter_portal(level_to_load, portal_id, x_offset, y_offset)
	isActive = false
