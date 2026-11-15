class_name HealthComponent
extends Node

signal damaged
signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 3
var current_health: int

func _ready() -> void:
	if GameState.health < 0:
		GameState.health = max_health
	current_health = GameState.health
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		call_deferred("emit_signal", "died") # you died in 3D, so show game over
func take_damage(amount: int) -> void:
	var before := current_health
	current_health = clampi(current_health - amount, 0, max_health)
	if current_health < before:
		damaged.emit()
	health_changed.emit(current_health, max_health)
	GameState.set_health(current_health)
	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	GameState.set_health(current_health)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("damage"):
		print("Damage key pressed!")
		take_damage(1)
