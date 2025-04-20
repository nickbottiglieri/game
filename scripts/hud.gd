extends CanvasLayer

@onready var coins_label: Label = $VBoxContainer/HBoxContainer/coinsLabel
@onready var health_label: Label = $VBoxContainer/HBoxContainer2/healthLabel

func update_coin_display(coins: int):
	coins_label.text = str(coins)

func update_health_display(health: int):
	health_label.text = str(health)
