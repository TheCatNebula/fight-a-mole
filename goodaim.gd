extends Node3D

const RAY_LENGTH: float = 100.0

func _physics_process(_delta: float) -> void:
	# Only run the raycast on the exact frame "shoot" is pressed
	if Input.is_action_just_pressed("shoot"):
		check_hit_scan()

func check_hit_scan() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return
		
	var screen_center: Vector2 = get_viewport().get_visible_rect().size / 2.0
	var ray_origin: Vector3 = camera.project_ray_origin(screen_center)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(screen_center) * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result.collider
		print("my beautiful boy just shot his load on the ", hit_object.name)
