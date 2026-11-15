extends Control

@export var health_component: HealthComponent

# Store the three TextureRect children in order from left to right
@onready var hearts: Array[TextureRect] = [
	$TextureRect,
	$TextureRect2,
	$TextureRect3
]

func _ready() -> void:
	if health_component:
		update_hearts(health_component.current_health)
		health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health: int, _max_health: int) -> void:
	update_hearts(current_health)

func update_hearts(current_health: int) -> void:
	for i in range(hearts.size()):
		# Show the heart if its index is less than current_health
		hearts[i].visible = i < current_health
