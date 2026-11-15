extends CanvasLayer
## Start screen + game-over screen.
## Setup: add a CanvasLayer named "Menus" to the main scene, attach this script,
## then assign health_component and spawn_cycle in the Inspector.
## The UI is built in code, so there's nothing else to wire up.

# Static vars survive reload_current_scene(), so "Play Again" skips the start screen.
static var skip_start_screen: bool = false
static var best_score: int = 0

@export var health_component: HealthComponent
@export var spawn_cycle: Node ## the node running popup.gd (it holds `score`)
@export var game_title: String = "FIGHT A MOLE"
@export_multiline var instructions: String = ""
@export var ui_font: Font ## optional

var _start_panel: Control
var _over_panel: Control
var _start_button: Button
var _again_button: Button
var _score_label: Label
var _best_label: Label
var _game_over: bool = false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS # buttons must work while the tree is paused
	_build_ui()

	if health_component:
		health_component.died.connect(_on_died)

	if not skip_start_screen:
		_show_start()


func _show_start() -> void:
	get_tree().paused = true # freezes the spawn timer, shooting, everything
	_start_panel.visible = true
	_start_button.grab_focus()


func _on_start_pressed() -> void:
	skip_start_screen = true
	_start_panel.visible = false
	get_tree().paused = false


func _on_died() -> void:
	if _game_over:
		return
	_game_over = true

	var final_score: int = spawn_cycle.score if spawn_cycle else 0
	best_score = maxi(best_score, final_score)
	_score_label.text = "Score: %d" % final_score
	_best_label.text = "Best: %d" % best_score

	_over_panel.modulate.a = 0.0
	_over_panel.visible = true
	_again_button.grab_focus()
	get_tree().paused = true

	create_tween().tween_property(_over_panel, "modulate:a", 1.0, 0.4)


func _on_again_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


# --- UI construction -------------------------------------------------------

func _build_ui() -> void:
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ui_theme := Theme.new()
	if ui_font:
		ui_theme.default_font = ui_font
	ui_theme.default_font_size = 36
	root.theme = ui_theme
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Start screen
	_start_panel = _make_panel(root)
	var start_box := _make_box(_start_panel)
	start_box.add_child(_make_label(game_title, 96, Color.WHITE))
	start_box.add_child(_make_label(instructions, 36, Color(0.85, 0.85, 0.85)))
	_start_button = _make_button("START")
	_start_button.pressed.connect(_on_start_pressed)
	start_box.add_child(_start_button)

	# Game-over screen
	_over_panel = _make_panel(root)
	var over_box := _make_box(_over_panel)
	over_box.add_child(_make_label("GAME OVER", 96, Color(1.0, 0.25, 0.25)))
	_score_label = _make_label("", 56, Color.WHITE)
	over_box.add_child(_score_label)
	_best_label = _make_label("", 36, Color(0.85, 0.85, 0.85))
	over_box.add_child(_best_label)
	_again_button = _make_button("PLAY AGAIN")
	_again_button.pressed.connect(_on_again_pressed)
	over_box.add_child(_again_button)


func _make_panel(parent: Control) -> ColorRect:
	var panel := ColorRect.new() # default mouse filter (Stop) blocks clicks behind it
	panel.color = Color(0, 0, 0, 0.7)
	panel.visible = false
	parent.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return panel


func _make_box(panel: Control) -> VBoxContainer:
	var center := CenterContainer.new()
	panel.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 28)
	center.add_child(box)
	return box


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 80)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return button
