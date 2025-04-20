extends Node2D

@onready var killzone: Area2D = $killzone
@onready var game_manager: Node = %gameManager

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_floor_check_right: RayCast2D = $RayCastFloorCheckRight
@onready var ray_cast_floor_check_left: RayCast2D = $RayCastFloorCheckLeft

@export var SPEED: int = 60
const DAMAGE_DEALT: int = 1
var dir: int = 1

func _ready() -> void:
	killzone.hit.connect(deal_damage)

func deal_damage():
	game_manager.damage_player(DAMAGE_DEALT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if isFacingLeft():
		if ray_cast_left.is_colliding() or not ray_cast_floor_check_left.is_colliding():
			flipSprite()
	else:
		if ray_cast_right.is_colliding() or not ray_cast_floor_check_right.is_colliding():
			flipSprite() 
		
	position.x += dir * SPEED * delta
	
func isFacingLeft():
	return dir == -1
	
func flipSprite():
	dir *= -1
	animated_sprite.flip_h = not animated_sprite.flip_h
