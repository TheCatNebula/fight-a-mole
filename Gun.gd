extends Sprite2D

@export var target_min: Vector2 = Vector2(-50, -50) # Small frame min
@export var target_max: Vector2 = Vector2(50, 50)   # Small frame max

var anchor_position: Vector2

# Cooldown variables (0.25 seconds = 250 milliseconds)
var fire_cooldown_ms: float = 250.0
var last_shot_time: float = -1000.0

func _ready() -> void:
	anchor_position = global_position

func _process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Map screen coordinates (0 to viewport_size) to the smaller range
	var mapped_x = remap(mouse_pos.x, 0.0, viewport_size.x, target_min.x, target_max.x)
	var mapped_y = remap(mouse_pos.y, 0.0, viewport_size.y, target_min.y, target_max.y)
	
	# Clamp ensures it stays inside even if the mouse leaves the window
	mapped_x = clamp(mapped_x, target_min.x, target_max.x)
	mapped_y = clamp(mapped_y, target_min.y, target_max.y)
	
	global_position = anchor_position + Vector2(mapped_x, mapped_y)

var recoil_tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		var current_time = Time.get_ticks_msec()
		
		# Check if the cooldown has elapsed since the last shot
		if current_time - last_shot_time < fire_cooldown_ms:
			return # Exit early if still cooling down
			
		last_shot_time = current_time # Update last shot timestamp
		
		# Stop any active rotation so rapid clicks don't stack or drift
		if recoil_tween and recoil_tween.is_valid():
			recoil_tween.kill()
		
		recoil_tween = create_tween()
		# 1. Kick up to 30 degrees (snappy 0.08s kick)
		recoil_tween.tween_property(self, "rotation_degrees", 30.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# 2. Ease back down to 0 degrees (over 0.42s, totaling 0.5s)
		recoil_tween.tween_property(self, "rotation_degrees", 0.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
