extends Label

var score : int = 0

func update_score() -> void:
	score += 1
	text = str(score)
