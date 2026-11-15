extends Area2D

@export var spawn_cycle: Node
@export var point_value: int = 10

func hit() -> void:
	$mole_died.play()
	print("Who's Mommy's Pretty Boy?")
	if spawn_cycle:
		spawn_cycle.add_score(point_value)
	
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)

func reset() -> void:
	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	$CollisionShape2D.set_deferred("disabled", false)
