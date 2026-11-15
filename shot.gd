extends Node2D

# Reference your nodes
@onready var gunshot = $Gunshot
@onready var angel_area = $Angel/AngelArea

func _on_gunshot_area_area_entered(area: Area2D) -> void:
	# Check if the overlapping area belongs to the angel AND the gunshot is visible
	if area == angel_area and gunshot.visible:
		print("dead")
