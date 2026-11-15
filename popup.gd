extends Node

@export var spawn_points_parent: Node
@export var demon: Area2D
@export var angel: Area2D
@export var timer: Timer
@export var score_label: Label
@export var health_component: HealthComponent # Drag your HealthComponent here in the Inspector

@onready var spawn_points: Array = spawn_points_parent.get_children()
var is_visible_phase: bool = false

# Score now lives in the GameState autoload so it survives the 2D <-> 3D switch.
# This getter keeps menus.gd working (it reads spawn_cycle.score).
var score: int:
	get:
		return GameState.score

# Track active states explicitly to avoid visibility desyncs
var is_demon_active: bool = false
var is_angel_active: bool = false

func _ready() -> void:
	set_area_active(demon, false)
	set_area_active(angel, false)
	timer.timeout.connect(_on_timer_timeout)

	# Keep the label in sync, and show the carried-over score when returning from 3D
	GameState.score_changed.connect(_update_score_label)
	_update_score_label()

	# FIX: Start the timer on ready so the loop actually begins!
	timer.start(1.0)

func _on_timer_timeout() -> void:
	if is_visible_phase:
		# If the demon was active and the player didn't hit it (was_hit is false)
		if is_demon_active and not demon.was_hit:
			if health_component:
				health_component.take_damage(1)

		# Turn everything off for the hidden phase
		set_area_active(demon, false)
		set_area_active(angel, false)
		is_demon_active = false
		is_angel_active = false

		is_visible_phase = false
		timer.start(randf_range(0.5, 1.5))

		# After every 10th spawn round, jump to the 3D scene (unless the player just died)
		if GameState.spawns % GameState.SPAWNS_PER_SWITCH == 0 \
				and (not health_component or health_component.current_health > 0):
			GameState.go_to_3d()

	else:
		# --- HIDDEN PHASE IS ENDING -> START VISIBLE PHASE ---
		is_visible_phase = true
		GameState.spawns += 1

		var shuffled_points = spawn_points.duplicate()
		shuffled_points.shuffle()

		var spawn_demon = randf() < 0.5
		var spawn_angel = randf() < 0.5

		if not spawn_demon and not spawn_angel:
			if randf() < 0.5:
				spawn_demon = true
			else:
				spawn_angel = true
				print("Spawning! Points count: ", spawn_points.size())

		if spawn_demon:
			demon.global_position = shuffled_points[0].global_position
			print("Demon moved to: ", demon.global_position, " Visible: ", demon.visible)
			set_area_active(demon, true)
			demon.reset()
			is_demon_active = true
		else:
			set_area_active(demon, false)
			is_demon_active = false

		if spawn_angel:
			var angel_index = 1 if spawn_demon else 0
			angel.global_position = shuffled_points[angel_index].global_position
			set_area_active(angel, true)
			angel.reset()
			is_angel_active = true
		else:
			set_area_active(angel, false)
			is_angel_active = false

		timer.start(1.2)

func set_area_active(area: Area2D, active: bool) -> void:
	area.visible = active
	area.set_deferred("monitoring", active)
	area.set_deferred("monitorable", active)
	area.get_node("CollisionShape2D").set_deferred("disabled", not active)

func add_score(points: int) -> void:
	GameState.add_score(points)

func _update_score_label(_new_score: int = 0) -> void:
	if score_label:
		score_label.text = "Score: " + str(GameState.score)
