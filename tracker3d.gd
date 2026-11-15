extends Sprite3D

@export var max_tilt_angle: float = 8.0 # Subtle tilt toward cursor edges
@export var y_min_limit: float = -11.0 # Minimum Y rotation when moving left
@export var y_max_limit: float = -80.0 # Maximum Y rotation when moving right (note: in Godot, more negative turns right depending on view setup)
@export var mouse_vel_damping: float = 10.0

var base_position: Vector3
var base_rotation: Vector3
var current_y_offset: float = 0.0
var recoil_tween: Tween

func _ready() -> void:
	base_position = position
	base_rotation = rotation_degrees

func _process(delta: float) -> void:
	position = base_position

	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var center = viewport_size * 0.5
	
	# Get mouse velocity/acceleration based on movement per frame
	var mouse_velocity = Input.get_last_mouse_velocity()
	
	# Map mouse velocity X to our Y-axis range (-11 to -80)
	var target_y_offset = remap(mouse_velocity.x, -2000.0, 2000.0, y_min_limit, y_max_limit)
	target_y_offset = clamp(target_y_offset, y_max_limit, y_min_limit) # Keep within your requested bounds
	
	# Smoothly interpolate the Y offset so it reacts dynamically to acceleration and returns to center
	current_y_offset = lerp(current_y_offset, target_y_offset, mouse_vel_damping * delta)

	# Standard cursor offset tilt
	var mouse_offset = (mouse_pos - center) / center
	mouse_offset = mouse_offset.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

	var target_rot_y = base_rotation.y + current_y_offset - (mouse_offset.x * max_tilt_angle)
	var target_rot_x = base_rotation.x + (mouse_offset.y * max_tilt_angle)
	
	if not (recoil_tween and recoil_tween.is_running()):
		rotation_degrees.y = lerp(rotation_degrees.y, target_rot_y, 12.0 * delta)
		rotation_degrees.x = lerp(rotation_degrees.x, target_rot_x, 12.0 * delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if recoil_tween and recoil_tween.is_valid():
			recoil_tween.kill()
		
		recoil_tween = create_tween()
		recoil_tween.tween_property(self, "rotation_degrees:z", -30.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		recoil_tween.tween_property(self, "rotation_degrees:z", 0.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
