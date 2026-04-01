extends AnimatableBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var id: int

var isDoorOpen: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if isDoorOpen:
		collision_shape_2d.disabled = false
	else:
		collision_shape_2d.disabled = true
	
	animated_sprite_2d.play("idle")

func open_door():
	animated_sprite_2d.play("opening")
	collision_shape_2d.disabled = true
	isDoorOpen = true
	
func close_door():
	animated_sprite_2d.play("closing")
	collision_shape_2d.disabled = false
	isDoorOpen = false
	
func leverInteract(isOn: bool, leverId: int):
	if self.id == leverId:
		if isOn and not isDoorOpen:
			open_door()
		elif not isOn and isDoorOpen:
			close_door()
