extends Node2D

@onready var killzone: Area2D = $killzone

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_left_player_pursuit: RayCast2D = $RayCastLeftPlayerPursuit
@onready var ray_cast_right_player_pursuit: RayCast2D = $RayCastRightPlayerPursuit
@onready var ray_cast_left_player_attack: RayCast2D = $RayCastLeftPlayerAttack
@onready var ray_cast_right_player_attack: RayCast2D = $RayCastRightPlayerAttack

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_run_timer: Timer = $idleRunTimer
@onready var pursuit_timer: Timer = $pursuitTimer

@onready var head_collision_shape: CollisionShape2D = $killzone/headCollisionShape
@onready var attack_left_collision_shape: CollisionShape2D = $killzone/attackLeftCollisionShape
@onready var attack_right_collision_shape: CollisionShape2D = $killzone/attackRightCollisionShape

const SPEED_RUN: int = 60
const SPEED_PURSUIT: int = 90
const DAMAGE_DEALT: int = 2
const PURSUIT_TIMER_LENGTH: int = 7

enum State { IDLE, RUN, ATTACK, PURSUIT }
var current_state: State = State.IDLE

var dir: int = -1

func _on_ready() -> void:
	killzone.hit.connect(deal_damage)
	idle_run_timer.start(randi()%3)
	
func deal_damage():
	Global.game_manager.damage_player(DAMAGE_DEALT)

func _process(delta: float) -> void:	
	# Enemy sees player, not close enough to attack, and not currently attacking
	if enemySeesPlayer() and not attackRayColliding() and current_state != State.ATTACK and current_state != State.PURSUIT:
		current_state = State.PURSUIT
		pursuit_timer.start(PURSUIT_TIMER_LENGTH)
			
	# Enemy is close enough to attack
	elif attackRayColliding() and current_state != State.ATTACK:
		current_state = State.ATTACK
					
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.RUN:
			animated_sprite.play("run")
			apply_movement(SPEED_RUN, delta)
		State.ATTACK:
			animated_sprite.play("attack")
			
			if animated_sprite.frame >= 5 and animated_sprite.frame <= 7:
				if isFacingLeft():
					attack_left_collision_shape.disabled = false
				else:
					attack_right_collision_shape.disabled = false
					
				head_collision_shape.disabled = true
			else:
				if isFacingLeft():
					attack_left_collision_shape.disabled = true
				else:
					attack_right_collision_shape.disabled = true
					
				head_collision_shape.disabled = false
		State.PURSUIT:			
			animated_sprite.play("run")
						
			if ray_cast_left_player_pursuit.is_colliding():
				if dir == 1:
					flipSprite()
				dir = -1
			elif ray_cast_right_player_pursuit.is_colliding():
				if dir == -1:
					flipSprite()
				dir = 1
			
			apply_movement(SPEED_PURSUIT, delta)

func _on_idle_run_timer_timeout() -> void:
	swapStates()
	
func _on_pursuit_timer_timeout() -> void:
	current_state = State.IDLE
	resetIdleRunTimer()
	
func setRandomDirection():
	var random_number = randi()%2
	match random_number:
		0:
			if dir == -1:
				flipSprite()
			dir = 1
		1:
			if dir == 1:
				flipSprite()
			dir = -1

func swapStates():
	match current_state:
		State.IDLE:
			setRandomDirection()
			resetIdleRunTimer()
			current_state = State.RUN
		State.RUN:
			setRandomDirection()
			resetIdleRunTimer()
			current_state = State.IDLE
			
func flipSprite():
	animated_sprite.flip_h = not animated_sprite.flip_h
	
func resetIdleRunTimer():
	idle_run_timer.start(randi()%3)
	
func apply_movement(speed: int, delta: float):
	if isFacingLeft():
		if ray_cast_left.is_colliding():
			flipSprite()
			dir *= -1
	else:
		if ray_cast_right.is_colliding():
			flipSprite() 
			dir *= -1
		
	position.x += dir * speed * delta
	
func enemySeesPlayer():
	return (ray_cast_left_player_pursuit.is_colliding() and dir == -1) or (ray_cast_right_player_pursuit.is_colliding() and dir == 1)
	
func attackRayColliding():
	return ray_cast_left_player_attack.is_colliding() or ray_cast_right_player_attack.is_colliding()

func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.ATTACK:
			if ray_cast_left_player_attack.is_colliding():
				if dir == 1:
					flipSprite()
				dir = -1
			elif ray_cast_right_player_attack.is_colliding():
				if dir == -1:
					flipSprite()
				dir = 1
			else:
				current_state = State.PURSUIT
				
func isFacingLeft():
	return dir == -1
