
extends Label

func _ready() -> void:
	# Listen for score changes
	GameState.score_changed.connect(_update_score)

	# Display the current score immediately
	_update_score(GameState.score)


func _update_score(new_score: int) -> void:
	text = "Score: " + str(new_score)
