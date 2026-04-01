extends CharacterBody2D

const SPEED: float = 130.0
const JUMP_VELOCITY: float = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision_shape: CollisionShape2D = $normalCollisionShape
@onready var roll_collision_shape: CollisionShape2D = $rollCollisionShape
@onready var hud: CanvasLayer = $"../gameManager/HUD"
@onready var camera_2d: Camera2D = $Camera2D

enum State { NORMAL, ROLLING, DAMAGE, SAVE }
var current_state: State = State.NORMAL

# player stats
var maxHealth: int = 3
var health: int = 3
var coins: int = 0

# duration of invincibility after taking damage
var damage_timer: float = 0.0
const DAMAGE_DURATION: float = 1.5

func _ready() -> void:
	Global.player = self
		
	hud.update_health_display(health)
	hud.update_coin_display(coins)
	
# player visits save zone
func save_game():
	current_state = State.SAVE
	full_heal()

# reset health to max
func full_heal():
	health = maxHealth
	hud.update_health_display(health)

# player collects a coin
func add_coin():
	coins += 1
	hud.update_coin_display(coins)

# player takes damage
func take_damage(damage_dealt):
	if current_state == State.DAMAGE:
		return
	
	current_state = State.DAMAGE
	health -= damage_dealt
	Global.game_manager.play_damage_sound()
	hud.update_health_display(health)

# player dies
func die():	
	# reset coins to before death
	Global.game_manager.reset_coins()
	self.coins = Global.game_manager.playerSave.coins
	hud.update_coin_display(coins)
	
	# reset the player to their position in their last save
	self.global_position = Global.game_manager.playerSave.position
		
	#load the level that the player last saved in
	Global.game_manager.reset_level()
		
	full_heal()
	self.current_state = State.NORMAL
	
func startSceneTransition():
	normal_collision_shape.disabled = true
	
func endSceneTransition():
	normal_collision_shape.disabled = false
			
func _physics_process(delta: float) -> void:
	# add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# get the input direction (-1, 0, 1)
	var direction := Input.get_axis("move_left", "move_right")

	# flip the sprite 
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	match current_state:
		State.NORMAL:
			if Input.is_action_just_pressed("roll"):
				current_state = State.ROLLING
				 
			if is_on_floor():
				if direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
			
		State.ROLLING:
			animated_sprite.play("roll")
			
			# switch hitbox when player rolls (only for certain frames) 
			if animated_sprite.frame >= 2 && animated_sprite.frame <= 6:
				normal_collision_shape.disabled = true
				roll_collision_shape.disabled = false
			else:
				normal_collision_shape.disabled = false
				roll_collision_shape.disabled = true
			
		State.DAMAGE:
			animated_sprite.play("damage")
			damage_timer += delta
			
			if health <= 0:
				die()
					
		State.SAVE:
			animated_sprite.play("save")
			return
				
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		
func _on_animated_sprite_2d_animation_finished() -> void:
	match current_state:
		State.ROLLING:
			current_state = State.NORMAL
		State.DAMAGE:
			if damage_timer > DAMAGE_DURATION:
				damage_timer = 0.0
				current_state = State.NORMAL
		State.SAVE:
			current_state = State.NORMAL
		
	
