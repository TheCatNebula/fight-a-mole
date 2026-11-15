extends Camera2D

@export var health_component: HealthComponent
@export var flash_rect: ColorRect
@export var tilt_degrees: float = 3.0
@export var flash_alpha: float = 0.4

var fx_tween: Tween

func _ready() -> void:
	ignore_rotation = false # Godot 4 defaults this to true, which blocks tilting
	flash_rect.color.a = 0.0
	if health_component:
		health_component.damaged.connect(_on_damaged)

func _on_damaged() -> void:
	if fx_tween and fx_tween.is_valid():
		fx_tween.kill()

	# Snap to a random-direction tilt and a red flash, then ease both back
	rotation_degrees = tilt_degrees * (1.0 if randf() < 0.5 else -1.0)
	flash_rect.color.a = flash_alpha

	fx_tween = create_tween().set_parallel(true)
	fx_tween.tween_property(self, "rotation_degrees", 0.0, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	fx_tween.tween_property(flash_rect, "color:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
