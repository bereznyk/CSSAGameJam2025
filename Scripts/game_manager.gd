extends Node

var game_over = false
var score = 0

@onready var game_score = %GameScore
@onready var death_screen = %Death
@onready var end_score = %EndScore
	
func _process(delta):
	if Input.is_action_just_pressed("restart") and game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()

func end_game():
	game_over = true
	get_tree().paused = true
	
	end_score.text = str(score)
	death_screen.visible = true
	end_score.visible = true
	
	game_score.visible = false

func update_score(count):
	score += count
	game_score.text = "Score: " + str(score)
