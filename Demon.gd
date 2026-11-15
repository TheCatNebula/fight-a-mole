extends Area2D

@export var spawn_cycle: Node
@export var point_value: int = 10 
@export var health_component: HealthComponent # Drag your HealthComponent here in the Inspector

var was_hit: bool = false

func hit() -> void:
	was_hit = true # Mark that the player shot it successfully!
	$mole_died2.play()
	print("You're Such A Good Boy Aren't You?")
	if spawn_cycle:
		spawn_cycle.add_score(point_value)
	
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)

func reset() -> void:
	was_hit = false # Reset the flag for the new round
	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	$CollisionShape2D.set_deferred("disabled", false)
