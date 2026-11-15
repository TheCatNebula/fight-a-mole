extends CharacterBody3D

const WALK_SPEED = 8.0
const SPRINT_SPEED = 15.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

@onready var camera_3d: Camera3D = $Node3D/Camera3D # Adjust path if your camera node path differs

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"): # Usually the Escape key
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Determine speed based on whether the sprint action is held
	var current_speed = SPRINT_SPEED if (Input.is_action_pressed("sprint") and is_on_floor()) else WALK_SPEED

	# Get input direction and handle movement/deceleration
	var input_dir := Input.get_vector("d", "a", "s", "w")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
