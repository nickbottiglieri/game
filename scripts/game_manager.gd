extends Node

# Sounds
@onready var damage_sound: AudioStreamPlayer2D = $sounds/damageSound
@onready var save_sound: AudioStreamPlayer2D = $sounds/saveSound
@onready var save_points: Node = $"../savePoints"
@onready var player: CharacterBody2D = $"../Player"

@onready var hud: CanvasLayer = $HUD

# Signals
signal player_damage
signal player_add_coin
signal player_save_zone
signal player_death(playerSaveLoc: Vector2, playerSaveCoins: int)

var playerSave
var playerStatusChanged = false
var unsavedCoinNodes: Array[Node] = []

@onready var start_save_point = save_points.get_child(0)

func _on_ready() -> void:
	playerSave = {
		zoneId = 0,
		position = player.global_position,
		coins = 0,
		health = 3,
	}

func save_game(zoneId: int, position: Vector2):
	
	if not playerStatusChanged and playerSave.zoneId == zoneId:
		return
	
	# free coins collected
	unsavedCoinNodes.map(func(coin: Node): coin.queue_free())
	unsavedCoinNodes.clear()
	
	playerStatusChanged = false
	playerSave.zoneId = zoneId
	playerSave.position = position
	play_save_game_sound()
	player_save_zone.emit()
		
func return_to_save_point():
	playerStatusChanged = false
	
	# show coins that were not saved upon death
	unsavedCoinNodes.map(func(coin: Node): coin.show())
	unsavedCoinNodes.clear()
	
	player_death.emit(playerSave.position, playerSave.coins)

func save_stats(coins: int, health: int):
	playerSave.coins = coins
	playerSave.health = health

func add_coin(coin: Node):
	unsavedCoinNodes.push_back(coin)
	playerStatusChanged = true
	player_add_coin.emit()
	
func damage_player(damage_dealt):
	playerStatusChanged = true
	player_damage.emit(damage_dealt)
	
func update_coin_display(coins: int):
	hud.update_coin_display(coins)
	
func update_health_display(health: int):
	hud.update_health_display(health)
	
func play_damage_sound():
	damage_sound.play()
	
func play_save_game_sound():
	save_sound.play()
