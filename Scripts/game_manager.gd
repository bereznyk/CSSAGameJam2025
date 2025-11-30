extends Node

var game_over = false
var score = 0

var num_shapes = 0 # Number of shapes on the map
var num_enemies = 0 # Number of enemies on the map

@onready var game_score = %GameScore
@onready var death_screen = %Death
@onready var end_score = %EndScore
	
func _process(delta):
	if Input.is_action_just_pressed("restart") and game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()

func start_game():
	pass

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
