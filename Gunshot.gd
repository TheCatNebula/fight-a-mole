extends Sprite2D

var flash_tween: Tween

# Cooldown variables (0.25 seconds = 250 milliseconds)
var fire_cooldown_ms: float = 500.0
var last_shot_time: float = -1000.0

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		var current_time = Time.get_ticks_msec()
		
		# Check if the cooldown has elapsed
		if current_time - last_shot_time < fire_cooldown_ms:
			return # Exit early if still cooling down
			
		last_shot_time = current_time # Update last shot timestamp

		if flash_tween and flash_tween.is_valid():
			flash_tween.kill()

		global_position = get_global_mouse_position()
		visible = true
		rotation_degrees = randf_range(0.0, 360.0)
		modulate.a = 1.0

		flash_tween = create_tween()
		flash_tween.tween_property(self, "modulate:a", 0.0, 0.1)
		flash_tween.tween_callback(hide)

		_check_hit()

func _check_hit() -> void:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results := get_world_2d().direct_space_state.intersect_point(query)
	for result in results:
		var target = result.collider
		if target.is_in_group("targets"):
			target.hit()
