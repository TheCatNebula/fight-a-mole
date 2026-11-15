extends Area2D

@export var spawn_cycle: Node

func hit() -> void:
	$CollisionShape2D.set_deferred("monitoring", false)
	set_deferred("monitorable", false)
