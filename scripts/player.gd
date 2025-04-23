extends CharacterBody2D

const SPEED: float = 130.0
const JUMP_VELOCITY: float = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision_shape: CollisionShape2D = $normalCollisionShape
@onready var roll_collision_shape: CollisionShape2D = $rollCollisionShape
@onready var hud: CanvasLayer = $"../gameManager/HUD"

enum State { NORMAL, ROLLING, DAMAGE, SAVE }
var current_state: State = State.NORMAL

var maxHealth: int = 3
var health: int = 3
var coins: int = 0

var damage_timer: float = 0.0
const DAMAGE_DURATION: float = 1.5

func _ready() -> void:
	Global.player = self
				
	hud.update_health_display(health)
	hud.update_coin_display(coins)
	
	Global.game_manager.connect("player_damage", take_damage)
	Global.game_manager.connect("player_add_coin", add_coin)
	Global.game_manager.connect("player_save_zone", save_game)
	Global.game_manager.connect("player_death", reset_to_save)
	Global.game_manager.connect("player_load_level", set_new_level_position)
	
func save_game():
	current_state = State.SAVE
	Global.game_manager.save_stats(coins, health)
	full_heal()

func full_heal():
	health = maxHealth
	Global.game_manager.update_health_display(health)

func add_coin():
	coins += 1
	Global.game_manager.update_coin_display(coins)

func take_damage(damage_dealt):
	if current_state == State.DAMAGE:
		return
	
	current_state = State.DAMAGE
	health -= damage_dealt
	Global.game_manager.play_damage_sound()
	Global.game_manager.update_health_display(health)
			
func die():
	Global.game_manager.return_to_save_point();
	
func set_new_level_position(portal_id):
	var levelTransitionNodes = get_tree().get_nodes_in_group("level_transitions")
	var correspondingTransitionNode = findMatch(levelTransitionNodes, portal_id)
	self.global_position.x = correspondingTransitionNode.global_position.x
	self.global_position.y = correspondingTransitionNode.global_position.y - 25
	
func findMatch(list, portalId):
	for item in list:
		if (item.portal_id == portalId and item.isActive):
			return item

func reset_to_save(savePosition: Vector2, coinsBeforeDeath: int):
	self.global_position = savePosition
	coins = coinsBeforeDeath
	Global.game_manager.update_coin_display(coins)
	full_heal()
	current_state = State.NORMAL
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	match current_state:
		State.NORMAL:
			if Input.is_action_just_pressed("roll"):
				current_state = State.ROLLING
				
			#Play animations    
			if is_on_floor():
				if direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
			
		State.ROLLING:
			animated_sprite.play("roll")
			
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
		
	
