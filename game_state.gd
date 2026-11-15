extends Node
## Shared by the 2D and 3D scenes.

signal score_changed(score: int)
signal health_changed(health: int)

const SPAWNS_PER_SWITCH := 10
const SCENE_2D := "res://sprite_2d.tscn"
const SCENE_3D := "res://3D.tscn"

var score: int = 0
var health: int = -1   # -1 = not set yet; HealthComponent fills in max_health
var spawns: int = 0
var in_3d: bool = false

func reset() -> void:
	score = 0
	health = -1
	spawns = 0
	in_3d = false

func add_score(points: int) -> void:
	score += points
	print("SCORE UPDATED: ", score)
	score_changed.emit(score)

func set_health(value: int) -> void:
	health = value
	health_changed.emit(health)

func damage_3d(amount: int = 1) -> void:
	set_health(maxi(health - amount, 0))
	if health == 0:
		go_to_2d() # the 2D scene shows the game-over screen

func go_to_3d() -> void:
	in_3d = true
	get_tree().change_scene_to_file.call_deferred(SCENE_3D)

func go_to_2d() -> void:
	in_3d = false
	get_tree().change_scene_to_file.call_deferred(SCENE_2D)
