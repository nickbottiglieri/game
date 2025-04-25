extends Node

@onready var damage_sound: AudioStreamPlayer2D = $sounds/damageSound
@onready var save_sound: AudioStreamPlayer2D = $sounds/saveSound

@onready var scene_transition: AnimationPlayer = $sceneTransition/AnimationPlayer

@onready var player: CharacterBody2D = %Player
@onready var hud: CanvasLayer = $HUD

@export var startLevel: int = 1

var playerSave
var currentLevel = startLevel
var playerStatusChanged = false
var unsavedCoinNodes: Array[Node] = []

var level_instance
var level_resources: Array = [
	preload("res://scenes/level_1.tscn"), 
	preload("res://scenes/level_2.tscn"), 
	preload("res://scenes/level_3.tscn")
]

func _on_ready() -> void:
	Global.game_manager = self
	
	playerSave = {
		level = startLevel,
		zoneId = 0,
		position = Vector2(0, 0),
		coins = 0,
		health = 3,
	}
		
	enter_portal(startLevel)
		
func unload_level():
	if (level_instance):
		level_instance.queue_free()

func load_level(level: int):
	unload_level()
	level_instance = level_resources.get(level - 1).instantiate()
	get_tree().root.add_child.call_deferred(level_instance)

# load the new level and set the player's position to the
# corresponding portal in the new level
func enter_portal(level: int, portal_id: int = -1):
	load_level(level)
	player.set_new_level_position.call_deferred(portal_id)

func save_game(zoneId: int, position: Vector2):
	
	if not playerStatusChanged and playerSave.zoneId == zoneId:
		return
	
	# free coins collected
	unsavedCoinNodes.map(func(coin: Node): coin.queue_free())
	unsavedCoinNodes.clear()
	
	playerStatusChanged = false
	
	# save player stats
	playerSave.zoneId = zoneId
	playerSave.position = position
	playerSave.coins = player.coins
	playerSave.health = player.health
	playerSave.level = currentLevel
	
	play_save_game_sound()
	
	player.save_game()

func reset_coins():
	playerStatusChanged = false
	
	# show coins that were not saved upon death
	unsavedCoinNodes.map(func(coin: Node): coin.show())
	unsavedCoinNodes.clear()

func add_coin(coin: Node):
	unsavedCoinNodes.push_back(coin)
	playerStatusChanged = true
	player.add_coin()
	
func damage_player(damage_dealt):
	playerStatusChanged = true
	player.take_damage(damage_dealt)
		
func play_damage_sound():
	damage_sound.play()
	
func play_save_game_sound():
	save_sound.play()
