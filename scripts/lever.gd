extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

@export var id: int

var canInteract: bool = false
var isOn: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if isOn:
		animated_sprite_2d.play("on idle")
	else:
		animated_sprite_2d.play("off idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if canInteract and Input.is_action_just_pressed("interact") and timer.TIMER_PROCESS_IDLE:
		if isOn:
			animated_sprite_2d.play("turn off")
			isOn = false
		else:
			animated_sprite_2d.play("turn on")
			isOn = true
		
		interactWithDoors()
		timer.start()
	
# call all doors leverInteract method
func interactWithDoors():
	get_tree().call_group("doors", "leverInteract", isOn, id)

func _on_body_entered(body: Node2D) -> void:
	canInteract = true

func _on_body_exited(body: Node2D) -> void:
	canInteract = false
