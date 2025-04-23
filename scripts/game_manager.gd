extends Node

@onready var damage_sound: AudioStreamPlayer2D = $sounds/damageSound
@onready var save_sound: AudioStreamPlayer2D = $sounds/saveSound

@onready var player: CharacterBody2D = %Player
@onready var hud: CanvasLayer = $HUD

var playerSave
var playerStatusChanged = false
var unsavedCoinNodes: Array[Node] = []

var level_instance
var level_resources: Array = []
var level_1 = preload("res://scenes/level_1.tscn")
var level_2 = preload("res://scenes/level_2.tscn")

func _on_ready() -> void:
	Global.game_manager = self
	level_resources.append(level_1)
	level_resources.append(level_2)
	playerSave = {
		level = 1,
		zoneId = 0,
		position = player.global_position,
		coins = 0,
		health = 3,
	}
	load_level(1)

func unload_level():
	if (level_instance):
		level_instance.queue_free()

func load_level(level: int, portal_id: int = -1):
	unload_level()
	level_instance = level_resources.get(level -1).instantiate()
	get_tree().root.add_child.call_deferred(level_instance)
	
	# set the player in the corresponding position for the portal
	if portal_id != -1:
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
