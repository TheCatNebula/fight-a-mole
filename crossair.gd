extends Control

@export var dot_color: Color = Color.WHITE
@export var dot_size: float = 4.0

func _gui_input(event: InputEvent) -> void:
	pass

func _draw() -> void:
	# Draws a clean crosshair dot right in the middle of the screen viewport
	var center = get_viewport_rect().size * 0.5
	draw_circle(center, dot_size, dot_color)
