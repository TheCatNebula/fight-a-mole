extends CharacterBody3D

@export var move_speed: float = 4.5
@export var strafe_speed: float = 3.0
@export var max_attack_range: float = 0.0 # Starts strafing within 12 meters
@export var min_retreat_range: float = 0.0 # Backs up if player is within 5 meters

@onready var line_of_sight: RayCast3D = $RayCast3D

var player: Node3D = null
var strafe_direction: int = 1
var strafe_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Make sure your 3D player node is in the "player" group
	player = get_tree().get_first_node_in_group("player")
	_pick_new_strafe()

func _physics_process(delta: float) -> void:
	# Apply gravity so the block stays on the ground
	if not is_on_floor():
		velocity.y -= gravity * delta

	if not player:
		move_and_slide()
		return

	# Face the player horizontally (ignoring up/down tilt)
	var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	if global_position.distance_squared_to(look_target) > 0.01:
		look_at(look_target, Vector3.UP)

	# Update random strafe timer
	strafe_timer -= delta
	if strafe_timer <= 0.0:
		_pick_new_strafe()

	# Point RayCast3D at the player to check for walls
	line_of_sight.target_position = to_local(player.global_position + Vector3(0, 1.0, 0))
	line_of_sight.force_raycast_update()
	
	var can_see_player: bool = true
	if line_of_sight.is_colliding() and line_of_sight.get_collider() != player:
		can_see_player = false

	# Calculate horizontal distance and directions
	var flat_pos = Vector3(global_position.x, 0, global_position.z)
	var flat_player_pos = Vector3(player.global_position.x, 0, player.global_position.z)
	var distance = flat_pos.distance_to(flat_player_pos)
	
	var forward_dir = flat_pos.direction_to(flat_player_pos)
	var right_dir = forward_dir.cross(Vector3.UP).normalized() * strafe_direction

	var move_dir := Vector3.ZERO

	if not can_see_player or distance > max_attack_range:
		# 1. CHASE: Too far or blocked by a wall
		move_dir = forward_dir * move_speed
	elif distance < min_retreat_range:
		# 2. RETREAT & STRAFE: Backpedal while strafing
		move_dir = (-forward_dir * (move_speed * 0.7)) + (right_dir * (strafe_speed * 0.5))
	else:
		# 3. OPTIMAL RANGE: Strafe side-to-side
		move_dir = right_dir * strafe_speed

	velocity.x = move_dir.x
	velocity.z = move_dir.z

	move_and_slide()

func _pick_new_strafe() -> void:
	strafe_direction = [-1, 0, 1].pick_random()
	strafe_timer = randf_range(0.6, 1.8)
